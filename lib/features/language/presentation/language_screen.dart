import 'package:flutter/material.dart';
import 'package:compressor/core/theme/app_colors.dart';
import 'package:compressor/features/language/application/language_controller.dart';
import 'package:compressor/features/language/domain/app_language.dart';
import 'package:compressor/features/language/presentation/widgets/globe_illustration.dart';
import 'package:compressor/features/language/presentation/widgets/language_card.dart';
import 'package:compressor/features/main_navigation/presentation/main_scaffold.dart';
import 'package:compressor/l10n/app_localizations.dart';

/// Dedicated Language Selection Screen corresponding to Screen 1 of reference design.
class LanguageScreen extends StatefulWidget {
  final LanguageController controller;
  final bool isFirstLaunch;

  const LanguageScreen({
    super.key,
    required this.controller,
    this.isFirstLaunch = true,
  });

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late AppLanguage _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.controller.currentLanguage;
  }

  void _onLanguageSelected(AppLanguage lang) {
    setState(() {
      _selectedLanguage = lang;
    });
    // Immediately update active locale so the UI adapts preview in real-time
    widget.controller.setLanguage(lang.locale);
  }

  Future<void> _onContinue() async {
    if (widget.isFirstLaunch) {
      await widget.controller.completeLanguageSetup(_selectedLanguage.locale);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) => MainScaffold(
            languageController: widget.controller,
          ),
        ),
      );
    } else {
      await widget.controller.setLanguage(_selectedLanguage.locale);
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.isFirstLaunch
          ? null
          : AppBar(
              title: Text(l10n.chooseLanguage),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),

                      // 3D Globe with chat bubbles illustration
                      const GlobeIllustration(size: 190),

                      const SizedBox(height: 28),

                      // Header Title
                      Text(
                        l10n.chooseLanguage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        l10n.selectLanguageSubtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // 3 Language Cards: English, Uzbek, Russian
                      LanguageCard(
                        language: AppLanguage.english,
                        isSelected: _selectedLanguage == AppLanguage.english,
                        onTap: () => _onLanguageSelected(AppLanguage.english),
                      ),
                      const SizedBox(height: 12),

                      LanguageCard(
                        language: AppLanguage.uzbek,
                        isSelected: _selectedLanguage == AppLanguage.uzbek,
                        onTap: () => _onLanguageSelected(AppLanguage.uzbek),
                      ),
                      const SizedBox(height: 12),

                      LanguageCard(
                        language: AppLanguage.russian,
                        isSelected: _selectedLanguage == AppLanguage.russian,
                        onTap: () => _onLanguageSelected(AppLanguage.russian),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Bottom Continue Action Button
              Padding(
                padding: const EdgeInsets.only(bottom: 20, top: 12),
                child: ElevatedButton(
                  onPressed: _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 4,
                    shadowColor: AppColors.primary.withValues(alpha: 0.35),
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.continueButton,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
