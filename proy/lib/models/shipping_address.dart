import 'package:mysql1/mysql1.dart';

class ShippingAddress {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? country;
  final String? state;
  final String? city;
  final String address;
  final int customerId;
  final bool isDefault;
  final String? zipCode;

  ShippingAddress({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.country,
    this.state,
    this.city,
    required this.address,
    required this.customerId,
    required this.isDefault,
    this.zipCode,
  });

  factory ShippingAddress.fromMap(Map<String, dynamic> map) {
    return ShippingAddress(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      country: map['country'] as String?,
      state: map['state'] as String?,
      city: map['city'] as String?,
      address: map['address'] as String,
      customerId: map['customer_id'] as int,
      isDefault: (map['is_default'] as int) == 1,
      zipCode: map['zip_code'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'country': country,
      'state': state,
      'city': city,
      'address': address,
      'customer_id': customerId,
      'is_default': isDefault ? 1 : 0,
      'zip_code': zipCode,
    };
  }
}
