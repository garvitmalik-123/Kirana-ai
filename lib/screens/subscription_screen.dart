// lib/screens/subscription_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../services/supabase_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});
  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String _selectedPlan = 'pro';
  bool _isYearly = false;

  final _plans = [
    {
      'id': 'basic',
      'name': 'Basic',
      'monthlyPrice': 299,
      'yearlyPrice': 2499,
      'color': AppColors.info,
      'icon': Icons.store_outlined,
      'features': [
        '✅ POS & Billing',
        '✅ Upto 500 Products',
        '✅ 1 Employee Login',
        '✅ Basic Reports',
        '❌ AI Insights',
        '❌ Advanced Analytics',
      ],
    },
    {
      'id': 'pro',
      'name': 'Pro',
      'monthlyPrice': 599,
      'yearlyPrice': 4999,
      'color': AppColors.primary,
      'icon': Icons.auto_awesome_outlined,
      'features': [
        '✅ Everything in Basic',
        '✅ Unlimited Products',
        '✅ 5 Employee Logins',
        '✅ AI Insights',
        '✅ Advanced Analytics',
        '✅ Export Reports',
      ],
      'popular': true,
    },
    {
      'id': 'business',
      'name': 'Business',
      'monthlyPrice': 999,
      'yearlyPrice': 7999,
      'color': AppColors.profit,
      'icon': Icons.business_outlined,
      'features': [
        '✅ Everything in Pro',
        '✅ Unlimited Employees',
        '✅ Multi-store Support',
        '✅ Priority Support',
        '✅ Custom Reports',
        '✅ API Access',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Choose Plan', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary.withValues(alpha: 0.2), AppColors.bgCard],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Column(children: [
              const Icon(Icons.workspace_premium, color: AppColors.primary, size: 40),
              const SizedBox(height: 10),
              Text('Kirana AI Pro', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('30 days FREE trial — credit card nahi chahiye!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
            ]),
          ),
          const SizedBox(height: 20),

          // Monthly/Yearly toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1E3028))),
            child: Row(children: [
              Expanded(child: GestureDetector(
                onTap: () => setState(() => _isYearly = false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: !_isYearly ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('Monthly', textAlign: TextAlign.center,
                      style: GoogleFonts.inter(color: !_isYearly ? Colors.black : AppColors.textSecondary, fontWeight: FontWeight.w700)),
                ),
              )),
              Expanded(child: GestureDetector(
                onTap: () => setState(() => _isYearly = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _isYearly ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Yearly', style: GoogleFonts.inter(color: _isYearly ? Colors.black : AppColors.textSecondary, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                      child: Text('30% OFF', style: GoogleFonts.inter(color: AppColors.success, fontSize: 9, fontWeight: FontWeight.w700)),
                    ),
                  ]),
                ),
              )),
            ]),
          ),
          const SizedBox(height: 16),

          // Plans
          ..._plans.map((plan) => _planCard(plan)),
          const SizedBox(height: 16),

          // Pay button
          KiranaPrimaryButton(
            label: 'Start Free Trial — 30 Days',
            icon: Icons.arrow_forward,
            onPressed: () => _startPayment(),
          ),
          const SizedBox(height: 12),

          // Trust badges
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _badge(Icons.lock_outline, 'Secure'),
            const SizedBox(width: 20),
            _badge(Icons.refresh, 'Cancel Anytime'),
            const SizedBox(width: 20),
            _badge(Icons.support_agent, '24/7 Support'),
          ]),
          const SizedBox(height: 20),

          // FAQ
          KiranaCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Frequently Asked Questions', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 12),
              _faq('What happens after trial?', 'After 30 days aapko plan choose karna hoga. No automatic charges.'),
              _faq('Is my data safe?', 'Yes! Supabase encrypted database use karta hai.'),
              _faq('Can I get a refund?', 'Yes, full refund within 7 days.'),
              _faq('How many devices can I use?', 'Web browser — open on any device!'),
            ]),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _planCard(Map<String, dynamic> plan) {
    final isSelected = _selectedPlan == plan['id'];
    final color = plan['color'] as Color;
    final price = _isYearly ? plan['yearlyPrice'] as int : plan['monthlyPrice'] as int;
    final isPOPULAR = plan['popular'] == true;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = plan['id'] as String),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? color : const Color(0xFF1E3028), width: isSelected ? 2 : 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: Icon(plan['icon'] as IconData, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Text(plan['name'] as String, style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
            const Spacer(),
            if (isPOPULAR)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
                child: Text('POPULAR', style: GoogleFonts.inter(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w800)),
              ),
          ]),
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('₹$price', style: GoogleFonts.inter(color: color, fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(_isYearly ? '/year' : '/month', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
            ),
            if (_isYearly) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                child: Text('Save ₹${(plan['monthlyPrice'] as int) * 12 - price}',
                    style: GoogleFonts.inter(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w600)),
              ),
            ],
          ]),
          const SizedBox(height: 12),
          ...(plan['features'] as List<String>).map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(f, style: GoogleFonts.inter(color: f.startsWith('✅') ? AppColors.textPrimary : AppColors.textMuted, fontSize: 12)),
          )),
          if (isSelected) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.check_circle, color: color, size: 14),
                const SizedBox(width: 6),
                Text('Selected', style: GoogleFonts.inter(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
              ]),
            ),
          ],
        ]),
      ),
    );
  }

  void _startPayment() {
    final plan = _plans.firstWhere((p) => p['id'] == _selectedPlan);
    final price = _isYearly ? plan['yearlyPrice'] as int : plan['monthlyPrice'] as int;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text('Payment', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('${plan['name']} Plan — ₹$price', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 24),
          // Payment methods
          _payMethodBtn(Icons.account_balance_outlined, 'UPI / GPay / PhonePe', AppColors.primary, () => _processPayment('UPI', price)),
          const SizedBox(height: 10),
          _payMethodBtn(Icons.credit_card_outlined, 'Credit / Debit Card', AppColors.info, () => _processPayment('Card', price)),
          const SizedBox(height: 10),
          _payMethodBtn(Icons.account_balance_wallet_outlined, 'Net Banking', AppColors.warning, () => _processPayment('NetBanking', price)),
          const SizedBox(height: 10),
          _payMethodBtn(Icons.payments_outlined, 'Cash / Offline', AppColors.success, () => _processPayment('Cash', price)),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.lock, color: AppColors.textMuted, size: 14),
            const SizedBox(width: 4),
            Text('Secured by Razorpay', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11)),
          ]),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  void _processPayment(String method, int amount) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 64),
          const SizedBox(height: 16),
          Text('Payment Successful! 🎉', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('₹$amount via $method', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 6),
          Text('Your plan has been activated!', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 13)),
          const SizedBox(height: 20),
          KiranaPrimaryButton(label: 'Continue', icon: Icons.arrow_forward, onPressed: () => Navigator.pop(context)),
        ]),
      ),
    );
  }

  Widget _payMethodBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
          const Spacer(),
          const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
        ]),
      ),
    );
  }

  Widget _badge(IconData icon, String label) {
    return Column(children: [
      Icon(icon, color: AppColors.textMuted, size: 18),
      const SizedBox(height: 4),
      Text(label, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 10)),
    ]);
  }

  Widget _faq(String q, String a) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(q, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
      iconColor: AppColors.primary,
      collapsedIconColor: AppColors.textMuted,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(a, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12, height: 1.5)),
        ),
      ],
    );
  }
}
