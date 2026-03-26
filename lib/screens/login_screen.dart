import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../data/privacy_storage.dart';
import '../l10n/app_strings.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({
    super.key,
    this.onLogin,
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    this.consentPrompt,
    this.emailLoginOverride,
    this.onConsentAccepted,
  })  : auth = auth ?? FirebaseAuth.instance,
        googleSignIn = googleSignIn ?? GoogleSignIn();

  final void Function(String name)? onLogin;
  final FirebaseAuth auth;
  final GoogleSignIn googleSignIn;
  final Future<bool> Function(BuildContext context)? consentPrompt;
  final Future<UserCredential> Function(String email, String password)?
      emailLoginOverride;
  final Future<void> Function()? onConsentAccepted;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const int _resetCooldownDuration = 30;
  static const int _maxFailedLoginAttempts = 5;
  static const Duration _loginLockDuration = Duration(minutes: 2);

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _isPasswordVisible = false;
  bool _isSendingResetEmail = false;
  bool _isSubmitting = false;
  bool _acceptedPolicy = false;
  int _resetCooldownSeconds = 0;
  Timer? _resetCooldownTimer;
  String? _loginInlineError;
  int _failedLoginAttempts = 0;
  DateTime? _loginLockedUntil;

  @override
  void initState() {
    super.initState();
    // Cleanup session on login screen entry (user logged out)
    _cleanupSession();
  }

  Future<void> _cleanupSession() async {
    try {
      await widget.auth.signOut();
      await widget.googleSignIn.signOut();
    } catch (e) {
      debugPrint('Session cleanup on login screen: $e');
    }
  }

  @override
  void dispose() {
    _resetCooldownTimer?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isLoginLocked {
    final lock = _loginLockedUntil;
    if (lock == null) {
      return false;
    }
    if (DateTime.now().isAfter(lock)) {
      _loginLockedUntil = null;
      return false;
    }
    return true;
  }

  int get _remainingLockSeconds {
    final lock = _loginLockedUntil;
    if (lock == null) {
      return 0;
    }
    final seconds = lock.difference(DateTime.now()).inSeconds;
    return seconds > 0 ? seconds : 0;
  }

  String _sanitizeDisplayName(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ');

  String? _validateName(String? value) {
    final s = AppStrings.of(context);
    final name = _sanitizeDisplayName(value ?? '');
    if (name.isEmpty) {
      return null;
    }
    if (name.length < 2) {
      return s.nameAtLeast2;
    }
    if (name.length > 50) {
      return s.nameMax50;
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final s = AppStrings.of(context);
    final email = (value ?? '').trim();
    if (email.isEmpty) {
      return s.emailRequired;
    }
    if (!_isValidEmail(email)) {
      return s.enterValidEmail;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final s = AppStrings.of(context);
    final password = value ?? '';
    if (password.isEmpty) {
      return s.passwordRequired;
    }

    if (_isLogin) {
      if (password.length < 6) {
        return s.min6Chars;
      }
      return null;
    }

    if (password.length < 8) {
      return s.min8Chars;
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return s.needUppercase;
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return s.needLowercase;
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      return s.needNumber;
    }
    return null;
  }

  void _registerCredentialFailure() {
    _failedLoginAttempts += 1;
    if (_failedLoginAttempts >= _maxFailedLoginAttempts) {
      _failedLoginAttempts = 0;
      _loginLockedUntil = DateTime.now().add(_loginLockDuration);
    }
  }

  void _resetLoginProtection() {
    _failedLoginAttempts = 0;
    _loginLockedUntil = null;
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isLogin && _isLoginLocked) {
      _showErrorSnackBar(
        AppStrings.of(context).tryAgainInSec(_remainingLockSeconds),
      );
      return;
    }

    if (_loginInlineError != null) {
      setState(() {
        _loginInlineError = null;
      });
    }

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (_isLogin) {
        final credential = widget.emailLoginOverride != null
            ? await widget.emailLoginOverride!(email, password)
            : await widget.auth.signInWithEmailAndPassword(
                email: email,
                password: password,
              );
        final canProceed = await _ensureConsentAfterEmailLogin();
        if (!canProceed) {
          return;
        }

        final user = credential.user;
        final name = user?.displayName?.trim().isNotEmpty == true
            ? user!.displayName!
            : (user?.email?.split('@').first ?? 'User');

        _resetLoginProtection();
        widget.onLogin?.call(name);
      } else {
        if (!_acceptedPolicy) {
          _showErrorSnackBar(AppStrings.of(context).acceptPolicyFirst);
          return;
        }

        final name = _sanitizeDisplayName(_nameController.text);
        final credential = await widget.auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        await credential.user?.updateDisplayName(name);
        await PrivacyStorage.saveConsentAcceptedNow();
        widget.onLogin?.call(name.isNotEmpty ? name : email.split('@').first);
      }
    } on FirebaseAuthException catch (e) {
      final message = _isLogin
          ? _resolveLoginErrorMessage(e)
          : _friendlyAuthMessage(code: e.code, isLoginFlow: false);

      if (_isLogin && _isCredentialMismatchCode(e.code)) {
        _registerCredentialFailure();
        setState(() {
          _loginInlineError = message;
        });
        return;
      }

      _showErrorSnackBar(message);
    } catch (e) {
      debugPrint('Unexpected sign-in error: $e (${e.runtimeType})');
      if (kDebugMode) {
        _showErrorSnackBar('Debug: $e');
      } else {
        if (!mounted) return;
        _showErrorSnackBar(AppStrings.of(context).authFailedTryAgain);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showPolicyDialog({required String title, required String body}) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(body)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.of(context).close),
          ),
        ],
      ),
    );
  }

  String _resolveLoginErrorMessage(FirebaseAuthException error) {
    if (_isCredentialMismatchCode(error.code)) {
      return AppStrings.of(context).invalidCredentials;
    }

    return _friendlyAuthMessage(code: error.code, isLoginFlow: true);
  }

  bool _isCredentialMismatchCode(String code) =>
      code == 'wrong-password' ||
      code == 'user-not-found' ||
      code == 'invalid-credential' ||
      code == 'invalid-login-credentials';

  bool _isValidEmail(String email) {
    final emailPattern = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );
    return emailPattern.hasMatch(email);
  }

  String _friendlyResetPasswordMessage(String code) {
    final s = AppStrings.of(context);
    switch (code) {
      case 'invalid-email':
        return s.invalidEmailFormat;
      case 'too-many-requests':
        return s.tooManyRequests;
      case 'network-request-failed':
        return s.pick('No internet connection', 'ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้');
      default:
        return s.resetPasswordFailed;
    }
  }

  bool _isActionCodeSettingsConfigurationError(String code) =>
      code == 'invalid-continue-uri' ||
      code == 'missing-continue-uri' ||
      code == 'unauthorized-continue-uri';

  ActionCodeSettings? _buildResetActionCodeSettings() {
    final projectId = widget.auth.app.options.projectId;
    if (projectId.isEmpty) {
      return null;
    }

    return ActionCodeSettings(
      // Keep reset flow on trusted Firebase-hosted domain for this project.
      url: 'https://$projectId.firebaseapp.com',
      handleCodeInApp: false,
      androidPackageName: 'com.nozofibi.app',
      androidInstallApp: true,
    );
  }

  Future<void> _sendPasswordResetEmailBestEffort(String email) async {
    final localeCode = Localizations.localeOf(context).languageCode.toLowerCase();
    try {
      await widget.auth.setLanguageCode(localeCode);
    } catch (e) {
      debugPrint('Could not set reset-email language: $e');
    }

    final settings = _buildResetActionCodeSettings();
    if (settings != null) {
      try {
        await widget.auth.sendPasswordResetEmail(
          email: email,
          actionCodeSettings: settings,
        );
        return;
      } on FirebaseAuthException catch (e) {
        if (!_isActionCodeSettingsConfigurationError(e.code)) {
          rethrow;
        }
        debugPrint('Reset ActionCodeSettings fallback: ${e.code}');
      }
    }

    await widget.auth.sendPasswordResetEmail(email: email);
  }

  String _resetEmailSenderHint() {
    final projectId = widget.auth.app.options.projectId;
    if (projectId.isEmpty) {
      return 'no-reply';
    }
    return 'no-reply@$projectId.firebaseapp.com';
  }

  void _showResetPasswordSentNotice() {
    final s = AppStrings.of(context);
    final senderHint = _resetEmailSenderHint();
    final notice = '${s.resetEmailSentNotice}\n${s.resetEmailDeliverabilityTips(senderHint)}';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(notice),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 7),
      ),
    );
  }

  void _showResetEmailTips() {
    final s = AppStrings.of(context);
    final senderHint = _resetEmailSenderHint();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.mark_email_read_outlined, color: Color(0xFFA78BFA)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    s.resetEmailTipsTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              s.resetEmailTipsBody(senderHint),
              style: const TextStyle(
                height: 1.45,
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startResetCooldown() {
    _resetCooldownTimer?.cancel();
    setState(() {
      _resetCooldownSeconds = _resetCooldownDuration;
    });

    _resetCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_resetCooldownSeconds <= 1) {
        timer.cancel();
        setState(() {
          _resetCooldownSeconds = 0;
        });
        return;
      }

      setState(() {
        _resetCooldownSeconds -= 1;
      });
    });
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim().toLowerCase();
    if (!_isValidEmail(email)) {
      _showErrorSnackBar(AppStrings.of(context).fillValidEmailBeforeReset);
      return;
    }

    if (_isSendingResetEmail || _resetCooldownSeconds > 0) {
      return;
    }

    setState(() {
      _isSendingResetEmail = true;
    });

    try {
      await _sendPasswordResetEmailBestEffort(email);
      if (!mounted) {
        return;
      }
      _showResetPasswordSentNotice();
      _startResetCooldown();
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }
      if (e.code == 'user-not-found') {
        _showResetPasswordSentNotice();
        _startResetCooldown();
        return;
      }
      _showErrorSnackBar(_friendlyResetPasswordMessage(e.code));
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showErrorSnackBar(AppStrings.of(context).genericErrorTryAgain);
    } finally {
      if (mounted) {
        setState(() {
          _isSendingResetEmail = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_isSubmitting) {
      return;
    }

    if (!_isLogin && !_acceptedPolicy) {
      _showErrorSnackBar(AppStrings.of(context).acceptPolicyFirst);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        final userCredential = await widget.auth.signInWithPopup(provider);
        final canProceed = await _ensureConsentForSocialSignIn(userCredential);
        if (!canProceed) {
          return;
        }
        final user = userCredential.user;
        final name = user?.displayName?.trim().isNotEmpty == true
            ? user!.displayName!
            : (user?.email?.split('@').first ?? 'User');
        widget.onLogin?.call(name);
        return;
      }

      final googleUser = await widget.googleSignIn.signIn();
      if (googleUser == null) {
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await widget.auth.signInWithCredential(credential);
      final canProceed = await _ensureConsentForSocialSignIn(userCredential);
      if (!canProceed) {
        return;
      }
      final user = userCredential.user;
      final name = user?.displayName?.trim().isNotEmpty == true
          ? user!.displayName!
          : (user?.email?.split('@').first ??
              googleUser.email.split('@').first);
      widget.onLogin?.call(name);
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar(
        _friendlyAuthMessage(
          code: e.code,
          isLoginFlow: true,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      _showErrorSnackBar(AppStrings.of(context).googleSignInFailed);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<bool> _ensureConsentForSocialSignIn(UserCredential credential) async {
    if (PrivacyStorage.hasConsent()) {
      return true;
    }

    final accepted = await _showConsentDialog();
    if (accepted) {
      if (widget.onConsentAccepted != null) {
        await widget.onConsentAccepted!();
      } else {
        await PrivacyStorage.saveConsentAcceptedNow();
      }
      return true;
    }

    await widget.auth.signOut();
    try {
      await widget.googleSignIn.signOut();
    } catch (_) {
      // Ignore provider-specific sign-out errors.
    }
    return false;
  }

  Future<bool> _ensureConsentAfterEmailLogin() async {
    if (PrivacyStorage.hasConsent()) {
      return true;
    }

    final accepted = await _showConsentDialog();
    if (accepted) {
      if (widget.onConsentAccepted != null) {
        await widget.onConsentAccepted!();
      } else {
        await PrivacyStorage.saveConsentAcceptedNow();
      }
      return true;
    }

    await widget.auth.signOut();
    return false;
  }

  Future<bool> _showConsentDialog() async {
    final customPrompt = widget.consentPrompt;
    if (customPrompt != null) {
      return customPrompt(context);
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.of(context).consentRequired),
        content: Text(AppStrings.of(context).consentBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.of(context).decline),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppStrings.of(context).agree),
          ),
        ],
      ),
    );

    return result == true;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _friendlyAuthMessage({
    required String code,
    required bool isLoginFlow,
  }) {
    final s = AppStrings.of(context);
    switch (code) {
      case 'user-not-found':
      case 'invalid-credential':
      case 'invalid-login-credentials':
      case 'wrong-password':
        return isLoginFlow ? s.invalidCredentials : s.accountNotFound;
      case 'email-already-in-use':
        return s.emailInUse;
      case 'invalid-email':
        return s.invalidEmailFormat;
      case 'weak-password':
        return s.weakPassword;
      case 'user-disabled':
        return s.userDisabled;
      case 'too-many-requests':
        return s.tooManyRequests;
      case 'operation-not-allowed':
        return s.operationNotAllowed;
      default:
        return s.authGenericError;
    }
  }

  @override
  Widget build(BuildContext context) => Theme(
        data: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFFDFCFE),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFA78BFA),
            brightness: Brightness.light,
          ),
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFFFDFCFE),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Builder(
                      builder: (context) {
                        final s = AppStrings.of(context);
                        return Column(
                          children: [
                            Column(
                              children: [
                                SvgPicture.asset(
                                  'assets/images/light.svg',
                                  width: 120,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 12),
                                ShaderMask(
                                  shaderCallback: (bounds) => const LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Color(0xFF3B82F6),
                                      Color(0xFF9333EA),
                                    ],
                                  ).createShader(bounds),
                                  child: const Text(
                                    'NOZOFIBI',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  s.elevateFocusLife,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            Text(
                              _isLogin ? s.welcomeBack : s.createAccount,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 30,
                                    offset: const Offset(0, 20),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  if (!_isLogin) ...[
                                    _buildField(
                                      controller: _nameController,
                                      hint: s.fullNameOptional,
                                      icon: Icons.person_outline,
                                      validator: _validateName,
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                  _buildField(
                                    controller: _emailController,
                                    hint: s.emailAddress,
                                    icon: Icons.mail_outline,
                                    validator: _validateEmail,
                                    onChanged: (_) {
                                      if (_loginInlineError != null) {
                                        setState(() {
                                          _loginInlineError = null;
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  _buildField(
                                    controller: _passwordController,
                                    hint: s.password,
                                    icon: Icons.lock_outline,
                                    isPassword: true,
                                    errorText: _isLogin ? _loginInlineError : null,
                                    isPasswordVisible: _isPasswordVisible,
                                    validator: _validatePassword,
                                    onChanged: (_) {
                                      if (_loginInlineError != null) {
                                        setState(() {
                                          _loginInlineError = null;
                                        });
                                      }
                                    },
                                    onToggleVisibility: () {
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                  if (_isLogin) ...[
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextButton(
                                            onPressed: (_isSendingResetEmail ||
                                                    _resetCooldownSeconds > 0)
                                                ? null
                                                : _handleForgotPassword,
                                            child: Text(
                                              _isSendingResetEmail
                                                  ? s.sending
                                                  : _resetCooldownSeconds > 0
                                                      ? s.tryAgainInSec(_resetCooldownSeconds)
                                                      : s.forgotPassword,
                                              style: const TextStyle(
                                                color: Color(0xFFA78BFA),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: _showResetEmailTips,
                                            splashRadius: 18,
                                            icon: const Icon(
                                              Icons.info_outline_rounded,
                                              size: 18,
                                              color: Color(0xFF9CA3AF),
                                            ),
                                            tooltip: s.resetEmailHelp,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  if (!_isLogin) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2),
                                          child: SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: Checkbox(
                                              value: _acceptedPolicy,
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize.shrinkWrap,
                                              visualDensity: VisualDensity.compact,
                                              onChanged: (value) {
                                                setState(() {
                                                  _acceptedPolicy = value ?? false;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Wrap(
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            spacing: 2,
                                            runSpacing: 2,
                                            children: [
                                              Text(
                                                s.iAgreeTo,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  height: 1.3,
                                                  color: Color(0xFF374151),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () => _showPolicyDialog(
                                                  title: s.privacyPolicy,
                                                  body: AppStrings.of(context).pick(
                                                    'We collect only required account and productivity data to provide authentication, scheduling, and analytics. You can request deletion from Settings.',
                                                    'เราเก็บเฉพาะข้อมูลบัญชีและข้อมูลการใช้งานที่จำเป็นต่อการเข้าสู่ระบบ ตารางงาน และสถิติ คุณสามารถขอลบข้อมูลได้จากหน้า Settings',
                                                  ),
                                                ),
                                                child: Text(
                                                  s.privacyPolicy,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    height: 1.3,
                                                    color: Color(0xFFA78BFA),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                s.andWord,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  height: 1.3,
                                                  color: Color(0xFF374151),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () => _showPolicyDialog(
                                                  title: s.termsOfService,
                                                  body: AppStrings.of(context).pick(
                                                    'By creating an account, you agree to use this app responsibly and according to applicable laws.',
                                                    'เมื่อสร้างบัญชี คุณยอมรับการใช้งานแอปอย่างเหมาะสมและตามกฎหมายที่เกี่ยวข้อง',
                                                  ),
                                                ),
                                                child: Text(
                                                  s.termsOfService,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    height: 1.3,
                                                    color: Color(0xFFA78BFA),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                s.dot,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  height: 1.3,
                                                  color: Color(0xFF374151),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 55,
                                    child: ElevatedButton(
                                      onPressed: (_isLogin && _isLoginLocked) || _isSubmitting
                                          ? null
                                          : _submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFA78BFA),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: _isSubmitting
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.4,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : Text(
                                              (_isLogin && _isLoginLocked)
                                                  ? s.tryAgainInSec(_remainingLockSeconds)
                                                  : (_isLogin ? s.signIn : s.signUp),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 25),
                                  Text(s.orContinueWith),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: _socialButton(
                                      text: s.google,
                                      icon: _googleIcon(),
                                      onPressed: _isSubmitting ? null : _signInWithGoogle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _isLogin
                                      ? s.dontHaveAccount
                                      : s.alreadyHaveAccount,
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isLogin = !_isLogin;
                                      _loginInlineError = null;
                                      _acceptedPolicy = false;
                                      if (!_isLogin) {
                                        _resetLoginProtection();
                                      }
                                    });
                                  },
                                  child: Text(
                                    _isLogin ? s.signUp : s.signIn,
                                    style: const TextStyle(
                                      color: Color(0xFFA78BFA),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    String? errorText,
    bool isPassword = false,
    bool isPasswordVisible = false,
    ValueChanged<String>? onChanged,
    VoidCallback? onToggleVisibility,
  }) =>
      TextFormField(
        controller: controller,
        validator: validator,
        onChanged: onChanged,
        obscureText: isPassword && !isPasswordVisible,
        decoration: InputDecoration(
          hintText: hint,
          errorText: errorText,
          prefixIcon: Icon(icon, color: const Color(0xFFA78BFA)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      );

  Widget _socialButton({
    required String text,
    required Widget icon,
    required VoidCallback? onPressed,
  }) =>
      ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: Text(
          text,
          style: const TextStyle(color: Colors.black),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );

  Widget _googleIcon() => Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEA4335),
              Color(0xFFFBBC05),
              Color(0xFF34A853),
              Color(0xFF4285F4),
            ],
            stops: [0.0, 0.35, 0.65, 1.0],
          ).createShader(bounds),
          child: const Text(
            'G',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1,
            ),
          ),
        ),
      );
}
