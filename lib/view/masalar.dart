import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'masa_detay_ekrani.dart';

class Masalar extends StatefulWidget {
  const Masalar({super.key});

  @override
  _MasalarState createState() => _MasalarState();
}

class _MasalarState extends State<Masalar> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _masaListesi = [];
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    _masalariGetir();
    super.initState();
  }

  // Veritabanından masaları getiriyoruz, her bir masa için sipariş durumu kontrol ediliyor
  Future<void> _masalariGetir() async {
    QuerySnapshot snapshot = await _firestore
        .collection('Kullanicilar')
        .doc(auth.currentUser?.uid)
        .collection('Masalar')
        .get();

    List<Map<String, dynamic>> masalar = snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return {
        'masaNumarasi': data['masaNumarasi'],
        // Eğer 'siparisVerildi' alanı null ya da yoksa false olarak ayarla
        'siparisVerildi': data.containsKey('siparisVerildi') ? data['siparisVerildi'] : false,
      };
    }).toList();

    // Masaları numaralarına göre sıralıyoruz
    masalar.sort((a, b) => (a['masaNumarasi'] as int).compareTo(b['masaNumarasi'] as int));

    setState(() {
      _masaListesi = masalar;
    });
  }



  // Her bir masa için bir kart oluşturuyoruz, sipariş verilmişse renk kırmızı
  Widget _buildMasaCard(Map<String, dynamic> masa) {
    bool siparisVerildi = masa['siparisVerildi'] as bool;
    int masaNumarasi = masa['masaNumarasi'] as int;

    return GestureDetector(
      onTap: () => _navigateToMasaDetay(masaNumarasi.toString()),
      // Masaya tıklayınca detaylara gitme
      child: Card(
        elevation: 5,
        color: siparisVerildi ? Colors.red : Colors.white, // Sipariş varsa kırmızı, yoksa beyaz
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_seat,
              size: 50,
              color: Colors.deepPurple,
            ),
            SizedBox(height: 10),
            Text(
              'Masa $masaNumarasi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Masanın detaylarına gitmek için kullanılan fonksiyon
  void _navigateToMasaDetay(String masaNumarasi) {
    // Burada sipariş detayları ya da başka bir sayfaya geçiş yapabilirsiniz
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MasaDetayEkrani(masaNumarasi: masaNumarasi)
      ),

    ).then((_){
      _masalariGetir();

    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Masalar'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // 4 sütunlu düzen
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _masaListesi.length,
                itemBuilder: (context, index) {
                  return _buildMasaCard(_masaListesi[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}
