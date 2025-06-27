import 'package:cafe_adisyon/view/menu_ekrani.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GarsonEkran extends StatefulWidget {
  @override
  _GarsonEkranState createState() => _GarsonEkranState();
}

class _GarsonEkranState extends State<GarsonEkran> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String selectedMasa = '';
  List<Map<String, dynamic>> selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Masalar'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _buildMasalarGrid(),
    );
  }

  Widget _buildMasalarGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('Kullanicilar')
          .doc(auth.currentUser?.uid)
          .collection('Masalar')
          .orderBy('masaNumarasi', descending: false) // Masaları sırayla listele
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var masalar = snapshot.data!.docs;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: masalar.length,
          itemBuilder: (context, index) {
            var masa = masalar[index];

            // Masa verilerini doğru çekiyoruz
            Map<String, dynamic> masaData = masa.data() as Map<String, dynamic>;

            // 'siparisVerildi' alanının olup olmadığını kontrol ediyoruz
            bool masaDolu = masaData.containsKey('siparisVerildi')
                ? masaData['siparisVerildi']
                : false;


            String masaNumarasi = masaData['masaNumarasi'].toString();

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedMasa = masaNumarasi;
                });
                _navigateToMenu(context, masaNumarasi);  // Menüye geçiş
              },

              child: Card(
                color: masaDolu ? Colors.red : Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_seat, size: 50,color: Colors.grey,),
                      SizedBox(height: 5,),
                      Text(
                        'Masa $masaNumarasi',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToMenu(BuildContext context, String masaNumarasi) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MenuEkrani(masaNumarasi: masaNumarasi),
      ),
    );
  }

}
