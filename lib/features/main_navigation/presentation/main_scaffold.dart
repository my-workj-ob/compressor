import 'package:flutter/material.dart';
import 'package:compressor/core/theme/app_colors.dart';
import 'package:compressor/features/file_history/application/file_history_controller.dart';
import 'package:compressor/features/file_history/data/file_history_repository.dart';
import 'package:compressor/features/file_history/presentation/my_files_screen.dart';
import 'package:compressor/features/home/presentation/home_screen.dart';
import 'package:compressor/features/language/application/language_controller.dart';
import 'package:compressor/features/settings/presentation/settings_screen.dart';
import 'package:compressor/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Main scaffold with 4 persistent tabs: Home, Recent, Files, Settings.
class MainScaffold extends StatefulWidget {
  final LanguageController languageController;
  final int initialIndex;
  final FileHistoryController? historyController;

  const MainScaffold({
    super.key,
    required this.languageController,
    this.initialIndex = 0,
    this.historyController,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _currentIndex;
  late FileHistoryController _historyController;
  bool _isHistoryInitialized = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    if (widget.historyController != null) {
      _historyController = widget.historyController!;
      _isHistoryInitialized = true;
    } else {
      _initHistoryController();
    }
  }

  Future<void> _initHistoryController() async {
    final prefs = await SharedPreferences.getInstance();
    final repo = FileHistoryRepository(prefs);
    if (mounted) {
      setState(() {
        _historyController = FileHistoryController(repo);
        _isHistoryInitialized = true;
      });
    }
  }

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!_isHistoryInitialized) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final screens = [
      HomeScreen(
        historyController: _historyController,
        languageController: widget.languageController,
        onNavigateTab: _onTabSelected,
      ),
      MyFilesScreen(historyController: _historyController),
      MyFilesScreen(historyController: _historyController),
      SettingsScreen(languageController: widget.languageController),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabSelected,
          backgroundColor: AppColors.surface,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home_rounded),
              label: l10n.navHome,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.access_time_rounded),
              activeIcon: const Icon(Icons.access_time_filled_rounded),
              label: l10n.navRecent,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.folder_outlined),
              activeIcon: const Icon(Icons.folder_rounded),
              label: l10n.navFiles,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings_rounded),
              label: l10n.navSettings,
            ),
          ],
        ),
      ),
    );
  }
}
