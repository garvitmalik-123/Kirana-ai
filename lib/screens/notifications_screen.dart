// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/database_service.dart';
import '../models/product_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Product> _lowStock = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final all = await DatabaseService.getProducts();
      setState(() { _lowStock = all.where((p) => p.isLowStock).toList(); _loading = false; });
    } catch (e) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary), onPressed: () => Navigator.pop(context)),
        title: Text('Notifications', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _lowStock.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.notifications_none_outlined, color: AppColors.textMuted, size: 56),
                  const SizedBox(height: 12),
                  Text('No notifications', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 15)),
                ]))
              : ListView(padding: const EdgeInsets.all(16), children: [
                  Text('Stock Alerts', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
                  const SizedBox(height: 10),
                  ..._lowStock.map((p) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF1E3028))),
                    child: Row(children: [
                      Container(padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(p.name, style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                        Text(p.isOutOfStock ? 'Out of stock!' : 'Only ${p.stock} ${p.unit ?? ""} left',
                            style: GoogleFonts.inter(color: p.isOutOfStock ? AppColors.error : AppColors.warning, fontSize: 12)),
                      ])),
                    ]),
                  )),
                ]),
    );
  }
}
