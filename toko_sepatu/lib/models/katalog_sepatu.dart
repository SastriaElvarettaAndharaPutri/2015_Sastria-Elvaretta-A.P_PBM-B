import 'package:cloud_firestore/cloud_firestore.dart';

class Shoe {
  final String id;
  final String brand;
  final double price;
  final String description;
  final String type;

  Shoe({
    required this.id,
    required this.brand,
    required this.price,
    required this.description,
    required this.type,
  });

  // Factory constructor untuk mengambil data dari Firestore
  factory Shoe.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Shoe(
      id: doc.id,
      brand: data['brand'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      description: data['description'] ?? '',
      type: data['type'] ?? '',
    );
  }

  // Konversi ke Map untuk simpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'brand': brand,
      'price': price,
      'description': description,
      'type': type,
    };
  }
}
