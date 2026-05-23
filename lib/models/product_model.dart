// lib/models/product_model.dart
class Product {
  final String id;
  final String name;
  final String? nameHindi;
  final String? sku;
  final String? barcode;
  final double price;
  final double? costPrice;
  final int stock;
  final int minStock;
  final String? category;
  final String? unit;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    this.nameHindi,
    this.sku,
    this.barcode,
    required this.price,
    this.costPrice,
    required this.stock,
    this.minStock = 5,
    this.category,
    this.unit,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        nameHindi: json['name_hindi'],
        sku: json['sku'],
        barcode: json['barcode'],
        price: (json['price'] as num).toDouble(),
        costPrice: json['cost_price'] != null ? (json['cost_price'] as num).toDouble() : null,
        stock: json['stock'] ?? 0,
        minStock: json['min_stock'] ?? 5,
        category: json['category'],
        unit: json['unit'],
        imageUrl: json['image_url'],
      );

  bool get isLowStock => stock <= minStock;
  bool get isOutOfStock => stock == 0;
}

// Cart Item
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => product.price * quantity;
}

// Bill model
class Bill {
  final String id;
  final int billNumber;
  final String? customerName;
  final String? customerPhone;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
  final List<BillItem> items;

  Bill({
    required this.id,
    required this.billNumber,
    this.customerName,
    this.customerPhone,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.items = const [],
  });

  factory Bill.fromJson(Map<String, dynamic> json) => Bill(
        id: json['id'],
        billNumber: json['bill_number'] ?? 0,
        customerName: json['customer_name'],
        customerPhone: json['customer_phone'],
        subtotal: (json['subtotal'] as num).toDouble(),
        tax: (json['tax'] as num).toDouble(),
        discount: (json['discount'] as num? ?? 0).toDouble(),
        total: (json['total'] as num).toDouble(),
        paymentMethod: json['payment_method'] ?? 'cash',
        status: json['status'] ?? 'completed',
        createdAt: DateTime.parse(json['created_at']),
        items: [],
      );
}

class BillItem {
  final String billId;
  final String productName;
  final int quantity;
  final double price;
  final double total;

  BillItem({
    required this.billId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.total,
  });
}
