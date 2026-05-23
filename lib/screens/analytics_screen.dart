// lib/screens/analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../models/product_model.dart';
import '../services/database_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Map<String, dynamic> _todayStats = {};
  List<Map<String, dynamic>> _weeklySales = [];
  List<Bill> _recentBills = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final stats = await DatabaseService.getTodayStats();
      final weekly = await DatabaseService.getWeeklySales();
      final bills = await DatabaseService.getRecentBills();
      setState(() { _todayStats = stats; _weeklySales = weekly; _recentBills = bills; _loading = false; });
    } catch (e) { setState(() => _loading = false); }
  }

  String _formatCurrency(double val) {
    if (val >= 100000) return '₹${(val/100000).toStringAsFixed(1)}L';
    if (val >= 1000) return '₹${(val/1000).toStringAsFixed(1)}K';
    return '₹${val.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final totalSales = (_todayStats['total_sales'] ?? 0.0) as double;
    final totalBills = (_todayStats['total_bills'] ?? 0) as int;
    final avgTicket = (_todayStats['avg_ticket'] ?? 0.0) as double;
    final weeklyData = _weeklySales.map((e) => (e['total'] as double)).toList();
    final weeklyDays = _weeklySales.map((e) => e['day'] as String).toList();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: KiranaAppBar(title: 'Kirana AI', showSearch: true, showNotification: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _load,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  KiranaCard(
                    color: const Color(0xFF0F1F18),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('DAILY PERFORMANCE', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 1.2)),
                      const SizedBox(height: 8),
                      Text(_formatCurrency(totalSales),
                          style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 36, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.trending_up, color: AppColors.success, size: 14),
                          const SizedBox(width: 4),
                          Text('$totalBills bills today', style: GoogleFonts.inter(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 12)),
                        ]),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  StatCard(title: 'Total Bills Today', value: '$totalBills',
                      icon: Icons.receipt_long_outlined, iconBg: const Color(0xFF1A2A4A), iconColor: AppColors.info),
                  const SizedBox(height: 12),
                  StatCard(title: 'Avg. Ticket Size', value: '₹${avgTicket.toStringAsFixed(0)}',
                      icon: Icons.receipt_outlined, iconBg: const Color(0xFF3A1A4A), iconColor: AppColors.profit),
                  const SizedBox(height: 16),
                  KiranaCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Weekly Sales', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 130,
                        child: weeklyData.isEmpty
                            ? Center(child: Text('No data yet', style: GoogleFonts.inter(color: AppColors.textMuted)))
                            : WeeklySalesChart(
                                data: weeklyData.map((e) => e == 0 ? 1.0 : e).toList(),
                                days: weeklyDays.isEmpty ? ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'] : weeklyDays,
                              ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  KiranaCard(
                    child: Column(children: [
                      Row(children: [
                        const Icon(Icons.receipt_outlined, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text('Recent Transactions', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF2A3D35))),
                          child: Text('Export CSV', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      if (_recentBills.isEmpty)
                        Padding(padding: const EdgeInsets.all(20),
                            child: Text('No transactions yet', style: GoogleFonts.inter(color: AppColors.textMuted)))
                      else
                        ..._recentBills.take(10).map((bill) => _txnRow(bill)),
                    ]),
                  ),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
    );
  }

  Widget _txnRow(Bill bill) {
    final isCompleted = bill.status == 'completed';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Expanded(flex: 2, child: Text('#TXN-${bill.billNumber}',
            style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 12))),
        Expanded(child: Text(bill.customerName ?? 'Walk-in',
            style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11), overflow: TextOverflow.ellipsis)),
        Text('₹${bill.total.toStringAsFixed(0)}',
            style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: (isCompleted ? AppColors.success : AppColors.warning).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(isCompleted ? 'DONE' : 'PENDING',
              style: GoogleFonts.inter(color: isCompleted ? AppColors.success : AppColors.warning, fontSize: 9, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}
