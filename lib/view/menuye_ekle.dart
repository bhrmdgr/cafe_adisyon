import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../models/functions.dart';

class MenuyeEkle extends StatefulWidget {
  const MenuyeEkle({super.key});

  @override
  _MenuyeEkleState createState() => _MenuyeEkleState();
}

class _MenuyeEkleState extends State<MenuyeEkle> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _urunIsmiController = TextEditingController();
  final TextEditingController _urunAciklamaController = TextEditingController();
  final TextEditingController _urunFiyatController = TextEditingController();

  File? _selectedImage;
  final picker = ImagePicker();
  final FirebaseAuth auth = FirebaseAuth.instance;

  String? _selectedKategoriId; // Seçilen kategori ID'si
  String? _selectedKategoriAdi; // Seçilen kategori ismi

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menüye Ekle'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return backgroundContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                "Kategori Seç",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              _buildKategoriDropdown(), // Kategori seçim dropdown'ı
              SizedBox(height: 30),
              Text(
                "Ürün Bilgileri",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _urunIsmiController,
                label: 'Ürün İsmi',
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _urunAciklamaController,
                label: 'Ürün Açıklaması',
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _urunFiyatController,
                label: 'Ürün Fiyatı',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              _selectedImage != null
                  ? Image.file(_selectedImage!) // Seçilen görseli ekranda gösterir
                  : Text(
                'Henüz ürün görseli seçilmedi',
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _urunResmiEkle, // Görsel seçme fonksiyonu
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Ürün Görseli Ekle',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && _selectedKategoriId != null) {
                    _menuyeEkle(); // Menüye ürün ekleme fonksiyonu
                    menuDuzenleGec(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lütfen bir kategori seçin ve formu doldurun')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Menüye Ekle',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Kategorileri listeleyen dropdown widget'ı
  Widget _buildKategoriDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Kullanicilar')
          .doc(auth.currentUser?.uid)
          .collection('isletmeMenusu')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var kategoriler = snapshot.data!.docs;

        return DropdownButtonFormField<String>(
          value: _selectedKategoriId,
          onChanged: (newValue) {
            setState(() {
              _selectedKategoriId = newValue;
              _selectedKategoriAdi = kategoriler
                  .firstWhere((kategori) => kategori.id == newValue)['kategoriIsmi'];
            });
          },
          items: kategoriler.map((kategori) {
            return DropdownMenuItem<String>(
              value: kategori.id,
              child: Text(kategori['kategoriIsmi'], style: TextStyle(color: Colors.black)),
            );
          }).toList(),
          hint: Text('Bir kategori seçin', style: TextStyle(color: Colors.white70)),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      style: TextStyle(color: Colors.white),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen $label girin';
        }
        return null;
      },
    );
  }

  Future<void> _urunResmiEkle() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
      } else {
        print('Resim seçilmedi');
      }
    });
  }

  Future<void> _menuyeEkle() async {
    if (_selectedImage != null && _selectedKategoriId != null) {
      // Firebase Storage'a resmi yükle
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('menu_images/${auth.currentUser?.uid}/${_urunIsmiController.text}.jpg');
      await storageRef.putFile(_selectedImage!);
      final imageUrl = await storageRef.getDownloadURL();

      // Firebase Firestore'a menü bilgilerini ekle
      await FirebaseFirestore.instance
          .collection('Kullanicilar')
          .doc(auth.currentUser?.uid)
          .collection('isletmeMenusu')
          .doc(_selectedKategoriId)
          .collection('urunler')
          .add({
        "urunIsmi": _urunIsmiController.text,
        "urunAciklamasi": _urunAciklamaController.text,
        "urunFiyati": _urunFiyatController.text,
        "urunGorseli": imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Ürün menüye eklendi!'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Lütfen bir ürün görseli ekleyin ve kategori seçin'),
      ));
    }
  }
}
