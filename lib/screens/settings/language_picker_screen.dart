import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class LanguagePickerScreen extends StatefulWidget {
  const LanguagePickerScreen({super.key});

  @override
  State<LanguagePickerScreen> createState() => _LanguagePickerScreenState();
}

class _LanguagePickerScreenState extends State<LanguagePickerScreen> {
  String _selected = 'English';

  final _languages = [
    'English',
    'French',
    'Spanish',
    'Portuguese',
    'Arabic',
    'Swahili',
    'Yoruba',
    'Igbo',
    'Hausa',
    'Zulu',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Language',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.onSurface, fontWeight: FontWeight.w600, fontSize: 22)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text('SELECT LANGUAGE',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.onSurfaceVariant, letterSpacing: 1.2)),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.surfaceVariant),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _languages.length,
                separatorBuilder: (_, _) => Padding(
                  padding: const EdgeInsets.only(left: 72),
                  child: Divider(height: 1, color: AppTheme.surfaceVariant),
                ),
                itemBuilder: (context, i) {
                  final lang = _languages[i];
                  final selected = _selected == lang;
                  return InkWell(
                    onTap: () => setState(() => _selected = lang),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(lang.substring(0, 2).toUpperCase(),
                                style: const TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.w600, fontSize: 14)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(lang,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.onSurface)),
                          ),
                          if (selected)
                            const Icon(Icons.check_circle, color: AppTheme.primaryContainer, size: 22),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.surfaceVariant),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 20, color: AppTheme.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Language changes are currently visual only. Full i18n coming soon.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceVariant)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
