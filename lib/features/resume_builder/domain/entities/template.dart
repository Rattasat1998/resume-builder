import 'package:equatable/equatable.dart';

/// Resume template types
enum TemplateType {
  templateA,      // Classic
  templateB,      // Modern
  elegant,        // Elegant - Minimalist with serif fonts
  creative,       // Creative - Bold colors and unique layout
  professional,   // Professional - Corporate style
  minimal,        // Minimal - Ultra clean
  bold,           // Bold - Strong typography
  tech,           // Tech - Developer/IT focused
  executive,      // Executive - Senior/C-level
  infographic,    // Infographic - Visual data
  timeline,       // Timeline - Career progression
  gradient,       // Gradient - Modern gradient colors
}

extension TemplateTypeExtension on TemplateType {
  String get displayName {
    switch (this) {
      case TemplateType.templateA:
        return 'Classic';
      case TemplateType.templateB:
        return 'Modern';
      case TemplateType.elegant:
        return 'Elegant';
      case TemplateType.creative:
        return 'Creative';
      case TemplateType.professional:
        return 'Professional';
      case TemplateType.minimal:
        return 'Minimal';
      case TemplateType.bold:
        return 'Bold';
      case TemplateType.tech:
        return 'Tech';
      case TemplateType.executive:
        return 'Executive';
      case TemplateType.infographic:
        return 'Infographic';
      case TemplateType.timeline:
        return 'Timeline';
      case TemplateType.gradient:
        return 'Gradient';
    }
  }

  String get description {
    switch (this) {
      case TemplateType.templateA:
        return 'A clean, classic layout perfect for traditional industries';
      case TemplateType.templateB:
        return 'A modern, stylish design with sidebar for creative professionals';
      case TemplateType.elegant:
        return 'Sophisticated and refined with elegant typography';
      case TemplateType.creative:
        return 'Bold and artistic design for creative roles';
      case TemplateType.professional:
        return 'Corporate and polished for business professionals';
      case TemplateType.minimal:
        return 'Ultra clean design that lets content shine';
      case TemplateType.bold:
        return 'Strong typography and impactful layout';
      case TemplateType.tech:
        return 'Modern tech-inspired design for developers';
      case TemplateType.executive:
        return 'Premium design for senior leadership roles';
      case TemplateType.infographic:
        return 'Visual-focused with charts and icons';
      case TemplateType.timeline:
        return 'Career progression timeline layout';
      case TemplateType.gradient:
        return 'Trendy gradient colors and modern aesthetics';
    }
  }

  String get defaultPrimaryColor {
    switch (this) {
      case TemplateType.templateA:
        return '#1a1a1a';
      case TemplateType.templateB:
        return '#2c3e50';
      case TemplateType.elegant:
        return '#8B4513';
      case TemplateType.creative:
        return '#FF6B6B';
      case TemplateType.professional:
        return '#1E3A5F';
      case TemplateType.minimal:
        return '#333333';
      case TemplateType.bold:
        return '#000000';
      case TemplateType.tech:
        return '#00D4AA';
      case TemplateType.executive:
        return '#2C3E50';
      case TemplateType.infographic:
        return '#3498DB';
      case TemplateType.timeline:
        return '#9B59B6';
      case TemplateType.gradient:
        return '#667EEA';
    }
  }

  String get defaultSecondaryColor {
    switch (this) {
      case TemplateType.templateA:
        return '#666666';
      case TemplateType.templateB:
        return '#3498db';
      case TemplateType.elegant:
        return '#D4A574';
      case TemplateType.creative:
        return '#4ECDC4';
      case TemplateType.professional:
        return '#4A90A4';
      case TemplateType.minimal:
        return '#999999';
      case TemplateType.bold:
        return '#FFD700';
      case TemplateType.tech:
        return '#1a1a2e';
      case TemplateType.executive:
        return '#C9A227';
      case TemplateType.infographic:
        return '#E74C3C';
      case TemplateType.timeline:
        return '#E91E63';
      case TemplateType.gradient:
        return '#764BA2';
    }
  }
}

/// Template configuration for resume
class Template extends Equatable {
  final String id;
  final TemplateType type;
  final String primaryColor;
  final String secondaryColor;
  final String fontFamily;
  final double fontSize;

  const Template({
    required this.id,
    required this.type,
    this.primaryColor = '#1a1a1a',
    this.secondaryColor = '#666666',
    this.fontFamily = 'Roboto',
    this.fontSize = 12.0,
  });

  Template copyWith({
    String? id,
    TemplateType? type,
    String? primaryColor,
    String? secondaryColor,
    String? fontFamily,
    double? fontSize,
  }) {
    return Template(
      id: id ?? this.id,
      type: type ?? this.type,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  factory Template.defaultTemplate(String id) => Template(
    id: id,
    type: TemplateType.templateA,
  );

  @override
  List<Object?> get props => [
    id,
    type,
    primaryColor,
    secondaryColor,
    fontFamily,
    fontSize,
  ];
}

