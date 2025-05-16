import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class SepatuPage extends StatefulWidget {
  const SepatuPage({Key? key}) : super(key: key);

  @override
  _SepatuPageState createState() => _SepatuPageState();
}

class _SepatuPageState extends State<SepatuPage> {
  final FirestoreService _service = FirestoreService();
  late Future<List<Map<String, dynamic>>> _futureShoes;

  @override
  void initState() {
    super.initState();
    _refreshShoes();
  }

  void _refreshShoes() {
    _futureShoes = _service.getShoes();
  }

  void _showDialog({Map<String, dynamic>? data}) {
    final TextEditingController brand = TextEditingController(text: data?['brand']);
    final TextEditingController price = TextEditingController(text: data?['price']?.toString());
    final TextEditingController description = TextEditingController(text: data?['description']);
    final TextEditingController type = TextEditingController(text: data?['type']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(data == null ? 'Tambah Sepatu' : 'Edit Sepatu'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: brand, decoration: const InputDecoration(labelText: 'Brand')),
                TextField(
                  controller: price,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                TextField(controller: description, decoration: const InputDecoration(labelText: 'Description')),
                TextField(controller: type, decoration: const InputDecoration(labelText: 'Type')),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                brand.dispose();
                price.dispose();
                description.dispose();
                type.dispose();
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                final priceValue = double.tryParse(price.text) ?? 0.0;

                if (data == null) {
                  // Tambah data baru
                  await _service.addShoe(
                    brand.text,
                    priceValue,
                    description.text,
                    type.text,
                  );
                } else {
                  // Update data lama berdasarkan ID
                  final id = data['id'];
                  if (id != null) {
                    await _service.updateShoe(
                      id,
                      {
                        'brand': brand.text,
                        'price': priceValue,
                        'description': description.text,
                        'type': type.text,
                      },
                    );
                  }
                }

                brand.dispose();
                price.dispose();
                description.dispose();
                type.dispose();

                Navigator.pop(context);
                setState(() {
                  _futureShoes = _service.getShoes(); // refresh data
                });
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Katalog Sepatu')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureShoes,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final shoes = snapshot.data!;
          if (shoes.isEmpty) {
            return const Center(child: Text('Belum ada data sepatu'));
          }
          return ListView.builder(
            itemCount: shoes.length,
            itemBuilder: (context, index) {
              final shoe = shoes[index];
              return ListTile(
                title: Text(shoe['brand']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(shoe['description'] ?? ''),
                    Text('${shoe['type']} - Rp ${shoe['price']}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showDialog(data: shoe);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await _service.deleteShoe(shoe['id']);
                        setState(() {
                          _futureShoes = _service.getShoes();
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
