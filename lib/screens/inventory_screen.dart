// lib/screens/inventory_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../models/product_model.dart';
import '../services/database_service.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Product> _products = [];
  List<Product> _lowStock = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final p = await DatabaseService.getProducts();
      setState(() { _products = p; _lowStock = p.where((x) => x.isLowStock).toList(); _loading = false; });
    } catch (e) { setState(() => _loading = false); }
  }

  int get highTurnover => _products.where((p) => p.stock > p.minStock * 3).length;
  int get slowMoving => _products.where((p) => p.stock > p.minStock && p.stock < p.minStock * 3).length;
  int get outOfStock => _products.where((p) => p.isOutOfStock).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: KiranaAppBar(title: 'Kirana AI', showNotification: true, showAvatar: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProduct(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _load,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('INTELLIGENT OVERSIGHT', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                  const SizedBox(height: 4),
                  Text('Inventory\nAssistant', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 30, fontWeight: FontWeight.w800, height: 1.1)),
                  const SizedBox(height: 16),
                  Row(children: [
                    _actionBtn(Icons.download_outlined, 'Export\nReport', false, _exportReport),
                    const SizedBox(width: 12),
                    _actionBtn(Icons.add, 'Add\nItem', true, _showAddProduct),
                  ]),
                  const SizedBox(height: 20),
                  // Health Score
                  KiranaCard(
                    child: Column(children: [
                      Row(children: [
                        Text('Health Score', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                        const Spacer(),
                        const Icon(Icons.health_and_safety_outlined, color: AppColors.primary, size: 20),
                      ]),
                      const SizedBox(height: 16),
                      HealthScoreWidget(score: _products.isEmpty ? 0 : ((1 - outOfStock / _products.length) * 100).clamp(0, 100)),
                      const SizedBox(height: 12),
                      Text(_products.isEmpty ? 'Loading...' : 'You have ${_products.length} products.\n${outOfStock} out of stock.',
                          textAlign: TextAlign.center, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  // Inventory Health
                  KiranaCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text('Inventory Health', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                        const Spacer(),
                        Text('Details', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 13)),
                      ]),
                      const SizedBox(height: 16),
                      InventoryProgressBar(label: 'High Turnover', percent: _products.isEmpty ? 0 : highTurnover / _products.length, color: AppColors.success),
                      InventoryProgressBar(label: 'Slow Moving', percent: _products.isEmpty ? 0 : slowMoving / _products.length, color: AppColors.warning),
                      InventoryProgressBar(label: 'Out of Stock', percent: _products.isEmpty ? 0 : outOfStock / _products.length, color: AppColors.error),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  // Stock Alerts
                  if (_lowStock.isNotEmpty) ...[
                    KiranaCard(
                      child: Column(children: [
                        Row(children: [
                          Container(padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: AppColors.error.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 18)),
                          const SizedBox(width: 10),
                          Text('Stock Alerts', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                          const Spacer(),
                          Text('${_lowStock.length} items', style: GoogleFonts.inter(color: AppColors.error, fontSize: 12)),
                        ]),
                        const SizedBox(height: 12),
                        ..._lowStock.take(5).map((p) => Column(children: [
                          const Divider(color: Color(0xFF1E3028)),
                          StockAlertTile(
                            name: p.name,
                            status: p.isOutOfStock ? 'Out of stock' : 'Only ${p.stock} left in stock',
                            statusColor: p.isOutOfStock ? AppColors.error : AppColors.warning,
                          ),
                        ])),
                      ]),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // All Products
                  SectionHeader(title: 'All Products (${_products.length})', actionLabel: 'Add New', onAction: _showAddProduct),
                  const SizedBox(height: 12),
                  ..._products.map((p) => _productTile(p)),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
    );
  }

  Widget _productTile(Product p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1E3028))),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.inventory_2_outlined, color: AppColors.textMuted, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p.name, style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
          Text('SKU: ${p.sku ?? "-"} • ${p.category ?? ""}', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('₹${p.price.toStringAsFixed(2)}', style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: (p.isOutOfStock ? AppColors.error : p.isLowStock ? AppColors.warning : AppColors.success).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: Text('${p.stock} ${p.unit ?? ""}',
                  style: GoogleFonts.inter(color: p.isOutOfStock ? AppColors.error : p.isLowStock ? AppColors.warning : AppColors.success, fontSize: 10, fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(width: 8),
        GestureDetector(onTap: () => _showEditProduct(p),
            child: const Icon(Icons.edit_outlined, color: AppColors.textMuted, size: 18)),
      ]),
    );
  }

  Widget _actionBtn(IconData icon, String label, bool isPrimary, VoidCallback onTap) {
    return GestureDetector(onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: isPrimary ? AppColors.primary : AppColors.bgCard, borderRadius: BorderRadius.circular(12),
            border: isPrimary ? null : Border.all(color: const Color(0xFF1E3028))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: isPrimary ? Colors.black : AppColors.textSecondary, size: 16),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.inter(color: isPrimary ? Colors.black : AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
        ]),
      ),
    );
  }


  Future<void> _exportReport() async {
    try {
      final products = _products;
      final buffer = StringBuffer();
      buffer.writeln('Name,SKU,Category,Price,Stock,Min Stock,Status');
      for (final p in products) {
        final status = p.isOutOfStock ? 'Out of Stock' : p.isLowStock ? 'Low Stock' : 'OK';
        buffer.writeln('${p.name},${p.sku ?? ""},${p.category ?? ""},${p.price},${p.stock},${p.minStock},$status');
      }
      // Show CSV in dialog for copying
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.bgCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Export Report', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
            content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${products.length} products exported', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(10)),
                child: SingleChildScrollView(
                  child: Text(buffer.toString(), style: GoogleFonts.inter(color: AppColors.primary, fontSize: 10)),
                ),
              ),
              const SizedBox(height: 8),
              Text('Copy the CSV data above', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11)),
            ]),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Close', style: GoogleFonts.inter(color: AppColors.textSecondary))),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report ready! ✅'), backgroundColor: AppColors.success));
                },
                child: Text('Done', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e'), backgroundColor: AppColors.error));
    }
  }

  void _showAddProduct() {
    _showProductForm(null);
  }

  void _showEditProduct(Product p) {
    _showProductForm(p);
  }

  void _showProductForm(Product? existing) {
    final nameCtrl = TextEditingController(text: existing?.name);
    final priceCtrl = TextEditingController(text: existing?.price.toString());
    final stockCtrl = TextEditingController(text: existing?.stock.toString());
    final skuCtrl = TextEditingController(text: existing?.sku);
    final categoryCtrl = TextEditingController(text: existing?.category);
    final barcodeCtrl = TextEditingController(text: existing?.barcode);

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text(existing == null ? 'Add Product' : 'Edit Product',
              style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _formField(nameCtrl, 'Product Name', Icons.shopping_bag_outlined),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _formField(priceCtrl, 'Price (Rs.)', Icons.currency_rupee, type: TextInputType.number)),
            const SizedBox(width: 10),
            Expanded(child: _formField(stockCtrl, 'Stock', Icons.inventory_2_outlined, type: TextInputType.number)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _formField(skuCtrl, 'SKU', Icons.tag)),
            const SizedBox(width: 10),
            Expanded(child: _formField(categoryCtrl, 'Category', Icons.category_outlined)),
          ]),
          const SizedBox(height: 10),
          _formField(barcodeCtrl, 'Barcode (optional)', Icons.qr_code),
          const SizedBox(height: 16),
          Row(children: [
            if (existing != null) ...[
              Expanded(child: OutlinedButton(
                onPressed: () async {
                  await DatabaseService.deleteProduct(existing.id);
                  Navigator.pop(context); _load();
                },
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error), foregroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Delete'),
              )),
              const SizedBox(width: 10),
            ],
            Expanded(flex: 2, child: ElevatedButton(
              onPressed: () async {
                final data = {
                  'name': nameCtrl.text, 'price': double.tryParse(priceCtrl.text) ?? 0,
                  'stock': int.tryParse(stockCtrl.text) ?? 0, 'sku': skuCtrl.text.isEmpty ? null : skuCtrl.text,
                  'category': categoryCtrl.text.isEmpty ? null : categoryCtrl.text,
                  'barcode': barcodeCtrl.text.isEmpty ? null : barcodeCtrl.text,
                };
                if (existing == null) { await DatabaseService.addProduct(data); }
                else { await DatabaseService.updateProduct(existing.id, data); }
                Navigator.pop(context); _load();
              },
              child: Text(existing == null ? 'Add Product' : 'Save Changes'),
            )),
          ]),
        ]),
      ),
    );
  }

  Widget _formField(TextEditingController ctrl, String hint, IconData icon, {TextInputType? type}) {
    return TextField(controller: ctrl, keyboardType: type, style: GoogleFonts.inter(color: AppColors.textPrimary),
        decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, color: AppColors.textMuted, size: 16)));
  }
}
