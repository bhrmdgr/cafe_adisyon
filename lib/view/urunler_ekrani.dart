import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UrunlerEkrani extends StatefulWidget {
  final String kategoriId;
  final Function(Map<String, dynamic>) onUrunSec;

  UrunlerEkrani({required this.kategoriId, required this.onUrunSec});

  @override
  State<UrunlerEkrani> createState() => _UrunlerEkraniState();
}

class _UrunlerEkraniState extends State<UrunlerEkrani> {
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ürünler'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _buildUrunler(),
    );
  }

  Widget _buildUrunler() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Kullanicilar')
          .doc(auth.currentUser?.uid)
          .collection('isletmeMenusu')
          .doc(widget.kategoriId)  // Tıklanan kategoriye ait ID
          .collection('urunler')  // Kategori altındaki ürünler
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var urunler = snapshot.data!.docs;
        return ListView.builder(
          itemCount: urunler.length,
          itemBuilder: (context, index) {
            var urun = urunler[index];
            String urunIsmi = urun['urunIsmi'];
            String urunFiyati = urun['urunFiyati'];
            String urunGorseli = urun['urunGorseli'];

            return GestureDetector(
              onTap: () {
                widget.onUrunSec({
                  'urunIsmi': urunIsmi,
                  'urunFiyati': urunFiyati,
                  'urunGorseli': urunGorseli,
                });
                Navigator.pop(context);
              },
              child: Card(
                child: ListTile(
                  leading: Image.network(urunGorseli),
                  title: Text(urunIsmi),
                  subtitle: Text('${urunFiyati}₺'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
