import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'urun_guncelleme.dart'; // UrunGuncelleme sayfası import ediliyor

class KategoriIcerikSayfasi extends StatelessWidget {
  final String kategoriId;
  final String kategoriIsmi;
  final FirebaseAuth auth = FirebaseAuth.instance;

  KategoriIcerikSayfasi({
    Key? key,
    required this.kategoriId,
    required this.kategoriIsmi,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(kategoriIsmi),
        backgroundColor: Colors.deepPurple,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Kullanicilar')
            .doc(auth.currentUser?.uid)
            .collection('isletmeMenusu')
            .doc(kategoriId)
            .collection('urunler')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Bu kategoride henüz ürün eklenmemiş.'));
          }

          var urunler = snapshot.data!.docs;
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.75,
            ),
            itemCount: urunler.length,
            itemBuilder: (context, index) {
              var urun = urunler[index];
              String urunId = urun.id; // Ürün ID'sini aldık
              String urunIsmi = urun['urunIsmi'];
              String urunAciklamasi = urun['urunAciklamasi'];
              String urunFiyati = urun['urunFiyati'];
              String urunGorseli = urun['urunGorseli'];

              return GestureDetector(
                onTap: () {
                  // Ürün tıklanırsa, UrunGuncelleme sayfasına geçiş yapılır
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UrunGuncelleme(
                        kategoriId: kategoriId,
                        urunId: urunId,
                        urunIsmi: urunIsmi,
                        urunAciklamasi: urunAciklamasi,
                        urunFiyati: urunFiyati,
                        urunGorseli: urunGorseli,
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white,
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: urunGorseli.isNotEmpty
                                ? Image.network(
                              urunGorseli,
                              height: 200,
                              width: 205,
                              fit: BoxFit.cover,
                            )
                                : Icon(Icons.image, size: 80),
                          ),
                          Text(
                            urunIsmi,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            urunFiyati + ' ₺',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              urunAciklamasi,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
