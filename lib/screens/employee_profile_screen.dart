// lib/screens/employee_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'login_screen.dart';

class EmployeeProfileScreen extends StatelessWidget {
  final String employeeName;
  final String shopId;

  const EmployeeProfileScreen({super.key, required this.employeeName, required this.shopId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        leading: Padding(padding: const EdgeInsets.all(8),
          child: Container(decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.store_outlined, color: AppColors.primary, size: 20))),
        title: Text('My Profile', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // Avatar
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: Text(
              employeeName.isNotEmpty ? employeeName[0].toUpperCase() : 'E',
              style: GoogleFonts.inter(color: AppColors.primary, fontSize: 36, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 12),
          Text(employeeName, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
          Text('Employee', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 13)),
          const SizedBox(height: 24),

          // Info card
          KiranaCard(
            child: Column(children: [
              _infoRow(Icons.store_outlined, 'Shop ID', shopId),
              const Divider(color: Color(0xFF1E3028)),
              _infoRow(Icons.badge_outlined, 'Role', 'Employee'),
              const Divider(color: Color(0xFF1E3028)),
              _infoRow(Icons.check_circle_outline, 'Status', 'Active'),
            ]),
          ),
          const SizedBox(height: 16),

          // Features card
          KiranaCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Your Features', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 12),
              _featureTile(Icons.point_of_sale_outlined, 'Billing', 'Products scan karke bill banao', true),
              _featureTile(Icons.qr_code_scanner, 'Barcode Scanner', 'Scan items to add quickly', true),
              _featureTile(Icons.history_outlined, 'Bill History', 'View previous bills', true),
              _featureTile(Icons.inventory_2_outlined, 'Inventory', 'Owner only', false),
              _featureTile(Icons.analytics_outlined, 'Analytics', 'Owner only', false),
            ]),
          ),
          const SizedBox(height: 16),

          // Tips card
          KiranaCard(
            color: AppColors.primary.withValues(alpha: 0.05),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text('Tips', style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14)),
              ]),
              const SizedBox(height: 10),
              _tipRow('Search products by SKU'),
              _tipRow('Scan barcode to add items quickly'),
              _tipRow('Always select payment method'),
              _tipRow('Give receipt to customer after billing'),
            ]),
          ),
          const SizedBox(height: 24),

          // Logout
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => _confirmLogout(context),
              icon: const Icon(Icons.logout, color: AppColors.error, size: 18),
              label: Text('Logout', style: GoogleFonts.inter(color: AppColors.error, fontWeight: FontWeight.w700, fontSize: 15)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Logout', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to logout?', style: GoogleFonts.inter(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Logout', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Icon(icon, color: AppColors.textMuted, size: 18),
        const SizedBox(width: 12),
        Text(label, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
        const Spacer(),
        Text(value, style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
      ]),
    );
  }

  Widget _featureTile(IconData icon, String title, String sub, bool allowed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, color: allowed ? AppColors.primary : AppColors.textMuted, size: 18),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.inter(color: allowed ? AppColors.textPrimary : AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
          Text(sub, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11)),
        ])),
        Icon(allowed ? Icons.check_circle : Icons.lock_outline,
            color: allowed ? AppColors.success : AppColors.textMuted, size: 16),
      ]),
    );
  }

  Widget _tipRow(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('• ', style: TextStyle(color: AppColors.primary)),
        Expanded(child: Text(tip, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12))),
      ]),
    );
  }
}
