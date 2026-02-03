/// Supported app languages
enum AppLanguage { english, thai }

extension AppLanguageExtension on AppLanguage {
  String get displayName {
    switch (this) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.thai:
        return 'ไทย';
    }
  }

  String get code {
    switch (this) {
      case AppLanguage.english:
        return 'en';
      case AppLanguage.thai:
        return 'th';
    }
  }

  String get flag {
    switch (this) {
      case AppLanguage.english:
        return '🇺🇸';
      case AppLanguage.thai:
        return '🇹🇭';
    }
  }
}

/// Localized strings for the app UI
class AppStrings {
  final AppLanguage language;

  const AppStrings(this.language);

  // App Title
  String get appTitle =>
      language == AppLanguage.thai ? 'เรซูเม่ของฉัน' : 'My Resume';

  // Home Page
  String get noResumesYet =>
      language == AppLanguage.thai ? 'ยังไม่มีเรซูเม่' : 'No resumes yet';

  String get tapToCreateFirst => language == AppLanguage.thai
      ? 'กดปุ่มด้านล่างเพื่อสร้างเรซูเม่แรกของคุณ'
      : 'Tap the button below to create your first resume';

  String get newResume =>
      language == AppLanguage.thai ? 'สร้างใหม่' : 'New Resume';

  String get myResumes =>
      language == AppLanguage.thai ? 'เรซูเม่ของฉัน' : 'My Resumes';

  String get complete => language == AppLanguage.thai ? 'สมบูรณ์' : 'complete';

  String get lastEdited =>
      language == AppLanguage.thai ? 'แก้ไขล่าสุด' : 'Last edited';

  String get today => language == AppLanguage.thai ? 'วันนี้' : 'Today';

  String get yesterday =>
      language == AppLanguage.thai ? 'เมื่อวาน' : 'Yesterday';

  String daysAgo(int days) =>
      language == AppLanguage.thai ? '$days วันที่แล้ว' : '$days days ago';

  // Actions
  String get edit => language == AppLanguage.thai ? 'แก้ไข' : 'Edit';
  String get delete => language == AppLanguage.thai ? 'ลบ' : 'Delete';
  String get duplicate => language == AppLanguage.thai ? 'คัดลอก' : 'Duplicate';
  String get share => language == AppLanguage.thai ? 'แชร์' : 'Share';
  String get preview => language == AppLanguage.thai ? 'ดูตัวอย่าง' : 'Preview';
  String get exportPdf =>
      language == AppLanguage.thai ? 'ส่งออก PDF' : 'Export PDF';

  // Confirmations
  String get confirmDelete =>
      language == AppLanguage.thai ? 'ยืนยันการลบ' : 'Confirm Delete';

  String deleteResumeConfirm(String title) => language == AppLanguage.thai
      ? 'คุณต้องการลบ "$title" หรือไม่? การดำเนินการนี้ไม่สามารถย้อนกลับได้'
      : 'Are you sure you want to delete "$title"? This action cannot be undone.';

  String get cancel => language == AppLanguage.thai ? 'ยกเลิก' : 'Cancel';

  // Settings
  String get settings => language == AppLanguage.thai ? 'ตั้งค่า' : 'Settings';
  String get languageLabel =>
      language == AppLanguage.thai ? 'ภาษา' : 'Language';
  String get theme => language == AppLanguage.thai ? 'ธีม' : 'Theme';
  String get about => language == AppLanguage.thai ? 'เกี่ยวกับ' : 'About';

  // Templates
  String get templates =>
      language == AppLanguage.thai ? 'เทมเพลต' : 'Templates';
  String get chooseTemplate =>
      language == AppLanguage.thai ? 'เลือกเทมเพลต' : 'Choose Template';

  // Messages
  String get resumeCreated => language == AppLanguage.thai
      ? 'สร้างเรซูเม่สำเร็จ'
      : 'Resume created successfully';

  String get resumeDeleted =>
      language == AppLanguage.thai ? 'ลบเรซูเม่แล้ว' : 'Resume deleted';

  String get resumeDuplicated =>
      language == AppLanguage.thai ? 'คัดลอกเรซูเม่แล้ว' : 'Resume duplicated';

  // Errors
  String get errorOccurred =>
      language == AppLanguage.thai ? 'เกิดข้อผิดพลาด' : 'An error occurred';

  String get tryAgain =>
      language == AppLanguage.thai ? 'ลองอีกครั้ง' : 'Try again';

  // Quick Actions
  String get quickStart =>
      language == AppLanguage.thai ? 'เริ่มต้นอย่างรวดเร็ว' : 'Quick Start';

  String get blankResume =>
      language == AppLanguage.thai ? 'เรซูเม่ว่าง' : 'Blank Resume';

  String get useTemplate =>
      language == AppLanguage.thai ? 'ใช้เทมเพลต' : 'Use Template';

  String get importResume =>
      language == AppLanguage.thai ? 'นำเข้าเรซูเม่' : 'Import Resume';

  // Resume Language Display
  String get resumeInEnglish =>
      language == AppLanguage.thai ? 'อังกฤษ' : 'English';

  String get resumeInThai => language == AppLanguage.thai ? 'ไทย' : 'Thai';

  // Rename Dialog
  String get renameResume =>
      language == AppLanguage.thai ? 'เปลี่ยนชื่อเรซูเม่' : 'Rename Resume';

  String get resumeName =>
      language == AppLanguage.thai ? 'ชื่อเรซูเม่' : 'Resume Name';

  String get enterResumeName =>
      language == AppLanguage.thai ? 'กรอกชื่อเรซูเม่' : 'Enter resume name';

  String get save => language == AppLanguage.thai ? 'บันทึก' : 'Save';

  // Auth
  String get signIn => language == AppLanguage.thai ? 'เข้าสู่ระบบ' : 'Sign In';

  String get signOut =>
      language == AppLanguage.thai ? 'ออกจากระบบ' : 'Sign Out';

  String get signOutConfirm => language == AppLanguage.thai
      ? 'คุณต้องการออกจากระบบหรือไม่?'
      : 'Are you sure you want to sign out?';

  String get profile => language == AppLanguage.thai ? 'โปรไฟล์' : 'Profile';

  String get guest => language == AppLanguage.thai ? 'ผู้เยี่ยมชม' : 'Guest';

  // Edit Profile Dialog
  String get editProfileName =>
      language == AppLanguage.thai ? 'แก้ไขชื่อโปรไฟล์' : 'Edit Profile Name';

  String get fullName =>
      language == AppLanguage.thai ? 'ชื่อ-นามสกุล' : 'Full Name';

  String get enterYourName =>
      language == AppLanguage.thai ? 'กรอกชื่อของคุณ' : 'Enter your name';

  // Paywall
  String get upgradeTitle =>
      language == AppLanguage.thai ? 'อัปเกรดเป็น Pro' : 'Go Pro';
  String get unlockAllFeatures => language == AppLanguage.thai
      ? 'ปลดล็อกฟีเจอร์ทั้งหมด'
      : 'Unlock All Features';
  String get unlockDescription => language == AppLanguage.thai
      ? '• เรซูเม่ไม่จำกัด\n• ซิงค์ออนไลน์ไม่จำกัด\n• เทมเพลตพรีเมียม\n• ส่งออก PDF โดยไม่มีลายน้ำ'
      : '• Unlimited Resumes\n• Unlimited Online Sync\n• Premium Templates\n• PDF Export without Watermark';

  String get restorePurchases =>
      language == AppLanguage.thai ? 'กู้คืนการซื้อ' : 'Restore Purchases';
  String get privacyPolicy =>
      language == AppLanguage.thai ? 'นโยบายความเป็นส่วนตัว' : 'Privacy Policy';
  String get termsOfUse =>
      language == AppLanguage.thai ? 'เงื่อนไขการใช้งาน' : 'Terms of Use';
  String get noOffers => language == AppLanguage.thai
      ? 'ยังไม่มีข้อเสนอในขณะนี้'
      : 'No offers available at the moment.';

  String welcomePro(String plan) => language == AppLanguage.thai
      ? 'ยินดีต้อนรับสู่ $plan!'
      : 'Welcome to $plan!';

  // Plan Comparison
  String get freePlan => language == AppLanguage.thai ? 'ฟรี' : 'Free';
  String get monthlyPlan =>
      language == AppLanguage.thai ? 'รายเดือน' : 'Monthly';

  String get maxResumesCap =>
      language == AppLanguage.thai ? 'สร้างเรซูเม่' : 'Max Resumes';
  String get onlineSync =>
      language == AppLanguage.thai ? 'ซิงค์ออนไลน์' : 'Online Sync';
  String get archives =>
      language == AppLanguage.thai ? 'สำรองข้อมูล' : 'Cloud Storage';
  String get exports =>
      language == AppLanguage.thai ? 'ส่งออก PDF' : 'PDF Exports';

  String get oneItem => language == AppLanguage.thai ? '1 รายการ' : '1 Item';
  String get twoTimes => language == AppLanguage.thai ? '2 ครั้ง' : '2 Times';
  String get threeItems =>
      language == AppLanguage.thai ? '3 รายการ' : '3 Items';
  String get unlimited =>
      language == AppLanguage.thai ? 'ไม่จำกัด' : 'Unlimited';
  String get disabled => language == AppLanguage.thai ? 'ไม่ได้' : 'Disabled';
}
