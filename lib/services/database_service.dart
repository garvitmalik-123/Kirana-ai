// lib/services/database_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import 'supabase_service.dart';

class DatabaseService {
  static SupabaseClient get _db => SupabaseService.client;

  // ─── PRODUCTS ──────────────────────────────────

  static Future<List<Product>> getProducts({String? search, String? category}) async {
    var query = _db.from('products').select();
    if (search != null && search.isNotEmpty) {
      query = query.or('name.ilike.%$search%,sku.ilike.%$search%,name_hindi.ilike.%$search%');
    }
    if (category != null && category != 'All') {
      query = query.eq('category', category);
    }
    final data = await query.order('name');
    return (data as List).map((e) => Product.fromJson(e)).toList();
  }

  static Future<Product?> getProductByBarcode(String barcode) async {
    final data = await _db.from('products').select().eq('barcode', barcode).maybeSingle();
    return data != null ? Product.fromJson(data) : null;
  }

  static Future<Product?> getProductBySku(String sku) async {
    final data = await _db.from('products').select().eq('sku', sku).maybeSingle();
    return data != null ? Product.fromJson(data) : null;
  }

  static Future<List<Product>> getLowStockProducts() async {
    final all = await _db.from('products').select().order('stock');
    return (all as List)
        .map((e) => Product.fromJson(e))
        .where((p) => p.stock <= p.minStock)
        .toList();
  }

  static Future<void> addProduct(Map<String, dynamic> data) async {
    await _db.from('products').insert(data);
  }

  static Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await _db.from('products').update(data).eq('id', id);
  }

  static Future<void> updateStock(String productId, int newStock) async {
    await _db.from('products').update({'stock': newStock}).eq('id', productId);
  }

  static Future<void> deleteProduct(String id) async {
    await _db.from('products').delete().eq('id', id);
  }

  // ─── BILLS ─────────────────────────────────────

  static Future<Bill> createBill({
    required List<CartItem> items,
    required double subtotal,
    required double tax,
    required double discount,
    required double total,
    required String paymentMethod,
    String? customerName,
    String? customerPhone,
  }) async {
    final billData = await _db.from('bills').insert({
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'total': total,
      'payment_method': paymentMethod,
      'status': 'completed',
      'created_by': SupabaseService.currentUser?.id,
    }).select().single();

    final bill = Bill.fromJson(billData);

    final billItems = items.map((item) => {
      'bill_id': bill.id,
      'product_id': item.product.id,
      'product_name': item.product.name,
      'quantity': item.quantity,
      'price': item.product.price,
      'total': item.total,
    }).toList();

    await _db.from('bill_items').insert(billItems);

    for (final item in items) {
      final newStock = item.product.stock - item.quantity;
      await updateStock(item.product.id, newStock < 0 ? 0 : newStock);
    }

    return bill;
  }

  static Future<List<Bill>> getRecentBills({int limit = 20}) async {
    final data = await _db
        .from('bills')
        .select()
        .order('created_at', ascending: false)
        .limit(limit);
    return (data as List).map((e) => Bill.fromJson(e)).toList();
  }

  // ─── ANALYTICS ─────────────────────────────────

  static Future<Map<String, dynamic>> getTodayStats() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();

    final bills = await _db
        .from('bills')
        .select()
        .gte('created_at', startOfDay)
        .eq('status', 'completed');

    final billList = bills as List;
    double totalSales = 0;
    final int totalBills = billList.length;

    for (final bill in billList) {
      totalSales += (bill['total'] as num).toDouble();
    }

    return {
      'total_sales': totalSales,
      'total_bills': totalBills,
      'avg_ticket': totalBills > 0 ? totalSales / totalBills : 0.0,
    };
  }

  static Future<List<Map<String, dynamic>>> getWeeklySales() async {
    final result = <Map<String, dynamic>>[];
    final now = DateTime.now();
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final start = DateTime(day.year, day.month, day.day).toIso8601String();
      final end = DateTime(day.year, day.month, day.day, 23, 59, 59).toIso8601String();

      final bills = await _db
          .from('bills')
          .select('total')
          .gte('created_at', start)
          .lte('created_at', end)
          .eq('status', 'completed');

      double total = 0;
      for (final b in bills as List) {
        total += (b['total'] as num).toDouble();
      }

      result.add({
        'day': dayNames[day.weekday - 1],
        'total': total,
      });
    }
    return result;
  }

  // ─── EMPLOYEES ─────────────────────────────────

  static Future<bool> verifyEmployeePin({
    required String shopId,
    required String employeeId,
    required String pin,
  }) async {
    try {
      // Get all active employees for this shop
      final data = await _db
          .from('employees')
          .select()
          .eq('is_active', true);
      
      final employees = data as List;
      
      for (final emp in employees) {
        final dbShopId = (emp['shop_id'] ?? '').toString().trim().toLowerCase();
        final dbMobile = (emp['mobile'] ?? '').toString().trim();
        final dbPin = (emp['pin'] ?? '').toString().trim();
        
        if (dbShopId == shopId.trim().toLowerCase() &&
            dbMobile == employeeId.trim() &&
            dbPin == pin.trim()) {
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
