import 'package:flutter/widgets.dart';

class AppStrings {
  AppStrings._(this.isThai);

  final bool isThai;

  static AppStrings of(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    return AppStrings._(code.startsWith('th'));
  }

  String pick(String en, String th) => isThai ? th : en;

  // Common
  String get cancel => pick('Cancel', 'ยกเลิก');
  String get confirm => pick('Confirm', 'ยืนยัน');
  String get close => pick('Close', 'ปิด');
  String get save => pick('Save', 'บันทึก');
  String get delete => pick('Delete', 'ลบ');
  String get setTime => pick('Set Time', 'ตั้งเวลา');
  String get tapToChangeTime => pick('Tap to change', 'แตะเพื่อเปลี่ยนเวลา');
  String get quickPick => pick('Quick Pick', 'เลือกด่วน');
  String get settings => pick('Settings', 'การตั้งค่า');
  String get signOut => pick('Sign Out', 'ออกจากระบบ');
  String get signIn => pick('Sign In', 'เข้าสู่ระบบ');
  String get signUp => pick('Sign Up', 'สมัครสมาชิก');

  // Home
  String goodMorning(String name) =>
      pick('Good morning, $name', 'สวัสดีตอนเช้า, $name');
  String get dailyPlan => pick('DAILY PLAN', 'แผนวันนี้');
  String get readingSchedule => pick('Reading Schedule', 'ตารางการอ่าน');
  String get managePlan => pick('Manage Plan', 'จัดการแผน');
  String get wellnessMetrics => pick('Wellness Metrics', 'สรุปประจำวัน');
  String get todayLabel => pick('TODAY', 'วันนี้');
  String get streakLabel => pick('STREAK', 'ต่อเนื่อง');
  String get focus7dLabel => pick('FOCUS 7D', 'โฟกัส 7 วัน');
  String get done7dLabel => pick('DONE 7D', 'เสร็จ 7 วัน');

  // Settings
  String get preferences => pick('PREFERENCES', 'การตั้งค่า');
  String get pushNotifications => pick('Push Notifications', 'การแจ้งเตือน');
  String get notificationsEnabled => pick('Notifications enabled', 'เปิดการแจ้งเตือนแล้ว');
  String get notificationsDisabled => pick('Notifications disabled', 'ปิดการแจ้งเตือนแล้ว');
  String get reminderTime => pick('Reminder Time', 'เวลาแจ้งเตือน');
  String get testNotification => pick('Send Test Notification', 'ส่งแจ้งเตือนทดสอบ');
  String get notificationTestSent => pick('Test notification sent', 'ส่งแจ้งเตือนทดสอบแล้ว');
  String get dailyReminderTitle => pick('Time to focus', 'ถึงเวลาโฟกัสแล้ว');
  String get dailyReminderBody => pick(
        'Come back and complete your study plan today.',
        'กลับมาเคลียร์แผนการเรียนของวันนี้กัน',
      );
  String get taskStartsInTenMinutes =>
      pick('Starts in 10 minutes', 'จะเริ่มในอีก 10 นาที');
  String get darkModeBeta => pick('Dark Mode (Beta)', 'โหมดมืด (เบต้า)');
  String get language => pick('Language', 'ภาษา');
  String get english => pick('English', 'English');
  String get thai => pick('ไทย', 'ไทย');
  String get systemDefault => pick('System Default', 'ตามตั้งค่าระบบ');
  String get privacyControls => pick('PRIVACY CONTROLS', 'การควบคุมความเป็นส่วนตัว');
  String get deleteMyLocalData => pick('Delete My Local Data', 'ลบข้อมูลในเครื่อง');
  String get deleteLocalDataTitle => pick('Delete Local Data', 'ลบข้อมูลในเครื่อง');
  String get deleteLocalDataBody => pick(
        'This will erase your local tasks, focus sessions, and privacy preferences on this device.',
        'การดำเนินการนี้จะลบงาน เซสชันโฟกัส และค่าความเป็นส่วนตัวในอุปกรณ์นี้',
      );
  String get deleteAccount => pick('Delete Account', 'ลบบัญชี');
  String get deleteAccountBody => pick(
        'This will remove your account and local app data. This action cannot be undone.',
        'การดำเนินการนี้จะลบบัญชีและข้อมูลแอปของคุณแบบถาวร ไม่สามารถย้อนกลับได้',
      );
  String get legal => pick('LEGAL', 'กฎหมาย');
  String get termsOfService => pick('Terms of Service', 'ข้อกำหนดการใช้งาน');
  String get privacyPolicy => pick('Privacy Policy', 'นโยบายความเป็นส่วนตัว');
  String get termsText => pick(
        'By using Nozofibi, you agree to use the app responsibly and in compliance with applicable laws.\n\nYour account data and productivity records are provided for personal use only.\n\nWe may update features and terms from time to time to improve the experience.',
        'เมื่อใช้งาน Nozofibi คุณยอมรับการใช้งานอย่างเหมาะสมและเป็นไปตามกฎหมายที่เกี่ยวข้อง\n\nข้อมูลบัญชีและบันทึกการใช้งานมีไว้เพื่อการใช้งานส่วนบุคคลเท่านั้น\n\nเราอาจปรับปรุงฟีเจอร์และข้อกำหนดเป็นระยะเพื่อพัฒนาประสบการณ์การใช้งาน',
      );
  String get privacyText => pick(
        'Nozofibi stores your app data to provide scheduling, timer tracking, and analytics features.\n\nWe do not sell personal information.\n\nYou can manage your account information and app usage data from the settings and profile sections.',
        'Nozofibi จัดเก็บข้อมูลที่จำเป็นเพื่อให้บริการตารางงาน จับเวลา และสถิติการใช้งาน\n\nเราไม่ขายข้อมูลส่วนบุคคล\n\nคุณสามารถจัดการข้อมูลบัญชีและข้อมูลการใช้งานได้จากหน้า Settings และ Profile',
      );

  // Profile / Edit profile
  String get systemSettings => pick('System Settings', 'การตั้งค่าระบบ');
  String get editProfile => pick('Edit Profile', 'แก้ไขโปรไฟล์');
  String get accountSettings => pick('Account Settings', 'ตั้งค่าบัญชี');
  String get darkMode => pick('Dark Mode', 'โหมดมืด');
  String currentStreak(int days) => pick('Current streak: $days day(s)', 'สตรีคปัจจุบัน: $days วัน');
  String get changeProfilePicture => pick('Change Profile Picture', 'เปลี่ยนรูปโปรไฟล์');
  String get fullName => pick('Full Name', 'ชื่อ-นามสกุล');
  String get saveChanges => pick('Save Changes', 'บันทึกการเปลี่ยนแปลง');
  String errorSavingProfile(String e) =>
      pick('Error saving profile: $e', 'บันทึกโปรไฟล์ไม่สำเร็จ: $e');

  // Schedule
  String get schedule => pick('Schedule', 'ตารางงาน');
  String get noPlansToday => pick('No plans for today', 'วันนี้ยังไม่มีแผน');
  String get addNewPlan => pick('Add New Plan', 'เพิ่มแผนใหม่');
  String get whatPlanning => pick('What are you planning?', 'วันนี้คุณวางแผนอะไรไว้');
  String get planType => pick('Plan Type', 'ประเภทแผน');
  String get typeGeneral => pick('General', 'ทั่วไป');
  String get typeReading => pick('Reading', 'อ่านหนังสือ');
  String get typeExercise => pick('Exercise', 'ออกกำลังกาย');
  String get typeHomework => pick('Homework', 'ทำการบ้าน');
  String get savePlan => pick('Save Plan', 'บันทึกแผน');

  // Timer
  String get focusTimer => pick('Focus Timer', 'โหมดโฟกัส');
  String get pomodoroProtocol => pick('Pomodoro Protocol', 'โหมด Pomodoro');
  String get sessionSaved => pick('Session Saved', 'บันทึกเซสชันแล้ว');
  String get focusSession => pick('Focus Session', 'เซสชันโฟกัส');
  String get sessionName => pick('Session Name', 'ชื่อเซสชัน');
  String get enterSessionName => pick('Enter session name', 'กรอกชื่อเซสชัน');
  String get custom => pick('Custom', 'กำหนดเอง');
  String get customTime => pick('Custom Time', 'ตั้งเวลาเอง');
  String get hours => pick('Hours', 'ชั่วโมง');
  String get minutes => pick('Minutes', 'นาที');
  String get seconds => pick('Seconds', 'วินาที');
  String get set => pick('Set', 'ตั้งค่า');

  // Bottom nav
  String get navHome => pick('Home', 'หน้าแรก');
  String get navTimer => pick('Timer', 'โฟกัส');
  String get navSchedule => pick('Schedule', 'ตาราง');
  String get navInsights => pick('Insights', 'สถิติ');
  String get navProfile => pick('Profile', 'โปรไฟล์');

  // Analytics
  String get insights => pick('Insights', 'ภาพรวม');
  String get weeklySummary => pick('WEEKLY SUMMARY', 'สรุปรายสัปดาห์');
  String totalFocusThisWeek(String v) => pick('Total Focus This Week: $v', 'โฟกัสรวมสัปดาห์นี้: $v');
  String averagePerDay(String v) => pick('Average Per Day: $v', 'เฉลี่ยต่อวัน: $v');
  String bestDay(String v) => pick('Best Day: $v', 'วันที่ดีที่สุด: $v');
  String get weeklyFocus => pick('WEEKLY FOCUS', 'โฟกัสรายสัปดาห์');
  String get recentSessions => pick('RECENT SESSIONS', 'เซสชันล่าสุด');
  String get noSavedSessions => pick('No saved sessions yet', 'ยังไม่มีเซสชันที่บันทึก');
  String get previous => pick('← Previous', '← ก่อนหน้า');
  String get next => pick('Next →', 'ถัดไป →');
  String page(int p) => pick('Page $p', 'หน้า $p');

  // Login
  String get elevateFocusLife => pick('Elevate your focus & life', 'ยกระดับโฟกัสและชีวิตของคุณ');
  String get welcomeBack => pick('Welcome Back', 'ยินดีต้อนรับกลับ');
  String get createAccount => pick('Create Account', 'สร้างบัญชี');
  String get fullNameOptional => pick('Full Name (Optional)', 'ชื่อ-นามสกุล (ไม่บังคับ)');
  String get emailAddress => pick('Email Address', 'อีเมล');
  String get password => pick('Password', 'รหัสผ่าน');
  String get forgotPassword => pick('Forgot Password?', 'ลืมรหัสผ่าน?');
  String get resetEmailHelp => pick('Help', 'วิธีค้นหาเมล');
  String get sending => pick('Sending...', 'กำลังส่ง...');
  String tryAgainInSec(int sec) => pick('Try again in ${sec}s', 'ลองใหม่ในอีก $sec วินาที');
  String get resetHintSpam => pick(
        'If not found, please check your Spam/Junk folder',
        'หากไม่พบอีเมล โปรดตรวจสอบกล่อง Spam/Junk',
      );
  String get resetEmailTipsTitle => pick('Find reset email faster', 'ค้นหาอีเมลรีเซ็ตให้เจอเร็วขึ้น');
  String resetEmailTipsBody(String senderHint) => pick(
        '1) Search for "$senderHint" in your inbox.\n'
        '2) Check Spam/Junk and Promotions tabs.\n'
        '3) Add the sender to contacts and try again after 1-3 minutes.',
        '1) ค้นหาคำว่า "$senderHint" ในกล่องจดหมาย\n'
        '2) ตรวจสอบโฟลเดอร์ Spam/Junk และแท็บโปรโมชัน\n'
        '3) เพิ่มผู้ส่งเป็นรายชื่อติดต่อ แล้วลองใหม่อีกครั้งใน 1-3 นาที',
      );
  String get orContinueWith => pick('OR CONTINUE WITH', 'หรือดำเนินการต่อด้วย');
  String get google => 'Google';
  String get dontHaveAccount => pick("Don't have an account?", 'ยังไม่มีบัญชีใช่ไหม?');
  String get alreadyHaveAccount => pick('Already have an account?', 'มีบัญชีอยู่แล้วใช่ไหม?');
  String get iAgreeTo => pick('I agree to the ', 'ฉันยอมรับ');
  String get andWord => pick(' and ', ' และ ');
  String get dot => '.';

  String get consentRequired => pick('Consent Required', 'ต้องยืนยันความยินยอม');
  String get consentBody => pick(
        'Before continuing, please confirm that you agree to the Privacy Policy and Terms of Service.',
        'ก่อนดำเนินการต่อ โปรดยืนยันว่าคุณยอมรับนโยบายความเป็นส่วนตัวและข้อกำหนดการใช้งาน',
      );
  String get decline => pick('Decline', 'ไม่ยอมรับ');
  String get agree => pick('Agree', 'ยอมรับ');

  String get authFailedTryAgain => pick('Authentication failed. Please try again.', 'ยืนยันตัวตนไม่สำเร็จ กรุณาลองใหม่');
  String get googleSignInFailed => pick('Google Sign-In failed. Please try again.', 'เข้าสู่ระบบด้วย Google ไม่สำเร็จ กรุณาลองใหม่');
  String get acceptPolicyFirst => pick('Please accept Privacy Policy and Terms first.', 'โปรดยอมรับนโยบายความเป็นส่วนตัวและข้อกำหนดก่อน');

  String get nameAtLeast2 => pick('Name must be at least 2 characters', 'ชื่อต้องมีอย่างน้อย 2 ตัวอักษร');
  String get nameMax50 => pick('Name must be 50 characters or less', 'ชื่อต้องยาวไม่เกิน 50 ตัวอักษร');
  String get emailRequired => pick('Email is required', 'กรุณากรอกอีเมล');
  String get enterValidEmail => pick('Enter valid email', 'กรุณากรอกอีเมลให้ถูกต้อง');
  String get passwordRequired => pick('Password is required', 'กรุณากรอกรหัสผ่าน');
  String get min6Chars => pick('Minimum 6 characters', 'อย่างน้อย 6 ตัวอักษร');
  String get min8Chars => pick('Minimum 8 characters', 'อย่างน้อย 8 ตัวอักษร');
  String get needUppercase => pick('Use at least 1 uppercase letter', 'ต้องมีอักษรพิมพ์ใหญ่อย่างน้อย 1 ตัว');
  String get needLowercase => pick('Use at least 1 lowercase letter', 'ต้องมีอักษรพิมพ์เล็กอย่างน้อย 1 ตัว');
  String get needNumber => pick('Use at least 1 number', 'ต้องมีตัวเลขอย่างน้อย 1 ตัว');

  String get invalidCredentials => pick('Incorrect email or password', 'อีเมลหรือรหัสผ่านไม่ถูกต้อง');
  String get accountNotFound => pick('Account not found', 'ไม่พบบัญชีผู้ใช้');
  String get emailInUse => pick('This email is already in use. Please sign in.', 'อีเมลนี้ถูกใช้งานแล้ว กรุณาเข้าสู่ระบบ');
  String get invalidEmailFormat => pick('Invalid email format', 'รูปแบบอีเมลไม่ถูกต้อง');
  String get weakPassword => pick('Password is too weak. Please use a stronger password.', 'รหัสผ่านอ่อนเกินไป กรุณาใช้รหัสผ่านที่ปลอดภัยขึ้น');
  String get userDisabled => pick('This account has been disabled', 'บัญชีนี้ถูกระงับการใช้งาน');
  String get tooManyRequests => pick('Too many attempts. Please try again later.', 'พยายามหลายครั้งเกินไป กรุณาลองใหม่ภายหลัง');
  String get operationNotAllowed => pick('This sign-in method is not enabled in Firebase Console', 'ยังไม่ได้เปิดวิธีการเข้าสู่ระบบนี้ใน Firebase Console');
  String get authGenericError => pick('Authentication error. Please try again.', 'เกิดข้อผิดพลาดในการยืนยันตัวตน กรุณาลองใหม่');

  String get resetEmailSentNotice => pick(
        'If this email exists in our system, we will send a reset link. Please also check your Spam/Junk folder.',
        'หากอีเมลนี้มีบัญชีอยู่ในระบบ เราจะส่งลิงก์รีเซ็ตรหัสผ่านให้ โปรดตรวจสอบกล่อง Spam/Junk ด้วย',
      );
  String resetEmailDeliverabilityTips(String senderHint) => pick(
        'Tip: search for "$senderHint", add the sender to your contacts, and wait 1-3 minutes for delivery.',
        'คำแนะนำ: ค้นหาคำว่า "$senderHint" เพิ่มผู้ส่งในรายชื่อติดต่อ และรอการส่ง 1-3 นาที',
      );
  String get fillValidEmailBeforeReset => pick(
        'Please enter a valid email in the Email field first.',
        'กรุณากรอกอีเมลในช่อง Email ให้ถูกต้องก่อน',
      );
  String get genericErrorTryAgain => pick('Something went wrong. Please try again.', 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง');
  String get resetPasswordFailed => pick('Failed to send reset password link. Please try again.', 'ส่งลิงก์รีเซ็ตรหัสผ่านไม่สำเร็จ กรุณาลองใหม่อีกครั้ง');

  // Main navigation account deletion flow
  String get allLocalDataDeleted => pick('All local data deleted.', 'ลบข้อมูลในเครื่องทั้งหมดแล้ว');
  String get deleteAccountTitle => pick('Delete Account', 'ลบบัญชี');
  String get deleteAccountConfirmBody => pick(
        'This will permanently delete your account and all associated data. This action cannot be undone.\n\nAre you sure?',
        'การดำเนินการนี้จะลบบัญชีและข้อมูลทั้งหมดแบบถาวร และไม่สามารถย้อนกลับได้\n\nคุณแน่ใจหรือไม่?',
      );
  String get deletingAccount => pick('Deleting account...', 'กำลังลบบัญชี...');
  String get accountDeletedThanks => pick('Account deleted. Thank you for using Nozofibi.', 'ลบบัญชีเรียบร้อยแล้ว ขอบคุณที่ใช้งาน Nozofibi');
  String get accountDeletionFailed => pick('Account deletion failed', 'ลบบัญชีไม่สำเร็จ');
  String errorDeletingAccount(String e) => pick('Error deleting account: $e', 'เกิดข้อผิดพลาดขณะลบบัญชี: $e');
  String errorGeneric(String e) => pick('Error: $e', 'เกิดข้อผิดพลาด: $e');
  String get signInRequired => pick('Sign in required', 'ต้องเข้าสู่ระบบอีกครั้ง');
  String get signInRequiredBody => pick(
        'For security, please sign in again before deleting your account.',
        'เพื่อความปลอดภัย โปรดเข้าสู่ระบบใหม่ก่อนลบบัญชี',
      );
  String get signOutNow => pick('Sign out now', 'ออกจากระบบตอนนี้');
  String get savedLocallySyncFailed => pick(
        'Saved locally, but failed to sync profile name.',
        'บันทึกในเครื่องแล้ว แต่ซิงก์ชื่อโปรไฟล์ไม่สำเร็จ',
      );
}
