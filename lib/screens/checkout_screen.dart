// lib/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../models/product_model.dart';
import '../services/database_service.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cart;
  final double subtotal;
  final double tax;
  final double total;
  final VoidCallback onSuccess;

  const CheckoutScreen({
    super.key,
    required this.cart,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.onSuccess,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _paymentMethod = 'cash';
  bool _isProcessing = false;
  final _customerNameCtrl = TextEditingController();
  final _customerPhoneCtrl = TextEditingController();

  Future<void> _completeSale() async {
    setState(() => _isProcessing = true);
    try {
      final bill = await DatabaseService.createBill(
        items: widget.cart,
        subtotal: widget.subtotal,
        tax: widget.tax,
        discount: 0,
        total: widget.total,
        paymentMethod: _paymentMethod,
        customerName: _customerNameCtrl.text.isNotEmpty ? _customerNameCtrl.text : null,
        customerPhone: _customerPhoneCtrl.text.isNotEmpty ? _customerPhoneCtrl.text : null,
      );
      widget.onSuccess();
      if (mounted) {
        Navigator.pop(context);
        _showSuccessDialog(bill.billNumber);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSuccessDialog(int billNo) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 64),
          const SizedBox(height: 16),
          Text('Sale Complete! 🎉', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Bill #$billNo', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14)),
          Text('₹${widget.total.toStringAsFixed(2)} received', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          KiranaPrimaryButton(label: 'New Sale', icon: Icons.add, onPressed: () => Navigator.pop(context)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: KiranaAppBar(title: 'Checkout', showNotification: false,
          leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary), onPressed: () => Navigator.pop(context))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Bill summary
          KiranaCard(
            child: Column(children: [
              Text('Bill Summary', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 12),
              ...widget.cart.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(children: [
                  Expanded(child: Text('${item.product.name} × ${item.quantity}', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13))),
                  Text('₹${item.total.toStringAsFixed(2)}', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13)),
                ]),
              )),
              const Divider(color: Color(0xFF1E3028)),
              _row('Subtotal', '₹${widget.subtotal.toStringAsFixed(2)}'),
              _row('Tax (5%)', '₹${widget.tax.toStringAsFixed(2)}'),
              const SizedBox(height: 4),
              Row(children: [
                Text('TOTAL', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 18)),
                const Spacer(),
                Text('₹${widget.total.toStringAsFixed(2)}', style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 22)),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          // Customer info (optional)
          KiranaCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Customer (Optional)', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 12),
              TextField(controller: _customerNameCtrl, style: GoogleFonts.inter(color: AppColors.textPrimary),
                  decoration: const InputDecoration(hintText: 'Customer name', prefixIcon: Icon(Icons.person_outline, color: AppColors.textMuted, size: 18))),
              const SizedBox(height: 10),
              TextField(controller: _customerPhoneCtrl, keyboardType: TextInputType.phone, style: GoogleFonts.inter(color: AppColors.textPrimary),
                  decoration: const InputDecoration(hintText: 'Phone number', prefixIcon: Icon(Icons.phone_outlined, color: AppColors.textMuted, size: 18))),
            ]),
          ),
          const SizedBox(height: 16),
          // Payment method
          KiranaCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Payment Method', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 12),
              Row(children: [
                _payBtn('cash', Icons.payments_outlined, 'Cash'),
                const SizedBox(width: 10),
                _payBtn('upi', Icons.phone_android_outlined, 'UPI'),
                const SizedBox(width: 10),
                _payBtn('card', Icons.credit_card_outlined, 'Card'),
              ]),
            ]),
          ),
          const SizedBox(height: 24),
          KiranaPrimaryButton(
            label: _isProcessing ? 'Processing...' : 'Complete Sale ₹${widget.total.toStringAsFixed(0)}',
            icon: Icons.check_circle_outline,
            isLoading: _isProcessing,
            onPressed: _isProcessing ? () {} : _completeSale,
          ),
        ]),
      ),
    );
  }

  Widget _row(String l, String r) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [
      Text(l, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
      const Spacer(),
      Text(r, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13)),
    ]),
  );

  Widget _payBtn(String method, IconData icon, String label) {
    final selected = _paymentMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _paymentMethod = method),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withOpacity(0.15) : AppColors.bgSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? AppColors.primary : const Color(0xFF2A3D35), width: selected ? 1.5 : 1),
          ),
          child: Column(children: [
            Icon(icon, color: selected ? AppColors.primary : AppColors.textMuted, size: 22),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.inter(color: selected ? AppColors.primary : AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}
