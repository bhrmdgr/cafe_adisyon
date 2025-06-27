import 'package:cafe_adisyon/view/urunler_ekrani.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MenuEkrani extends StatefulWidget {
  final String masaNumarasi;

  MenuEkrani({required this.masaNumarasi});

  @override
  _MenuEkraniState createState() => _MenuEkraniState();
}

class _MenuEkraniState extends State<MenuEkrani> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> sepet = [];
  FirebaseAuth auth = FirebaseAuth.instance;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Masa ${widget.masaNumarasi} - Menü'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(child: _buildKategoriler()), // Kategorileri listele
          Text("Sepet"),
          _buildSepet(), // Sepet gösterimi
          _buildSiparisListesi(), // Masanın tüm siparişlerini göster
          _buildToplamFiyat(), // Toplam fiyat gösterimi
          _buildSiparisVerButton(), // Sipariş ver butonu
        ],
      ),
    );
  }

  Widget _buildKategoriler() {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('Kullanicilar')
          .doc(auth.currentUser?.uid)
          .collection('isletmeMenusu')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var kategoriler = snapshot.data!.docs;
        return ListView.builder(
          itemCount: kategoriler.length,
          itemBuilder: (context, index) {
            var kategori = kategoriler[index];
            String kategoriIsmi = kategori['kategoriIsmi'];
            String kategoriGorseli = kategori['kategoriGorseli'];

            return GestureDetector(
              onTap: () => _navigateToUrunler(context, kategori.id),
              child: Card(
                child: ListTile(
                  leading: Image.network(kategoriGorseli),
                  title: Text(kategoriIsmi),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Ürünler sayfasına yönlendir
  void _navigateToUrunler(BuildContext context, String kategoriId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UrunlerEkrani(
          kategoriId: kategoriId,
          onUrunSec: _urunSepeteEkle,
        ),
      ),
    );
  }

  // Ürünü sepete ekle
  void _urunSepeteEkle(Map<String, dynamic> urun) {
    setState(() {
      sepet.add(urun);
    });
  }

  // Sepet gösterimi
  Widget _buildSepet() {
    return Expanded(
      child: ListView.builder(
        itemCount: sepet.length,
        itemBuilder: (context, index) {
          var urun = sepet[index];
          return ListTile(
            title: Text(urun['urunIsmi']),
            subtitle: Text('${urun['urunFiyati']}₺'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _sepettenCikar(index),
            ),
          );
        },
      ),
    );
  }

  // Ürünü sepetten çıkar
  void _sepettenCikar(int index) {
    setState(() {
      sepet.removeAt(index);
    });
  }

  // Toplam fiyatı hesapla ve göster
  Widget _buildToplamFiyat() {
    double toplamFiyat = 0;
    for (var urun in sepet) {
      toplamFiyat += double.tryParse(urun['urunFiyati'].toString()) ?? 0;
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Toplam Fiyat: ${toplamFiyat.toStringAsFixed(2)}₺',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Masanın önceki siparişlerini göster
  Widget _buildSiparisListesi() {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('Kullanicilar')
          .doc(auth.currentUser?.uid)
          .collection('Masalar')
          .doc(widget.masaNumarasi)
          .collection('Siparisler')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Bu masada henüz sipariş verilmedi.'));
        }

        var siparisler = snapshot.data!.docs;
        double toplamFiyat = 0;

        siparisler.forEach((siparis) {
          toplamFiyat += double.parse(siparis['urunFiyati'].toString());
        });

        return Column(
          children: [
            Text("Tüm Siparişler"),
            ListView.builder(
              shrinkWrap: true, // Listenin ekrandan taşmaması için
              itemCount: siparisler.length,
              itemBuilder: (context, index) {
                var siparis = siparisler[index];
                return ListTile(
                  title: Text(siparis['urunIsmi']),
                  subtitle: Text('${siparis['urunFiyati']}₺'),
                );
              },
            ),
            SizedBox(height: 10),
            Text(
              'Önceki Siparişlerin Toplam Fiyatı: ${toplamFiyat.toStringAsFixed(2)}₺',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }

  // Sipariş ver butonu
  Widget _buildSiparisVerButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: _siparisVer,
        child: Text('Sipariş Ver'),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
        ),
      ),
    );
  }

  // Sipariş ver işlemi
  Future<void> _siparisVer() async {
    if (sepet.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sepete bir şey eklenmedi!')),
      );
      return;
    }

    CollectionReference siparisRef = firestore
        .collection('Kullanicilar')
        .doc(auth.currentUser?.uid)
        .collection('Masalar')
        .doc(widget.masaNumarasi)
        .collection('Siparisler');

    for (var urun in sepet) {
      await siparisRef.add({
        'urunIsmi': urun['urunIsmi'],
        'urunFiyati': urun['urunFiyati'],
        'siparisTarihi': Timestamp.now(),
      });
    }

    await firestore
        .collection('Kullanicilar')
        .doc(auth.currentUser?.uid)
        .collection('Masalar')
        .doc(widget.masaNumarasi)
        .update({
      'siparisVerildi': true,
    });

    setState(() {
      sepet.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sipariş başarıyla verildi!')),
    );

    Navigator.pop(context);
  }
}
