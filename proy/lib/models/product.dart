import 'package:mysql1/mysql1.dart';

class Product {
  final int id;
  final String name;
  final String description;
  final String images;
  final double price;
  final String status;
  final int quantity;
  final bool isFeatured;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.price,
    required this.status,
    required this.quantity,
    required this.isFeatured,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int,
      name: map['name'] as String,
      description:
          map['description'] is Blob
              ? String.fromCharCodes((map['description'] as Blob).toBytes())
              : (map['description'] as String? ?? ''),
      images:
          map['images'] is Blob
              ? String.fromCharCodes((map['images'] as Blob).toBytes())
              : (map['images'] as String? ?? ''),
      price: (map['price'] as num).toDouble(),
      status: map['status'] as String,
      quantity: map['quantity'] as int,
      isFeatured: (map['is_featured'] as int) == 1,
    );
  }
}
