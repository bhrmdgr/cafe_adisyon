import 'package:cafe_adisyon/view/kategori_icerik_sayfasi.dart';
import 'package:cafe_adisyon/view/kategorileri_duzenle.dart';
import 'package:cafe_adisyon/view/menuye_ekle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/functions.dart'; // backgroundContainer burada tanımlı

class MenuyuDuzenle extends StatefulWidget {
  const MenuyuDuzenle({super.key});

  @override
  State<MenuyuDuzenle> createState() => _MenuyuDuzenleState();
}

class _MenuyuDuzenleState extends State<MenuyuDuzenle> {
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        "Menü",
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.deepPurple,
      actions: <Widget>[
        PopupMenuButton<String>(
          icon: Icon(
            Icons.list,
            color: Colors.white,
          ),
          onSelected: (String choice) {
            if (choice == 'Kategorileri Düzenle') {
              // Kategorileri Düzenle sayfasına git
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => KategorileriDuzenle(),
                ),
              );
            } else if (choice == 'Yeni Ürün Ekle') {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (context) => MenuyeEkle(),
            ),
              );
            }
          },
          itemBuilder: (BuildContext context) {
            return {'Kategorileri Düzenle', 'Yeni Ürün Ekle'}.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return backgroundContainer(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildCategoryGrid(), // Kategorileri yatayda listeleyen fonksiyon
            ),
          ],
        ),
      ),
    );
  }

  // Firestore'dan kategorileri çekip iki sütun şeklinde listeler
  Widget _buildCategoryGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Kullanicilar')
          .doc(auth.currentUser?.uid)
          .collection('isletmeMenusu')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Henüz kategori eklenmedi.'));
        }

        var kategoriler = snapshot.data!.docs;
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 sütun
            crossAxisSpacing: 10.0, // Sütunlar arası boşluk
            mainAxisSpacing: 10.0, // Satırlar arası boşluk
            childAspectRatio: 1, // Kartların en boy oranı (kare yapacak)
          ),
          itemCount: kategoriler.length,
          itemBuilder: (context, index) {
            var kategori = kategoriler[index];
            String kategoriIsmi = kategori['kategoriIsmi'];
            String kategoriGorseli = kategori['kategoriGorseli'];
            String kategoriId = kategori.id;

            return GestureDetector(
              onTap: () {
                _navigateToCategoryDetails(context, kategoriId, kategoriIsmi);
              },
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        // Kategori Görseli
                          child :kategoriGorseli.isNotEmpty
                              ? Image.network(
                            kategoriGorseli,
                            height: 180,
                            width: 205,
                            fit: BoxFit.fitHeight,
                          )
                              : Icon(Icons.image, size: 80),
                      ),

                      Text(
                        kategoriIsmi,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
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

  // Kategori içeriğine yönlendirme fonksiyonu
  void _navigateToCategoryDetails(BuildContext context, String kategoriId, String kategoriIsmi) {
    // Burada kategori içeriği sayfasına yönlendirme yapılacak
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KategoriIcerikSayfasi(kategoriId: kategoriId, kategoriIsmi: kategoriIsmi),
      ),
    );
  }
}


