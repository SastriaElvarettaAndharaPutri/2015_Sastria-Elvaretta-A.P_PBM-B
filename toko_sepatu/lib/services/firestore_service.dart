import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getShoes() async {
    try {
      final snapshot = await _db.collection('toko_sepatu').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } on FirebaseException catch (e) {
      debugPrint('Firestore error (getShoes): ${e.message}');
      return []; // Kembalikan list kosong jika terjadi error
    } catch (e) {
      debugPrint('Unexpected error (getShoes): $e');
      return [];
    }
  }

  Future<void> addShoe(String brand, double price, String description, String type) async {
    try {
      await _db.collection('toko_sepatu').add({
        'brand': brand,
        'price': price,
        'description': description,
        'type': type,
      });
      debugPrint('Sepatu berhasil ditambahkan');
    } on FirebaseException catch (e) {
      debugPrint('Firestore error (addShoe): ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error (addShoe): $e');
    }
  }

  Future<void> updateShoe(String id, Map<String, dynamic> data) async {
  try {
    await _db.collection('toko_sepatu').doc(id).update(data);
    debugPrint('Sepatu berhasil diperbarui');
  } on FirebaseException catch (e) {
    debugPrint('Firestore error (updateShoe): ${e.message}');
  } catch (e) {
    debugPrint('Unexpected error (updateShoe): $e');
  }
}


  Future<void> deleteShoe(String id) async {
    try {
      await _db.collection('toko_sepatu').doc(id).delete();
      debugPrint('Sepatu berhasil dihapus');
    } on FirebaseException catch (e) {
      debugPrint('Firestore error (deleteShoe): ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error (deleteShoe): $e');
    }
  }
}
