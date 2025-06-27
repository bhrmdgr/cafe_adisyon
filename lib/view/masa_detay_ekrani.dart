import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MasaDetayEkrani extends StatefulWidget {
  final String masaNumarasi;

  MasaDetayEkrani({required this.masaNumarasi});

  @override
  State<MasaDetayEkrani> createState() => _MasaDetayEkraniState();
}

class _MasaDetayEkraniState extends State<MasaDetayEkrani> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Masa ${widget.masaNumarasi} Sipariş Detayları'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(child: _buildSiparisListesi()), // Sipariş listesini göster
          _buildToplamFiyat(), // Toplam fiyatı göster
          _buildOdemeAlButton(context), // Ödeme al butonu
        ],
      ),
    );
  }

  // Masanın önceki siparişlerini Firestore'dan çekip gösteren fonksiyon
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

        return ListView.builder(
          itemCount: siparisler.length,
          itemBuilder: (context, index) {
            var siparis = siparisler[index];
            return ListTile(
              title: Text(siparis['urunIsmi']),
              subtitle: Text('${siparis['urunFiyati']}₺'),
            );
          },
        );
      },
    );
  }

  // Toplam fiyatı hesaplayıp gösteren fonksiyon
  Widget _buildToplamFiyat() {
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
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Toplam Fiyat: 0₺',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          );
        }

        var siparisler = snapshot.data!.docs;
        double toplamFiyat = 0;

        siparisler.forEach((siparis) {
          toplamFiyat += double.parse(siparis['urunFiyati'].toString());
        });

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Toplam Fiyat: ${toplamFiyat.toStringAsFixed(2)}₺',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  // Ödeme al butonunu gösteren fonksiyon
  Widget _buildOdemeAlButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () async {
          await _odemeAl(context);
          setState(() {

          });

        },
        child: Text('Ödemeyi Al'),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
        ),
      ),
    );
  }

  // Ödeme al ve siparişleri silen fonksiyon
  Future<void> _odemeAl(BuildContext context) async {
    CollectionReference siparisRef = firestore
        .collection('Kullanicilar')
        .doc(auth.currentUser?.uid)
        .collection('Masalar')
        .doc(widget.masaNumarasi)
        .collection('Siparisler');

    // Siparişler koleksiyonunu temizle (sil)
    var siparisler = await siparisRef.get();
    for (var siparis in siparisler.docs) {
      await siparis.reference.delete();
    }

    // Masa sipariş durumu sıfırlanıyor
    await firestore
        .collection('Kullanicilar')
        .doc(auth.currentUser?.uid)
        .collection('Masalar')
        .doc(widget.masaNumarasi)
        .update({
      'siparisVerildi': false, // Masa boş olarak güncelleniyor
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ödeme alındı ve siparişler silindi!')),
    );

    Navigator.pop(context); // Geri dön
  }
}
