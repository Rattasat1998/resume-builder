import 'package:flutter/material.dart';

import '../../domain/entities/template.dart';

/// Page for selecting and customizing resume templates
class TemplatesPage extends StatefulWidget {
  final Template currentTemplate;
  final ValueChanged<Template> onTemplateChanged;

  const TemplatesPage({
    super.key,
    required this.currentTemplate,
    required this.onTemplateChanged,
  });

  @override
  State<TemplatesPage> createState() => _TemplatesPageState();
}

class _TemplatesPageState extends State<TemplatesPage> {
  late TemplateType _selectedType;
  late String _primaryColor;
  late String _secondaryColor;
  late String _fontFamily;
  late double _fontSize;

  final List<String> _availableColors = [
    '#1a1a1a',
    '#2c3e50',
    '#1abc9c',
    '#3498db',
    '#9b59b6',
    '#e74c3c',
    '#f39c12',
    '#8B4513',
    '#FF6B6B',
    '#1E3A5F',
    '#00D4AA',
    '#C9A227',
    '#667EEA',
    '#764BA2',
  ];

  final List<String> _availableFonts = [
    'Roboto',
    'Open Sans',
    'Lato',
    'Montserrat',
    'Poppins',
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.currentTemplate.type;
    _primaryColor = widget.currentTemplate.primaryColor;
    _secondaryColor = widget.currentTemplate.secondaryColor;
    _fontFamily = widget.currentTemplate.fontFamily;
    _fontSize = widget.currentTemplate.fontSize;
  }

  void _updateTemplate() {
    final template = widget.currentTemplate.copyWith(
      type: _selectedType,
      primaryColor: _primaryColor,
      secondaryColor: _secondaryColor,
      fontFamily: _fontFamily,
      fontSize: _fontSize,
    );
    widget.onTemplateChanged(template);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Templates'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Template selection
          Text(
            'Choose Template',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildTemplateGrid(),
          const SizedBox(height: 32),

          // Color customization
          Text(
            'Primary Color',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildColorPicker(_primaryColor, (color) {
            setState(() {
              _primaryColor = color;
            });
            _updateTemplate();
          }),
          const SizedBox(height: 24),

          Text(
            'Secondary Color',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildColorPicker(_secondaryColor, (color) {
            setState(() {
              _secondaryColor = color;
            });
            _updateTemplate();
          }),
          const SizedBox(height: 32),

          // Font customization
          Text(
            'Font Family',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildFontDropdown(),
          const SizedBox(height: 32),

          // Font size
          Text(
            'Font Size: ${_fontSize.toInt()}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Slider(
            value: _fontSize,
            min: 10,
            max: 16,
            divisions: 6,
            label: _fontSize.toInt().toString(),
            onChanged: (value) {
              setState(() {
                _fontSize = value;
              });
              _updateTemplate();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: TemplateType.values.length,
      itemBuilder: (context, index) {
        final template = TemplateType.values[index];
        final isSelected = template == _selectedType;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedType = template;
              // Auto-apply template's default colors
              _primaryColor = template.defaultPrimaryColor;
              _secondaryColor = template.defaultSecondaryColor;
            });
            _updateTemplate();
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade300,
                width: isSelected ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _hexToColor(template.defaultPrimaryColor),
                          _hexToColor(template.defaultSecondaryColor),
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(11),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getTemplateIcon(template),
                        size: 40,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Text(
                        template.displayName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        template.description,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorPicker(String selectedColor, ValueChanged<String> onChanged) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _availableColors.map((color) {
        final isSelected = color == selectedColor;
        return GestureDetector(
          onTap: () => onChanged(color),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _hexToColor(color),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.black : Colors.transparent,
                width: 3,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFontDropdown() {
    return DropdownButtonFormField<String>(
      value: _fontFamily,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
      items: _availableFonts.map((font) {
        return DropdownMenuItem(
          value: font,
          child: Text(font),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _fontFamily = value;
          });
          _updateTemplate();
        }
      },
    );
  }

  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  IconData _getTemplateIcon(TemplateType template) {
    switch (template) {
      case TemplateType.templateA:
        return Icons.description;
      case TemplateType.templateB:
        return Icons.dashboard;
      case TemplateType.elegant:
        return Icons.auto_awesome;
      case TemplateType.creative:
        return Icons.palette;
      case TemplateType.professional:
        return Icons.business_center;
      case TemplateType.minimal:
        return Icons.crop_square;
      case TemplateType.bold:
        return Icons.format_bold;
      case TemplateType.tech:
        return Icons.code;
      case TemplateType.executive:
        return Icons.workspace_premium;
      case TemplateType.infographic:
        return Icons.insert_chart;
      case TemplateType.timeline:
        return Icons.timeline;
      case TemplateType.gradient:
        return Icons.gradient;
    }
  }
}

