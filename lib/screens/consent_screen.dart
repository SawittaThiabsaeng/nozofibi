import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/account_service.dart';
import '../services/notification_service.dart';

class ConsentScreen extends StatefulWidget {
  final User user;
  final VoidCallback? onDone;

  const ConsentScreen({
    super.key,
    required this.user,
    this.onDone,
  });

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _accepted = false;
  bool _loading = false;

  Future<void> _continue() async {
    if (_loading) return;

    if (!_accepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please accept the terms")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await AccountService.submitConsent(
        uid: widget.user.uid,
        accepted: _accepted,
      );

      await NotificationService.requestPermissionIfNeeded();

      widget.onDone?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Unable to save consent. Please try again."),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _decline() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  // ✅ popup แสดงเนื้อหา Privacy Policy หรือ Terms of Service
  void _showPolicyDialog(BuildContext context, {required bool isPrivacy}) {
    showDialog<void>(
      context: context,
      useRootNavigator: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isPrivacy ? "Privacy Policy" : "Terms of Service",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isPrivacy
                    ? "Privacy Policy for Nozofibi"
                    : "Terms of Service for Nozofibi",
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 4),
              const Text(
                "Last updated: April 9, 2026",
                style: TextStyle(color: Colors.black45, fontSize: 12),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 400,
                child: SingleChildScrollView(
                  child: Text(
                    isPrivacy ? _privacyPolicyText : _termsOfServiceText,
                    style: const TextStyle(height: 1.6, fontSize: 13.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Close",
                    style: TextStyle(color: Color(0xFFA78BFA)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFCFE),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 18,
                      color: Colors.black12,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      size: 60,
                      color: Color(0xFFA78BFA),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      "Privacy Consent",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      "We collect only necessary account and productivity data "
                      "to provide authentication, reminders, and analytics.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        height: 1.5,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ✅ checkbox + ลิงก์กดได้
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _accepted,
                          onChanged: (v) =>
                              setState(() => _accepted = v ?? false),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Wrap(
                              children: [
                                const Text("I agree to the "),
                                TextButton(
                                  onPressed: () => _showPolicyDialog(
                                    context,
                                    isPrivacy: true,
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    "Privacy Policy",
                                    style: TextStyle(
                                      color: Color(0xFFA78BFA),
                                      decoration: TextDecoration.underline,
                                      decorationColor: Color(0xFFA78BFA),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const Text(" and "),
                                TextButton(
                                  onPressed: () => _showPolicyDialog(
                                    context,
                                    isPrivacy: false,
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    "Terms of Service",
                                    style: TextStyle(
                                      color: Color(0xFFA78BFA),
                                      decoration: TextDecoration.underline,
                                      decorationColor: Color(0xFFA78BFA),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const Text("."),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed:
                            (_accepted && !_loading) ? _continue : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA78BFA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text("Continue"),
                      ),
                    ),

                    TextButton(
                      onPressed: _decline,
                      child: const Text("Decline"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ✅ เนื้อหา Privacy Policy
const String _privacyPolicyText = """
1. Information We Collect
We may collect account details (name, email, login identifiers) and app data (tasks, reminders, schedule, settings).

2. How We Process Information
We process data to provide app features, authentication, sync, security, troubleshooting, and service improvement.

3. Legal Bases
Where required, we rely on consent, contract performance, legitimate interests, and legal obligations.

4. Sharing of Personal Information
We may share data with service providers necessary for operation (for example Firebase services).

5. Social Logins
If you use Google sign-in, we receive limited profile/account data for authentication.

6. International Transfers
Your data may be processed in countries outside your own depending on provider infrastructure.

7. Data Retention
We retain data only as long as needed for service operation, legal compliance, and security.

8. Data Security
We apply appropriate technical and organizational safeguards, but no system is 100% secure.

9. Your Privacy Rights
You may request access, correction, deletion, or restriction as permitted by applicable law.

10. Do-Not-Track
Because no unified DNT standard exists, we currently do not respond to DNT browser signals.

11. US State Privacy Rights
Residents of certain US states may have additional rights under applicable laws.

12. Policy Updates
We may update this notice from time to time and show the latest updated date in the policy.

13. Contact
Email: nozofibi@gmail.com

14. Review, Update, or Delete Data
You can request data review/update/deletion via in-app controls or email.
Website: https://nozofibi.web.app/privacy
""";

// ✅ เนื้อหา Terms of Service
const String _termsOfServiceText = """
1. Our Services
Nozofibi provides focus, scheduling, reminders, and mood-support features for personal use.

2. Intellectual Property Rights
All app content, code, design, and trademarks are owned by or licensed to Nozofibi.

3. User Representations
You confirm you can legally agree to these terms and will provide accurate account information.

4. Prohibited Activities
Do not misuse the app, access systems without authorization, upload harmful content, or violate laws.

5. User Generated Contributions
You are responsible for data/content you submit and must have rights to submit it.

6. Contribution License
You allow us to process submitted data as needed to operate and improve the Services.

7. Services Management
We may monitor misuse, remove violating content, and take actions to protect security.

8. Term and Termination
These terms apply while you use the app. Access may be suspended or terminated for violations.

9. Modifications and Interruptions
Features may change, pause, or be discontinued. Availability is not guaranteed at all times.

10. Governing Law
These terms are governed by Thai law unless mandatory local law applies.

11. Dispute Resolution
Please contact us first for good-faith resolution before formal legal action.

12. Corrections
We may correct errors, omissions, or outdated information without prior notice.

13. Disclaimer
Services are provided "as is" and "as available" without warranties.

14. Limitation of Liability
To the maximum extent allowed by law, we are not liable for indirect or consequential damages.

15. Indemnification
You agree to indemnify us for claims arising from your misuse or violation of these terms.

16. User Data
You are responsible for data you transmit; we use reasonable safeguards and backups.

17. Electronic Communications
You consent to receiving notices and communications electronically.

18. Miscellaneous
If part of these terms is invalid, remaining sections stay in effect.

19. Contact Us
Email: nozofibi@gmail.com
Website: https://nozofibi.web.app/terms
""";
