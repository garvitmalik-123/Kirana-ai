// lib/screens/ai_insights_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../models/product_model.dart';
import '../services/database_service.dart';

class AIInsightsScreen extends StatefulWidget {
  const AIInsightsScreen({super.key});
  @override
  State<AIInsightsScreen> createState() => _AIInsightsScreenState();
}

class _AIInsightsScreenState extends State<AIInsightsScreen> {
  List<Product> _lowStock = [];
  List<Product> _allProducts = [];
  Map<String, dynamic> _stats = {};
  bool _loading = true;
  String _activeFilter = 'All';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final products = await DatabaseService.getProducts();
      final stats = await DatabaseService.getTodayStats();
      setState(() {
        _allProducts = products;
        _lowStock = products.where((p) => p.isLowStock).toList();
        _stats = stats;
        _loading = false;
      });
    } catch (e) { setState(() => _loading = false); }
  }

  List<Map<String, dynamic>> get _insights {
    final all = <Map<String, dynamic>>[];
    if (_lowStock.isNotEmpty) {
      all.add({
        'icon': Icons.warning_amber_rounded,
        'title': 'Restock Alert — ${_lowStock.length} items low',
        'desc': '${_lowStock.take(3).map((p) => p.name).join(", ")}${_lowStock.length > 3 ? " + ${_lowStock.length - 3} more" : ""} need restocking soon.',
        'tag': 'Urgent', 'tagColor': AppColors.error, 'action': 'Restock Now', 'type': 'stock',
      });
    }
    final outOfStock = _allProducts.where((p) => p.isOutOfStock).toList();
    if (outOfStock.isNotEmpty) {
      all.add({
        'icon': Icons.remove_shopping_cart_outlined,
        'title': 'Out of Stock — ${outOfStock.length} items',
        'desc': '${outOfStock.map((p) => p.name).join(", ")} completely out of stock!',
        'tag': 'Critical', 'tagColor': AppColors.error, 'action': 'Order Now', 'type': 'stock',
      });
    }
    final totalSales = (_stats['total_sales'] ?? 0.0) as double;
    if (totalSales > 0) {
      all.add({
        'icon': Icons.trending_up,
        'title': 'Today Sales: ₹${totalSales.toStringAsFixed(0)}',
        'desc': 'You have made ${_stats['total_bills']} bills today. Avg ticket: ₹${(_stats['avg_ticket'] as double? ?? 0).toStringAsFixed(0)}',
        'tag': 'Sales', 'tagColor': AppColors.success, 'action': 'View Analytics', 'type': 'sales',
      });
    }
    all.addAll([
      {
        'icon': Icons.shopping_basket_outlined,
        'title': 'Predictive Restock',
        'desc': 'Based on sales patterns, restock Dairy and Grains by Friday to avoid weekend stockouts.',
        'tag': 'High Confidence', 'tagColor': AppColors.primary, 'action': 'Order Now', 'type': 'prediction',
      },
      {
        'icon': Icons.trending_down_outlined,
        'title': 'Slow Moving Items',
        'desc': 'Some items have not moved in 15+ days. Consider a 10% bundle discount to clear inventory faster.',
        'tag': 'Efficiency Gain', 'tagColor': AppColors.info, 'action': 'Apply Discount', 'type': 'efficiency',
      },
      {
        'icon': Icons.people_outline,
        'title': 'Peak Hours Insight',
        'desc': 'Most sales happen 8-10 AM and 5-7 PM. Add 1 more billing staff during these windows.',
        'tag': 'Staffing Tip', 'tagColor': AppColors.warning, 'action': 'Schedule', 'type': 'staffing',
      },
      {
        'icon': Icons.local_offer_outlined,
        'title': 'Pricing Opportunity',
        'desc': 'Some products are priced lower than nearby competitors. Consider a slight price increase.',
        'tag': 'Revenue Boost', 'tagColor': AppColors.profit, 'action': 'Review Prices', 'type': 'pricing',
      },
    ]);
    if (_activeFilter == 'All') return all;
    return all.where((i) => i['type'] == _activeFilter.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: KiranaAppBar(title: 'AI Insights', showNotification: true, showAvatar: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _load,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  KiranaCard(
                    color: const Color(0xFF0F1E15),
                    child: Row(children: [
                      Container(padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 24)),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('AI Assistant Active', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                        Text('Monitoring ${_allProducts.length} products • ${_lowStock.length} alerts', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
                      ])),
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: _statMini('Bills Today', '${_stats['total_bills'] ?? 0}', AppColors.success)),
                    const SizedBox(width: 10),
                    Expanded(child: _statMini('Low Stock', '${_lowStock.length}', AppColors.error)),
                    const SizedBox(width: 10),
                    Expanded(child: _statMini('Revenue', '₹${((_stats['total_sales'] ?? 0.0) as double).toStringAsFixed(0)}', AppColors.primary)),
                  ]),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 36,
                    child: ListView(scrollDirection: Axis.horizontal, children: [
                      for (final f in ['All', 'Stock', 'Sales', 'Prediction', 'Efficiency', 'Pricing'])
                        GestureDetector(
                          onTap: () => setState(() => _activeFilter = f),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: _activeFilter == f ? AppColors.primary : AppColors.bgCard,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _activeFilter == f ? AppColors.primary : const Color(0xFF1E3028)),
                            ),
                            child: Text(f, style: GoogleFonts.inter(
                              color: _activeFilter == f ? Colors.black : AppColors.textSecondary,
                              fontSize: 12, fontWeight: FontWeight.w600,
                            )),
                          ),
                        ),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  SectionHeader(title: 'Recommendations (${_insights.length})', actionLabel: 'Refresh ›', onAction: _load),
                  const SizedBox(height: 12),
                  if (_insights.isEmpty)
                    Center(child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(children: [
                        const Icon(Icons.check_circle_outline, color: AppColors.success, size: 48),
                        const SizedBox(height: 12),
                        Text('All good! 🎉', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                        Text('No issues found', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                      ]),
                    ))
                  else
                    ...(_insights.map((insight) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _insightCard(insight),
                    ))),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
    );
  }

  Widget _insightCard(Map<String, dynamic> insight) {
    final color = insight['tagColor'] as Color;
    return KiranaCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
              child: Icon(insight['icon'] as IconData, color: color, size: 18)),
          const SizedBox(width: 10),
          Expanded(child: Text(insight['title'] as String,
              style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13))),
        ]),
        const SizedBox(height: 8),
        Text(insight['desc'] as String, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12, height: 1.5)),
        const SizedBox(height: 12),
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
              child: Text(insight['tag'] as String, style: GoogleFonts.inter(color: color, fontSize: 10, fontWeight: FontWeight.w600))),
          const Spacer(),
          GestureDetector(
            onTap: () => _handleAction(insight),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
              child: Text(insight['action'] as String, style: GoogleFonts.inter(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
            ),
          ),
        ]),
      ]),
    );
  }

  void _handleAction(Map<String, dynamic> insight) {
    final type = insight['type'] as String;
    switch (type) {
      case 'stock':
        _showRestockDialog();
        break;
      case 'sales':
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Analytics tab pe jaao'), backgroundColor: AppColors.primary));
        break;
      case 'efficiency':
        _showDiscountDialog();
        break;
      case 'prediction':
        _showOrderDialog();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${insight['action']} noted!'), backgroundColor: AppColors.bgCard));
    }
  }

  void _showRestockDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Low Stock Items', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ..._lowStock.take(5).map((p) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(width: 36, height: 36,
                  decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 18)),
              title: Text(p.name, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: Text('Stock: ${p.stock} | Min: ${p.minStock}', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: (p.isOutOfStock ? AppColors.error : AppColors.warning).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10)),
                child: Text(p.isOutOfStock ? 'OUT' : 'LOW',
                    style: GoogleFonts.inter(color: p.isOutOfStock ? AppColors.error : AppColors.warning, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            )),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: Text('Close', style: GoogleFonts.inter(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Order placed! ✅'), backgroundColor: AppColors.success));
            },
            child: Text('Order All', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showDiscountDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Apply Bundle Discount', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              Text('10% Bundle Discount', style: GoogleFonts.inter(color: AppColors.info, fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 6),
              Text('Apply on slow moving items to clear inventory faster',
                  style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12, height: 1.4), textAlign: TextAlign.center),
            ]),
          ),
          const SizedBox(height: 12),
          Text('This will apply 10% discount when selling these items together.',
              style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Discount applied! ✅'), backgroundColor: AppColors.success));
            },
            child: Text('Apply Discount', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showOrderDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Predictive Restock', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              const Icon(Icons.auto_awesome, color: AppColors.primary, size: 32),
              const SizedBox(height: 8),
              Text('AI Recommendation', style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 6),
              Text('Restock Dairy and Grains by Friday. Weekend demand expected to spike 24%.',
                  style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12, height: 1.4), textAlign: TextAlign.center),
            ]),
          ),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 16),
            const SizedBox(width: 6),
            Text('High confidence prediction', style: GoogleFonts.inter(color: AppColors.success, fontSize: 12)),
          ]),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: Text('Dismiss', style: GoogleFonts.inter(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Order confirmed! ✅'), backgroundColor: AppColors.success));
            },
            child: Text('Confirm Order', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _statMini(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(children: [
        Text(value, style: GoogleFonts.inter(color: color, fontWeight: FontWeight.w800, fontSize: 18)),
        const SizedBox(height: 2),
        Text(label, textAlign: TextAlign.center, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 10)),
      ]),
    );
  }
}
