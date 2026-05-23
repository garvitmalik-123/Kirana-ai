// lib/screens/pos_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../models/product_model.dart';
import '../services/database_service.dart';
import 'barcode_scanner_screen.dart';
import 'checkout_screen.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});
  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final List<CartItem> _cart = [];
  List<Product> _products = [];
  List<Product> _filtered = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();
  String _selectedCategory = 'All';
  List<String> _categories = ['All'];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchCtrl.addListener(_onSearch);
  }

  Future<void> _loadProducts() async {
    try {
      final p = await DatabaseService.getProducts();
      final cats = ['All', ...p.map((e) => e.category ?? 'Other').toSet().toList()..sort()];
      if (mounted) setState(() { _products = p; _filtered = p; _categories = cats; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _products.where((p) {
        final matchSearch = q.isEmpty || p.name.toLowerCase().contains(q) || (p.sku?.toLowerCase().contains(q) ?? false) || (p.nameHindi?.contains(q) ?? false);
        final matchCat = _selectedCategory == 'All' || p.category == _selectedCategory;
        return matchSearch && matchCat;
      }).toList();
    });
  }

  void _filterByCategory(String cat) {
    setState(() => _selectedCategory = cat);
    _onSearch();
  }

  void _addToCart(Product product) {
    setState(() {
      final idx = _cart.indexWhere((c) => c.product.id == product.id);
      if (idx >= 0) { _cart[idx].quantity++; }
      else { _cart.add(CartItem(product: product)); }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${product.name} added! ✅'),
      duration: const Duration(milliseconds: 800),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _openScanner() async {
    final barcode = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()));
    if (barcode != null && mounted) {
      final product = await DatabaseService.getProductByBarcode(barcode) ?? await DatabaseService.getProductBySku(barcode);
      if (product != null && mounted) {
        _addToCart(product);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product not found: $barcode'), backgroundColor: AppColors.error));
      }
    }
  }

  double get subtotal => _cart.fold(0, (s, e) => s + e.total);
  double get tax => subtotal * 0.05;
  double get total => subtotal + tax;

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: KiranaAppBar(title: 'Kirana AI', showSettings: true, showNotification: true),
      body: Column(children: [
        // Search + Scanner
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                style: GoogleFonts.inter(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Search items or SKU...',
                  prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 18),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _openScanner,
              child: Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.qr_code_scanner, color: Colors.black, size: 20),
              ),
            ),
          ]),
        ),

        // Category filter chips
        if (!_loading && _categories.length > 1)
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final selected = cat == _selectedCategory;
                return GestureDetector(
                  onTap: () => _filterByCategory(cat),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.bgCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? AppColors.primary : const Color(0xFF1E3028)),
                    ),
                    child: Text(cat, style: GoogleFonts.inter(
                      color: selected ? Colors.black : AppColors.textSecondary,
                      fontSize: 11, fontWeight: FontWeight.w600,
                    )),
                  ),
                );
              },
            ),
          ),

        const SizedBox(height: 8),

        // Products grid
        if (_loading)
          const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
        else if (_filtered.isEmpty)
          Expanded(child: Center(child: Text('No products found', style: GoogleFonts.inter(color: AppColors.textMuted))))
        else
          SizedBox(
            height: 200,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 0.55,
              ),
              itemCount: _filtered.length,
              itemBuilder: (_, i) => _productCard(_filtered[i]),
            ),
          ),

        // Divider
        const Divider(color: Color(0xFF1E3028), height: 1),

        // Cart
        Expanded(
          child: _cart.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.shopping_cart_outlined, color: AppColors.textMuted, size: 48),
                  const SizedBox(height: 12),
                  Text('Cart is empty', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14)),
                  Text('Tap any product to add', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
                ]))
              : Column(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                    child: Row(children: [
                      const Icon(Icons.shopping_cart_outlined, color: AppColors.primary, size: 18),
                      const SizedBox(width: 6),
                      Text('Current Bill', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                        child: Text('${_cart.length} items', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 11)),
                      ),
                    ]),
                  ),
                  Expanded(child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _cart.length,
                    itemBuilder: (_, i) => _cartTile(i),
                  )),
                ]),
        ),

        // Bottom bar
        if (_cart.isNotEmpty)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: const BoxDecoration(color: Color(0xFF101A15), border: Border(top: BorderSide(color: Color(0xFF1E3028)))),
            child: SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                Text('Subtotal', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                const Spacer(),
                Text('₹${subtotal.toStringAsFixed(2)}', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
              ]),
              Row(children: [
                Text('Tax (5%)', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                const Spacer(),
                Text('₹${tax.toStringAsFixed(2)}', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                Text('Grand Total', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('₹${total.toStringAsFixed(2)}', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: () => setState(() => _cart.clear()),
                  icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                  label: Text('Clear', style: GoogleFonts.inter(color: AppColors.error, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 13)),
                )),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutScreen(
                    cart: _cart, subtotal: subtotal, tax: tax, total: total,
                    onSuccess: () => setState(() => _cart.clear()),
                  ))),
                  icon: const Icon(Icons.payment, size: 16, color: Colors.black),
                  label: Text('Pay ₹${total.toStringAsFixed(0)}', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 15)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 13)),
                )),
              ]),
            ])),
          ),
      ]),
    );
  }

  Widget _productCard(Product p) {
    final inCart = _cart.any((c) => c.product.id == p.id);
    return GestureDetector(
      onTap: () => _addToCart(p),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: inCart ? AppColors.primary.withValues(alpha: 0.1) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: inCart ? AppColors.primary : const Color(0xFF1E3028), width: inCart ? 1.5 : 1),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.shopping_bag_outlined, color: inCart ? AppColors.primary : AppColors.textMuted, size: 22),
          const SizedBox(height: 4),
          Text(p.name, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 10, fontWeight: FontWeight.w600), maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text('₹${p.price.toStringAsFixed(0)}', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
          if (p.isLowStock)
            Text('Low', style: GoogleFonts.inter(color: AppColors.warning, fontSize: 9)),
        ]),
      ),
    );
  }

  Widget _cartTile(int i) {
    final item = _cart[i];
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF1E3028))),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.product.name, style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis),
          Text('₹${item.product.price.toStringAsFixed(2)} each', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11)),
        ])),
        Row(children: [
          _qBtn(Icons.remove, () => setState(() { if (item.quantity > 1) { item.quantity--; } else { _cart.removeAt(i); } })),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('${item.quantity}', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14))),
          _qBtn(Icons.add, () => setState(() => item.quantity++)),
        ]),
        const SizedBox(width: 10),
        Text('₹${item.total.toStringAsFixed(0)}', style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(width: 6),
        GestureDetector(onTap: () => setState(() => _cart.removeAt(i)), child: const Icon(Icons.close, color: AppColors.textMuted, size: 16)),
      ]),
    );
  }

  Widget _qBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(onTap: onTap,
      child: Container(width: 26, height: 26,
        decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFF2A3D35))),
        child: Icon(icon, color: AppColors.primary, size: 14)));
  }
}
