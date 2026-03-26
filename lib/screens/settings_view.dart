import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/soft_background.dart';
import '../widgets/roller_time_picker.dart';
import '../l10n/app_strings.dart';
import '../data/language_preference_storage.dart';
import '../data/notification_preference_storage.dart';
import '../services/notification_service.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({
    super.key,
    required this.onBack,
    required this.onThemeChanged,
    required this.onDeleteMyData,
    required this.onDeleteAccount,
    required this.onLanguageChanged,
  });

  final VoidCallback onBack;
  final Function(bool) onThemeChanged;
  final Function(String) onLanguageChanged;
  final Future<void> Function() onDeleteMyData;
  final Future<void> Function() onDeleteAccount;

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _notifications = true;
  late String _selectedLanguage;
  late TimeOfDay _reminderTime;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = LanguagePreferenceStorage.getLanguage();
    _notifications = NotificationPreferenceStorage.getEnabled();
    final savedReminder = NotificationPreferenceStorage.getReminderTime();
    _reminderTime = TimeOfDay(
      hour: savedReminder.hour,
      minute: savedReminder.minute,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppTheme.creamBackground,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(AppStrings.of(context).settings, style: AppTheme.h2),
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              final navigator = Navigator.of(context);
              if (navigator.canPop()) {
                navigator.pop();
                return;
              }
              widget.onBack();
            },
          ),
        ),
        body: SoftBackground(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
            children: [
              
              _section(AppStrings.of(context).preferences),
              _switchTile(
                AppStrings.of(context).pushNotifications,
                _notifications,
                _onNotificationsChanged,
              ),
              _reminderTimeCard(context),
              _tile(
                AppStrings.of(context).testNotification,
                tap: _sendTestNotification,
              ),
              _switchTile(
                AppStrings.of(context).darkModeBeta,
                Theme.of(context).brightness == Brightness.dark,
                widget.onThemeChanged,
              ),
              _languageTile(context),
              const SizedBox(height: 32),
              _section(AppStrings.of(context).privacyControls),
              _tile(
                AppStrings.of(context).deleteMyLocalData,
                tap: () => _confirmAndRun(
                  title: AppStrings.of(context).deleteLocalDataTitle,
                  body: AppStrings.of(context).deleteLocalDataBody,
                  action: widget.onDeleteMyData,
                ),
              ),
              _tile(
                AppStrings.of(context).deleteAccount,
                tap: () => _confirmAndRun(
                  title: AppStrings.of(context).deleteAccount,
                  body: AppStrings.of(context).deleteAccountBody,
                  action: widget.onDeleteAccount,
                  destructive: true,
                ),
              ),
              const SizedBox(height: 32),
              _section(AppStrings.of(context).legal),
              _tile(
                AppStrings.of(context).termsOfService,
                tap: () => _showLegalDialog(
                  title: AppStrings.of(context).termsOfService,
                  body: AppStrings.of(context).termsText,
                ),
              ),
              _tile(
                AppStrings.of(context).privacyPolicy,
                tap: () => _showLegalDialog(
                  title: AppStrings.of(context).privacyPolicy,
                  body: AppStrings.of(context).privacyText,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _section(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 4),
        child: Text(t, style: AppTheme.caption),
      );

  Widget _switchTile(String t, bool v, Function(bool) c) => ListTile(
        title: Text(t, style: AppTheme.bodyBold),
        trailing: Switch(
          value: v,
          onChanged: c,
          activeThumbColor: AppTheme.primary,
        ),
      );

  Widget _tile(String t, {VoidCallback? tap}) => ListTile(
        title: Text(t, style: AppTheme.bodyBold),
        trailing: const Icon(Icons.chevron_right),
        onTap: tap,
      );

  Widget _reminderTimeCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(AppStrings.of(context).reminderTime, style: AppTheme.caption),
        ),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _pickReminderTime,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.alarm_rounded),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatReminderTime(context),
                        style: AppTheme.bodyBold,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppStrings.of(context).tapToChangeTime,
                        style: AppTheme.caption,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.edit_rounded, size: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final preset in const [
              TimeOfDay(hour: 9, minute: 0),
              TimeOfDay(hour: 18, minute: 0),
              TimeOfDay(hour: 21, minute: 0),
            ])
              ChoiceChip(
                label: Text(MaterialLocalizations.of(context).formatTimeOfDay(preset)),
                selected: preset.hour == _reminderTime.hour &&
                    preset.minute == _reminderTime.minute,
                onSelected: (_) => _setReminderTime(preset),
              ),
          ],
        ),
      ],
    );
  }

  Widget _languageTile(BuildContext context) {
    final s = AppStrings.of(context);
    return ListTile(
      title: Text(s.language, style: AppTheme.bodyBold),
      trailing: DropdownButton<String>(
        value: _selectedLanguage,
        underline: SizedBox(),
        items: [
          DropdownMenuItem(
            value: 'en',
            child: Text(s.english),
          ),
          DropdownMenuItem(
            value: 'th',
            child: Text(s.thai),
          ),
        ],
        onChanged: (value) {
          if (value != null && value != _selectedLanguage) {
            setState(() {
              _selectedLanguage = value;
            });
            widget.onLanguageChanged(value);
          }
        },
      ),
    );
  }

  Future<void> _onNotificationsChanged(bool enabled) async {
    final s = AppStrings.of(context);

    if (enabled) {
      final granted = await NotificationService.requestPermissionIfNeeded();
      if (!granted) {
        if (!mounted) return;
        setState(() {
          _notifications = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.notificationsDisabled)),
        );
        await NotificationPreferenceStorage.setEnabled(false);
        return;
      }

      try {
        await NotificationService.scheduleDailyReminder(
          title: s.dailyReminderTitle,
          body: s.dailyReminderBody,
          hour: _reminderTime.hour,
          minute: _reminderTime.minute,
        );
        await NotificationPreferenceStorage.setEnabled(true);
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _notifications = false;
        });
        await NotificationPreferenceStorage.setEnabled(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.notificationsDisabled)),
        );
        return;
      }

      if (!mounted) return;
      setState(() {
        _notifications = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.notificationsEnabled)),
      );
      return;
    }

    await NotificationService.cancelDailyReminder();
    await NotificationPreferenceStorage.setEnabled(false);

    if (!mounted) return;
    setState(() {
      _notifications = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s.notificationsDisabled)),
    );
  }

  String _formatReminderTime(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    return localizations.formatTimeOfDay(_reminderTime);
  }

  Future<void> _pickReminderTime() async {
    final picked = await showRollerTimePicker(
      context: context,
      initialTime: _reminderTime,
    );

    if (picked == null || !mounted) {
      return;
    }

    await _setReminderTime(picked);
  }

  Future<void> _setReminderTime(TimeOfDay picked) async {
    if (!mounted) {
      return;
    }

    setState(() {
      _reminderTime = picked;
    });

    await NotificationPreferenceStorage.setReminderTime(
      hour: picked.hour,
      minute: picked.minute,
    );

    if (_notifications) {
      final s = AppStrings.of(context);
      await NotificationService.scheduleDailyReminder(
        title: s.dailyReminderTitle,
        body: s.dailyReminderBody,
        hour: picked.hour,
        minute: picked.minute,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.notificationsEnabled)),
      );
    }
  }

  Future<void> _sendTestNotification() async {
    final s = AppStrings.of(context);
    await NotificationService.showInstantNotification(
      title: s.dailyReminderTitle,
      body: s.dailyReminderBody,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s.notificationTestSent)),
    );
  }

  void _showLegalDialog({
    required String title,
    required String body,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(body),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.of(context).close),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmAndRun({
    required String title,
    required String body,
    required Future<void> Function() action,
    bool destructive = false,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.of(context).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: destructive
                ? TextButton.styleFrom(foregroundColor: Colors.red)
                : null,
            child: Text(AppStrings.of(context).confirm),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await action();
  }
}