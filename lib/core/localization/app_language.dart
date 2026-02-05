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
      language == AppLanguage.thai ? 'เรซูเม่ดี' : 'ResumeDee';

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
  String get confirm => language == AppLanguage.thai ? 'ยืนยัน' : 'Confirm';

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

  // Onboarding
  String get onboardingTitle1 => language == AppLanguage.thai
      ? 'สร้างเรซูเม่แบบมืออาชีพ'
      : 'Create Professional Resumes';
  String get onboardingDesc1 => language == AppLanguage.thai
      ? 'สร้างเรื่องราวอาชีพของคุณ ทีละส่วน ในเวลาเพียงไม่กี่นาที'
      : 'Build your career story, block by block, in just a few minutes.';

  String get onboardingTitle2 => language == AppLanguage.thai
      ? 'ผู้ช่วยเขียนอัจฉริยะ AI'
      : 'AI-Powered Writing Assistant';
  String get onboardingDesc2 => language == AppLanguage.thai
      ? 'ใช้ AI ของเราช่วยขัดเกลาข้อความให้โดดเด่นและน่าสนใจ'
      : 'Use our Gemini-powered AI to polish your text and make it shine.';

  String get onboardingTitle3 => language == AppLanguage.thai
      ? 'ส่งออก PDF & สมัครงาน'
      : 'Export to PDF & Apply';
  String get onboardingDesc3 => language == AppLanguage.thai
      ? 'ส่งออกไฟล์ PDF คุณภาพสูงและสมัครงานในฝันได้ทันที'
      : 'Export high-quality PDFs and apply to your dream jobs instantly.';

  String get next => language == AppLanguage.thai ? 'ถัดไป' : 'Next';
  String get getStarted =>
      language == AppLanguage.thai ? 'เริ่มต้นใช้งาน' : 'Get Started';

  // Dashboard Menu
  String get dashboard =>
      language == AppLanguage.thai ? 'หน้าหลัก' : 'Dashboard';
  String get menuMyResumes =>
      language == AppLanguage.thai ? 'เรซูเม่ของฉัน' : 'My Resumes';
  String get menuMyResumesDesc => language == AppLanguage.thai
      ? 'ดูและจัดการเรซูเม่ทั้งหมด'
      : 'View and manage all your resumes';
  String get menuCoverLetter =>
      language == AppLanguage.thai ? 'เขียนจดหมายสมัครงาน' : 'Cover Letter';
  String get menuCoverLetterDesc => language == AppLanguage.thai
      ? 'สร้างจดหมายสมัครงาน ด้วย AI'
      : 'Generate AI-powered cover letters';
  String get menuAtsCheck =>
      language == AppLanguage.thai ? 'ฝึกสัมภาษณ์ AI' : 'AI Interview Coach';
  String get menuAtsCheckDesc => language == AppLanguage.thai
      ? 'ฝึกซ้อมสัมภาษณ์งานกับ AI'
      : 'Practice job interviews with AI';
  String get menuSettings =>
      language == AppLanguage.thai ? 'ตั้งค่า' : 'Settings';
  String get menuSettingsDesc => language == AppLanguage.thai
      ? 'จัดการบัญชีและการตั้งค่า'
      : 'Manage account and preferences';
  String get comingSoon =>
      language == AppLanguage.thai ? 'เร็วๆ นี้' : 'Coming Soon';

  // Settings Page
  String get subscription =>
      language == AppLanguage.thai ? 'การสมัครสมาชิก' : 'Subscription';
  String get expiresOn =>
      language == AppLanguage.thai ? 'หมดอายุ' : 'Expires on';
  String get lifetimeAccess =>
      language == AppLanguage.thai ? 'ใช้งานได้ตลอดชีพ' : 'Lifetime Access';
  String get upgradeForMore => language == AppLanguage.thai
      ? 'อัปเกรดเพื่อปลดล็อกฟีเจอร์เพิ่มเติม'
      : 'Upgrade to unlock more features';
  String get upgradeToPro =>
      language == AppLanguage.thai ? 'อัปเกรดเป็น Pro' : 'Upgrade to Pro';

  // Interview Coach
  String get interviewCoachTitle => language == AppLanguage.thai
      ? 'ฝึกซ้อมสัมภาษณ์งานกับ AI'
      : 'Practice Job Interviews with AI';
  String get interviewCoachDesc => language == AppLanguage.thai
      ? 'AI จะถามคำถามสัมภาษณ์และให้ feedback เพื่อช่วยคุณเตรียมตัว'
      : 'AI will ask interview questions and provide feedback to help you prepare';
  String get jobPosition =>
      language == AppLanguage.thai ? 'ตำแหน่งงาน' : 'Job Position';
  String get jobPositionHint => language == AppLanguage.thai
      ? 'เช่น Software Engineer, Marketing Manager'
      : 'e.g., Software Engineer, Marketing Manager';
  String get startInterview =>
      language == AppLanguage.thai ? 'เริ่มสัมภาษณ์' : 'Start Interview';
  String interviewWelcome(String position) => language == AppLanguage.thai
      ? 'ยินดีต้อนรับสู่การฝึกสัมภาษณ์สำหรับตำแหน่ง $position! ผมจะถามคำถามและให้ feedback หลังจากคุณตอบ'
      : 'Welcome to the interview practice for $position! I\'ll ask questions and provide feedback after your answers.';
  String get typeYourAnswer => language == AppLanguage.thai
      ? 'พิมพ์คำตอบของคุณ...'
      : 'Type your answer...';
  String get newSession =>
      language == AppLanguage.thai ? 'เริ่มใหม่' : 'New Session';
  String get newSessionConfirm => language == AppLanguage.thai
      ? 'ต้องการเริ่มการสัมภาษณ์ใหม่หรือไม่?'
      : 'Do you want to start a new interview session?';
  String get practiceLanguage =>
      language == AppLanguage.thai ? 'ภาษาที่ใช้ในการฝึก' : 'Practice Language';
  String get questionLabel =>
      language == AppLanguage.thai ? 'คำถาม' : 'Question';
  String get feedbackLabel =>
      language == AppLanguage.thai ? 'ความคิดเห็น' : 'Feedback';
  String get answerHint =>
      language == AppLanguage.thai ? 'แนะนำวิธีตอบ' : 'Answer Tips';
  String get gotIt => language == AppLanguage.thai ? 'เข้าใจแล้ว' : 'Got it';
  String get getHintButton =>
      language == AppLanguage.thai ? 'ขอคำแนะนำ' : 'Get Hint';

  // Salary Estimator
  String get salaryEstimator =>
      language == AppLanguage.thai ? 'ประเมินเงินเดือน' : 'Salary Estimator';
  String get salaryEstimatorDesc => language == AppLanguage.thai
      ? 'เช็คมูลค่าตลาดของคุณ'
      : 'Estimate your market value';
  String get yearsOfExperience =>
      language == AppLanguage.thai ? 'ประสบการณ์ (ปี)' : 'Years of Experience';
  String get location => language == AppLanguage.thai ? 'สถานที่' : 'Location';
  String get locationHint => language == AppLanguage.thai
      ? 'เช่น กรุงเทพฯ, เชียงใหม่'
      : 'e.g., Bangkok, Chiang Mai';
  String get estimateSalary =>
      language == AppLanguage.thai ? 'ประเมินเงินเดือน' : 'Estimate Salary';
  String get estimatedSalaryRange => language == AppLanguage.thai
      ? 'ช่วงเงินเดือนที่ประเมิน'
      : 'Estimated Salary Range';
  String get keyFactors =>
      language == AppLanguage.thai ? 'ปัจจัยสำคัญ' : 'Key Factors';
  String get required =>
      language == AppLanguage.thai ? 'จำเป็นต้องระบุ' : 'Required';
  String get month => language == AppLanguage.thai ? 'เดือน' : 'month';

  // Dream Job Roadmap
  String get dreamJobRoadmap =>
      language == AppLanguage.thai ? 'เส้นทางสู่งานในฝัน' : 'Dream Job Roadmap';
  String get dreamJobRoadmapDesc => language == AppLanguage.thai
      ? 'วางแผนเส้นทางสู่ความสำเร็จ'
      : 'Plan your path to success';
  String get startPlanning =>
      language == AppLanguage.thai ? 'เริ่มวางแผน' : 'Start Planning';

  String get consultingCoach => language == AppLanguage.thai
      ? 'กำลังปรึกษาโค้ชอาชีพ AI...'
      : 'Consulting AI Career Coach...';
  String get whereDoYouWantToBe => language == AppLanguage.thai
      ? 'เป้าหมายสูงสุดของคุณคืออะไร?'
      : 'Where do you want to be?';
  String get defineGoal => language == AppLanguage.thai
      ? 'กำหนดเป้าหมายอาชีพ แล้วให้ AI วางแผนเส้นทางให้คุณ'
      : 'Define your career goal and let AI map the path for you.';
  String get targetJobTitle =>
      language == AppLanguage.thai ? 'ตำแหน่งงานในฝัน' : 'Target Job Title';
  String get dreamCompanyOptional => language == AppLanguage.thai
      ? 'บริษัทในฝัน (ระบุหรือไม่ก็ได้)'
      : 'Dream Company (Optional)';
  String get currentLevel =>
      language == AppLanguage.thai ? 'ระดับปัจจุบัน' : 'Current Level';
  String get generateRoadmap =>
      language == AppLanguage.thai ? 'สร้างแผนที่เส้นทาง' : 'Generate Roadmap';
  String get at => language == AppLanguage.thai ? 'ที่' : 'at';
  String get completed =>
      language == AppLanguage.thai ? 'สำเร็จแล้ว' : 'Completed';
  String get yourSteps =>
      language == AppLanguage.thai ? 'ขั้นตอนของคุณ' : 'Your Steps';
  // Smart Cover Letter
  String get smartCoverLetter => language == AppLanguage.thai
      ? 'Smart Cover Letter'
      : 'Smart Cover Letter';
  String get coverLetterTips => language == AppLanguage.thai
      ? 'วางรายละเอียดงาน (Job Description) ด้านล่าง AI จะเขียนจดหมายสมัครงานให้เข้ากับจุดแข็งในเรซูเม่ของคุณ'
      : 'Paste the Job Description below. AI will tailor your cover letter to match your resume strengths with their requirements.';
  String get jobDescriptionLabel =>
      language == AppLanguage.thai ? 'รายละเอียดงาน:' : 'Job Description:';
  String get jobDescriptionHint => language == AppLanguage.thai
      ? 'วางรายละเอียดงานที่นี่...'
      : 'Paste Job Description here...';
  String get enterJobDescription => language == AppLanguage.thai
      ? 'กรุณากรอกรายละเอียดงาน'
      : 'Please enter a Job Description';
  String get generating =>
      language == AppLanguage.thai ? 'กำลังสร้าง...' : 'Generating...';
  String get generateCoverLetter => language == AppLanguage.thai
      ? 'สร้าง Cover Letter'
      : 'Generate Cover Letter';
  String get yourCoverLetter =>
      language == AppLanguage.thai ? 'จดหมายของคุณ:' : 'Your Cover Letter:';
  String get copyToClipboard =>
      language == AppLanguage.thai ? 'คัดลอกลงคลิปบอร์ด' : 'Copy to Clipboard';
  String get copiedToClipboard => language == AppLanguage.thai
      ? 'คัดลอกเรียบร้อย!'
      : 'Copied to clipboard!';
  String get copyText =>
      language == AppLanguage.thai ? 'คัดลอกข้อความ' : 'Copy Text';
}
