import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_widgets.dart';
import '../services/supabase_service.dart';
import 'pos_screen.dart';
import 'inventory_screen.dart';
import 'analytics_screen.dart';
import 'ai_insights_screen.dart';
import 'login_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _screens = const [
    PosScreen(),
    InventoryScreen(),
    AnalyticsScreen(),
    AIInsightsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    SupabaseService.authStateChanges.listen((event) {
      if (event.event == AuthChangeEvent.signedOut && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: KiranaBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
