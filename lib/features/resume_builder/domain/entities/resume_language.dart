/// Supported languages for resume preview
enum ResumeLanguage {
  english,
  thai,
}

extension ResumeLanguageExtension on ResumeLanguage {
  String get displayName {
    switch (this) {
      case ResumeLanguage.english:
        return 'English';
      case ResumeLanguage.thai:
        return 'ไทย';
    }
  }

  String get code {
    switch (this) {
      case ResumeLanguage.english:
        return 'en';
      case ResumeLanguage.thai:
        return 'th';
    }
  }
}

/// Localized strings for resume sections
class ResumeStrings {
  final ResumeLanguage language;

  const ResumeStrings(this.language);

  // Section titles
  String get professionalSummary => language == ResumeLanguage.thai
      ? 'ข้อมูลส่วนตัว' : 'Professional Summary';

  String get workExperience => language == ResumeLanguage.thai
      ? 'ประสบการณ์การทำงาน' : 'Work Experience';

  String get education => language == ResumeLanguage.thai
      ? 'การศึกษา' : 'Education';

  String get skills => language == ResumeLanguage.thai
      ? 'ทักษะและความสามารถ' : 'Skills';

  String get projects => language == ResumeLanguage.thai
      ? 'ผลงาน/โปรเจกต์' : 'Projects';

  String get languages => language == ResumeLanguage.thai
      ? 'ภาษา' : 'Languages';

  String get hobbies => language == ResumeLanguage.thai
      ? 'งานอดิเรก' : 'Hobbies & Interests';

  String get contact => language == ResumeLanguage.thai
      ? 'ข้อมูลติดต่อ' : 'Contact';

  String get profile => language == ResumeLanguage.thai
      ? 'ประวัติ' : 'Profile';

  String get aboutMe => language == ResumeLanguage.thai
      ? 'เกี่ยวกับฉัน' : 'About Me';

  String get expertise => language == ResumeLanguage.thai
      ? 'ความเชี่ยวชาญ' : 'Expertise';

  String get interests => language == ResumeLanguage.thai
      ? 'ความสนใจ' : 'Interests';

  // Placeholders
  String get yourName => language == ResumeLanguage.thai
      ? 'ชื่อของคุณ' : 'Your Name';

  String get jobTitle => language == ResumeLanguage.thai
      ? 'ตำแหน่งงาน' : 'Job Title';

  String get professionalTitle => language == ResumeLanguage.thai
      ? 'ตำแหน่งงาน' : 'Professional Title';

  String get creativeProfessional => language == ResumeLanguage.thai
      ? 'ผู้เชี่ยวชาญสร้างสรรค์' : 'Creative Professional';

  // Labels
  String get gpa => language == ResumeLanguage.thai
      ? 'เกรดเฉลี่ย' : 'GPA';

  String get present => language == ResumeLanguage.thai
      ? 'ปัจจุบัน' : 'Present';

  // Language levels (for display)
  String languageLevel(String level) {
    if (language == ResumeLanguage.thai) {
      switch (level.toLowerCase()) {
        case 'beginner':
          return 'เริ่มต้น';
        case 'elementary':
          return 'พื้นฐาน';
        case 'intermediate':
          return 'ปานกลาง';
        case 'upperintermediate':
        case 'upper intermediate':
          return 'ปานกลาง-สูง';
        case 'advanced':
          return 'ขั้นสูง';
        case 'native':
          return 'ภาษาแม่';
        default:
          return level;
      }
    }
    return level;
  }

  // Form UI strings
  String get add => language == ResumeLanguage.thai ? 'เพิ่ม' : 'Add';
  String get edit => language == ResumeLanguage.thai ? 'แก้ไข' : 'Edit';
  String get delete => language == ResumeLanguage.thai ? 'ลบ' : 'Delete';
  String get save => language == ResumeLanguage.thai ? 'บันทึก' : 'Save';
  String get cancel => language == ResumeLanguage.thai ? 'ยกเลิก' : 'Cancel';
  String get close => language == ResumeLanguage.thai ? 'ปิด' : 'Close';

  // Add buttons
  String get addExperience => language == ResumeLanguage.thai ? 'เพิ่มประสบการณ์' : 'Add Experience';
  String get addEducation => language == ResumeLanguage.thai ? 'เพิ่มการศึกษา' : 'Add Education';
  String get addSkill => language == ResumeLanguage.thai ? 'เพิ่มทักษะ' : 'Add Skill';
  String get addProject => language == ResumeLanguage.thai ? 'เพิ่มโปรเจกต์' : 'Add Project';
  String get addLanguage => language == ResumeLanguage.thai ? 'เพิ่มภาษา' : 'Add Language';
  String get addHobby => language == ResumeLanguage.thai ? 'เพิ่มงานอดิเรก' : 'Add Hobby';

  // Edit dialogs
  String get editExperience => language == ResumeLanguage.thai ? 'แก้ไขประสบการณ์' : 'Edit Experience';
  String get editEducation => language == ResumeLanguage.thai ? 'แก้ไขการศึกษา' : 'Edit Education';
  String get editSkill => language == ResumeLanguage.thai ? 'แก้ไขทักษะ' : 'Edit Skill';
  String get editProject => language == ResumeLanguage.thai ? 'แก้ไขโปรเจกต์' : 'Edit Project';
  String get editLanguage => language == ResumeLanguage.thai ? 'แก้ไขภาษา' : 'Edit Language';
  String get editHobby => language == ResumeLanguage.thai ? 'แก้ไขงานอดิเรก' : 'Edit Hobby';

  // Form field labels
  String get companyName => language == ResumeLanguage.thai ? 'ชื่อบริษัท' : 'Company Name';
  String get position => language == ResumeLanguage.thai ? 'ตำแหน่ง' : 'Position';
  String get location => language == ResumeLanguage.thai ? 'สถานที่' : 'Location';
  String get startDate => language == ResumeLanguage.thai ? 'วันที่เริ่ม' : 'Start Date';
  String get endDate => language == ResumeLanguage.thai ? 'วันที่สิ้นสุด' : 'End Date';
  String get currentJob => language == ResumeLanguage.thai ? 'งานปัจจุบัน' : 'Current Job';
  String get description => language == ResumeLanguage.thai ? 'รายละเอียด' : 'Description';

  String get institution => language == ResumeLanguage.thai ? 'สถาบัน' : 'Institution';
  String get degree => language == ResumeLanguage.thai ? 'วุฒิการศึกษา' : 'Degree';
  String get fieldOfStudy => language == ResumeLanguage.thai ? 'สาขาวิชา' : 'Field of Study';
  String get currentlyStudying => language == ResumeLanguage.thai ? 'กำลังศึกษาอยู่' : 'Currently Studying';

  String get skillName => language == ResumeLanguage.thai ? 'ชื่อทักษะ' : 'Skill Name';
  String get skillLevel => language == ResumeLanguage.thai ? 'ระดับทักษะ' : 'Skill Level';
  String get category => language == ResumeLanguage.thai ? 'หมวดหมู่' : 'Category';

  String get projectName => language == ResumeLanguage.thai ? 'ชื่อโปรเจกต์' : 'Project Name';
  String get projectUrl => language == ResumeLanguage.thai ? 'URL โปรเจกต์' : 'Project URL';
  String get technologies => language == ResumeLanguage.thai ? 'เทคโนโลยี' : 'Technologies';

  String get languageName => language == ResumeLanguage.thai ? 'ชื่อภาษา' : 'Language Name';
  String get proficiency => language == ResumeLanguage.thai ? 'ระดับความสามารถ' : 'Proficiency';

  String get hobbyName => language == ResumeLanguage.thai ? 'ชื่องานอดิเรก' : 'Hobby Name';

  // Empty states
  String get noExperience => language == ResumeLanguage.thai
      ? 'ยังไม่มีประสบการณ์การทำงาน\nกดปุ่มด้านบนเพื่อเพิ่ม'
      : 'No work experience added yet.\nTap the button above to add your first experience.';
  String get noEducation => language == ResumeLanguage.thai
      ? 'ยังไม่มีประวัติการศึกษา\nกดปุ่มด้านบนเพื่อเพิ่ม'
      : 'No education added yet.\nTap the button above to add your education.';
  String get noSkills => language == ResumeLanguage.thai
      ? 'ยังไม่มีทักษะ\nกดปุ่มด้านบนเพื่อเพิ่ม'
      : 'No skills added yet.\nTap the button above to add your skills.';
  String get noProjects => language == ResumeLanguage.thai
      ? 'ยังไม่มีโปรเจกต์\nกดปุ่มด้านบนเพื่อเพิ่ม'
      : 'No projects added yet.\nTap the button above to add your projects.';
  String get noLanguages => language == ResumeLanguage.thai
      ? 'ยังไม่มีภาษา\nกดปุ่มด้านบนเพื่อเพิ่ม'
      : 'No languages added yet.\nTap the button above to add languages.';
  String get noHobbies => language == ResumeLanguage.thai
      ? 'ยังไม่มีงานอดิเรก\nกดปุ่มด้านบนเพื่อเพิ่ม'
      : 'No hobbies added yet.\nTap the button above to add your hobbies.';

  // Profile form
  String get fullName => language == ResumeLanguage.thai ? 'ชื่อ-นามสกุล' : 'Full Name';
  String get summary => language == ResumeLanguage.thai ? 'สรุปโปรไฟล์' : 'Summary';
  String get profilePhoto => language == ResumeLanguage.thai ? 'รูปโปรไฟล์' : 'Profile Photo';
  String get changePhoto => language == ResumeLanguage.thai ? 'เปลี่ยนรูป' : 'Change Photo';

  // Contact form
  String get email => language == ResumeLanguage.thai ? 'อีเมล' : 'Email';
  String get phone => language == ResumeLanguage.thai ? 'เบอร์โทร' : 'Phone';
  String get website => language == ResumeLanguage.thai ? 'เว็บไซต์' : 'Website';
  String get address => language == ResumeLanguage.thai ? 'ที่อยู่' : 'Address';
  String get city => language == ResumeLanguage.thai ? 'เมือง' : 'City';
  String get country => language == ResumeLanguage.thai ? 'ประเทศ' : 'Country';

  // Confirmations
  String get confirmDelete => language == ResumeLanguage.thai ? 'ยืนยันการลบ' : 'Confirm Delete';
  String deleteConfirmMessage(String item) => language == ResumeLanguage.thai
      ? 'คุณต้องการลบ "$item" หรือไม่?'
      : 'Are you sure you want to delete "$item"?';

  // Hints for Experience
  String get hintCompanyName => language == ResumeLanguage.thai
      ? 'เช่น บริษัท ABC จำกัด' : 'e.g., ABC Company';
  String get hintPosition => language == ResumeLanguage.thai
      ? 'เช่น นักพัฒนาซอฟต์แวร์' : 'e.g., Software Developer';
  String get hintLocation => language == ResumeLanguage.thai
      ? 'เช่น กรุงเทพ, ประเทศไทย' : 'e.g., Bangkok, Thailand';
  String get hintDescription => language == ResumeLanguage.thai
      ? 'อธิบายหน้าที่และความรับผิดชอบ' : 'Describe your responsibilities';

  // Hints for Education
  String get hintInstitution => language == ResumeLanguage.thai
      ? 'เช่น มหาวิทยาลัยจุฬาลงกรณ์' : 'e.g., Chulalongkorn University';
  String get hintDegree => language == ResumeLanguage.thai
      ? 'เช่น ปริญญาตรี' : 'e.g., Bachelor\'s Degree';
  String get hintFieldOfStudy => language == ResumeLanguage.thai
      ? 'เช่น วิทยาการคอมพิวเตอร์' : 'e.g., Computer Science';
  String get hintGpa => language == ResumeLanguage.thai
      ? 'เช่น 3.50' : 'e.g., 3.50';

  // Hints for Skills
  String get hintSkillName => language == ResumeLanguage.thai
      ? 'เช่น Flutter, Python, การจัดการโปรเจกต์' : 'e.g., Flutter, Python, Project Management';
  String get hintCategory => language == ResumeLanguage.thai
      ? 'เช่น โปรแกรมมิ่ง, ออกแบบ, ภาษา' : 'e.g., Programming, Design, Languages';

  // Hints for Projects
  String get hintProjectName => language == ResumeLanguage.thai
      ? 'เช่น แอปจัดการงาน' : 'e.g., Task Management App';
  String get hintProjectUrl => language == ResumeLanguage.thai
      ? 'เช่น https://myproject.com' : 'e.g., https://myproject.com';
  String get hintTechnologies => language == ResumeLanguage.thai
      ? 'เช่น Flutter, Firebase, REST API' : 'e.g., Flutter, Firebase, REST API';
  String get hintProjectDescription => language == ResumeLanguage.thai
      ? 'อธิบายโปรเจกต์และผลลัพธ์' : 'Describe the project and outcomes';

  // Hints for Languages
  String get hintLanguageName => language == ResumeLanguage.thai
      ? 'เช่น อังกฤษ, ไทย, ญี่ปุ่น' : 'e.g., English, Thai, Japanese';

  // Hints for Hobbies
  String get hintHobbyName => language == ResumeLanguage.thai
      ? 'เช่น อ่านหนังสือ, ถ่ายภาพ, เล่นเกม' : 'e.g., Reading, Photography, Gaming';

  // Hints for Profile
  String get hintFullName => language == ResumeLanguage.thai
      ? 'เช่น สมชาย ใจดี' : 'e.g., John Doe';
  String get hintJobTitle => language == ResumeLanguage.thai
      ? 'เช่น นักพัฒนาแอปพลิเคชัน' : 'e.g., Mobile Developer';
  String get hintSummary => language == ResumeLanguage.thai
      ? 'เขียนสรุปประสบการณ์และความสามารถของคุณ' : 'Write a brief summary of your experience and skills';

  // Hints for Contact
  String get hintEmail => language == ResumeLanguage.thai
      ? 'เช่น example@email.com' : 'e.g., example@email.com';
  String get hintPhone => language == ResumeLanguage.thai
      ? 'เช่น 081-234-5678' : 'e.g., +66 81-234-5678';
  String get hintWebsite => language == ResumeLanguage.thai
      ? 'เช่น https://mywebsite.com' : 'e.g., https://mywebsite.com';
  String get hintLinkedIn => language == ResumeLanguage.thai
      ? 'เช่น linkedin.com/in/username' : 'e.g., linkedin.com/in/username';
  String get hintGitHub => language == ResumeLanguage.thai
      ? 'เช่น github.com/username' : 'e.g., github.com/username';
  String get hintAddress => language == ResumeLanguage.thai
      ? 'เช่น 123 ถนนสุขุมวิท' : 'e.g., 123 Main Street';
  String get hintCity => language == ResumeLanguage.thai
      ? 'เช่น กรุงเทพมหานคร' : 'e.g., Bangkok';
  String get hintCountry => language == ResumeLanguage.thai
      ? 'เช่น ประเทศไทย' : 'e.g., Thailand';

  // Required field indicator
  String get required => language == ResumeLanguage.thai ? 'จำเป็น' : 'Required';
}

