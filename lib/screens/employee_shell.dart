// lib/screens/employee_shell.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'employee_pos_screen.dart';
import 'employee_history_screen.dart';
import 'employee_profile_screen.dart';

class EmployeeShell extends StatefulWidget {
  final String employeeName;
  final String shopId;

  const EmployeeShell({
    super.key,
    required this.employeeName,
    required this.shopId,
  });

  @override
  State<EmployeeShell> createState() => _EmployeeShellState();
}

class _EmployeeShellState extends State<EmployeeShell> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      EmployeePosScreen(employeeName: widget.employeeName, shopId: widget.shopId),
      EmployeeHistoryScreen(employeeName: widget.employeeName),
      EmployeeProfileScreen(employeeName: widget.employeeName, shopId: widget.shopId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF101A15),
          border: Border(top: BorderSide(color: Color(0xFF1E3028), width: 1)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.point_of_sale_outlined, 'Billing'),
                _navItem(1, Icons.history_outlined, 'History'),
                _navItem(2, Icons.person_outline, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final selected = index == _currentIndex;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: selected
            ? BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20))
            : null,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: selected ? AppColors.primary : AppColors.textMuted, size: 22),
          const SizedBox(height: 3),
          Text(label, style: GoogleFonts.inter(
              fontSize: 10, fontWeight: FontWeight.w600,
              color: selected ? AppColors.primary : AppColors.textMuted)),
        ]),
      ),
    );
  }
}
