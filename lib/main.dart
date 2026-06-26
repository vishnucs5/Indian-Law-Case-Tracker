import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'viewmodels/case_viewmodel.dart';
import 'services/notification_service.dart';
import 'theme/legal_theme.dart';
import 'widgets/neumorphic.dart';
import 'views/dashboard_view.dart';
import 'views/all_cases_list_view.dart';
import 'views/pending_outcome_view.dart';
import 'views/settings_view.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService().initialize();
  await NotificationService().requestPermission();

  runApp(const CaseTrackApp());
}

class CaseTrackApp extends StatelessWidget {
  const CaseTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CaseViewModel()..initialize(),
      child: MaterialApp(
        title: 'CaseTrack',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: LegalColors.textPrimary,
          useMaterial3: true,
          scaffoldBackgroundColor: LegalColors.background,
          fontFamily: GoogleFonts.inter().fontFamily,
          appBarTheme: const AppBarTheme(
            backgroundColor: LegalColors.background,
            foregroundColor: LegalColors.textPrimary,
            elevation: 0,
            centerTitle: true,
          ),
          cardTheme: const CardThemeData(
            color: Colors.transparent,
            elevation: 0,
            margin: EdgeInsets.zero,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: LegalColors.textPrimary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(LegalRadius.lg),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: LegalColors.textPrimary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: const MainTabView(),
      ),
    );
  }
}

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardView(),
    AllCasesListView(),
    PendingOutcomeView(),
    SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: NeuContainer(
          radius: 24,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: _currentIndex == 0 ? Icons.dashboard_rounded : Icons.dashboard_outlined,
                label: 'Dashboard',
                isActive: _currentIndex == 0,
                onTap: () => _navigateTo(0),
              ),
              _NavItem(
                icon: _currentIndex == 1 ? Icons.folder_rounded : Icons.folder_outlined,
                label: 'Case Files',
                isActive: _currentIndex == 1,
                onTap: () => _navigateTo(1),
              ),
              _NavItem(
                icon: _currentIndex == 2 ? Icons.task_alt_rounded : Icons.task_outlined,
                label: 'Tasks',
                isActive: _currentIndex == 2,
                onTap: () => _navigateTo(2),
              ),
              _NavItem(
                icon: _currentIndex == 3 ? Icons.settings_rounded : Icons.settings_outlined,
                label: 'Firm Settings',
                isActive: _currentIndex == 3,
                onTap: () => _navigateTo(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(int index) {
    setState(() => _currentIndex = index);
    if (index == 0) {
      context.read<CaseViewModel>().refresh();
    }
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 78,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? LegalColors.surfaceElevated : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: LegalColors.insetShadow,
                    offset: const Offset(3, 3),
                    blurRadius: 8,
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: LegalColors.highlight.withValues(alpha: 0.95),
                    offset: const Offset(-3, -3),
                    blurRadius: 8,
                    spreadRadius: -3,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: isActive ? LegalColors.textPrimary : LegalColors.navInactive),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? LegalColors.textPrimary : LegalColors.navInactive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
