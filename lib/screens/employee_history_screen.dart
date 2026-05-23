// lib/screens/employee_history_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../models/product_model.dart';
import '../services/database_service.dart';

class EmployeeHistoryScreen extends StatefulWidget {
  final String employeeName;
  const EmployeeHistoryScreen({super.key, required this.employeeName});
  @override
  State<EmployeeHistoryScreen> createState() => _EmployeeHistoryScreenState();
}

class _EmployeeHistoryScreenState extends State<EmployeeHistoryScreen> {
  List<Bill> _bills = [];
  bool _loading = true;
  Map<String, dynamic> _todayStats = {};

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final bills = await DatabaseService.getRecentBills(limit: 30);
      final stats = await DatabaseService.getTodayStats();
      setState(() { _bills = bills; _todayStats = stats; _loading = false; });
    } catch (e) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final totalSales = (_todayStats['total_sales'] ?? 0.0) as double;
    final totalBills = (_todayStats['total_bills'] ?? 0) as int;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        leading: Padding(padding: const EdgeInsets.all(8),
          child: Container(decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.store_outlined, color: AppColors.primary, size: 20))),
        title: Text('Bill History', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: AppColors.textSecondary), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _load,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  // Today stats
                  Row(children: [
                    Expanded(child: _statCard('Today\'s Bills', '$totalBills', Icons.receipt_outlined, AppColors.success)),
                    const SizedBox(width: 12),
                    Expanded(child: _statCard('Today\'s Sales', '₹${totalSales.toStringAsFixed(0)}', Icons.currency_rupee, AppColors.primary)),
                  ]),
                  const SizedBox(height: 16),
                  Row(children: [
                    Text('Recent Bills', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                    const Spacer(),
                    Text('${_bills.length} bills', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
                  ]),
                  const SizedBox(height: 12),
                  if (_bills.isEmpty)
                    Center(child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(children: [
                        const Icon(Icons.receipt_long_outlined, color: AppColors.textMuted, size: 48),
                        const SizedBox(height: 12),
                        Text('No bills yet', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14)),
                      ]),
                    ))
                  else
                    ..._bills.map((bill) => _billTile(bill)),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11)),
          Text(value, style: GoogleFonts.inter(color: color, fontWeight: FontWeight.w800, fontSize: 18)),
        ]),
      ]),
    );
  }

  Widget _billTile(Bill bill) {
    final isCompleted = bill.status == 'completed';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3028)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.receipt_outlined, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Bill #${bill.billNumber}', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
          Text(bill.customerName ?? 'Walk-in Customer', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11)),
          Text(_formatTime(bill.createdAt), style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 10)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('₹${bill.total.toStringAsFixed(0)}', style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: (isCompleted ? AppColors.success : AppColors.warning).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(isCompleted ? 'Done' : 'Pending',
                style: GoogleFonts.inter(color: isCompleted ? AppColors.success : AppColors.warning, fontSize: 10, fontWeight: FontWeight.w600)),
          ),
        ]),
      ]),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
