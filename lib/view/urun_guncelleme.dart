import 'dart:io';
import 'package:cafe_adisyon/models/functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UrunGuncelleme extends StatefulWidget {
  final String kategoriId;
  final String urunId;
  final String urunIsmi;
  final String urunAciklamasi;
  final String urunFiyati;
  final String urunGorseli;

  const UrunGuncelleme({
    Key? key,
    required this.kategoriId,
    required this.urunId,
    required this.urunIsmi,
    required this.urunAciklamasi,
    required this.urunFiyati,
    required this.urunGorseli,
  }) : super(key: key);

  @override
  _UrunGuncellemeState createState() => _UrunGuncellemeState();
}

class _UrunGuncellemeState extends State<UrunGuncelleme> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final picker = ImagePicker();
  File? _selectedImage;

  late TextEditingController _urunIsmiController;
  late TextEditingController _urunAciklamaController;
  late TextEditingController _urunFiyatController;

  @override
  void initState() {
    super.initState();
    _urunIsmiController = TextEditingController(text: widget.urunIsmi);
    _urunAciklamaController = TextEditingController(text: widget.urunAciklamasi);
    _urunFiyatController = TextEditingController(text: widget.urunFiyati);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ürün Güncelleme'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return backgroundContainer(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _selectedImage != null
                    ? Image.file(_selectedImage!)
                    : Image.network(widget.urunGorseli, height: 200, fit: BoxFit.cover),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _urunResmiDegistir,
                  child: Text('Görseli Değiştir'),
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
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _urunGuncelle,
                  child: Text('Ürünü Güncelle'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  ),
                ),
                SizedBox(height: 30,),
                ElevatedButton(
                  onPressed: _urunSil,
                  child: Text('Ürünü Sil'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  Future<void> _urunResmiDegistir() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
      }
    });
  }

  Future<void> _urunGuncelle() async {
    String imageUrl = widget.urunGorseli;

    if (_selectedImage != null) {
      // Yeni görseli Firebase Storage'a yükle
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('menu_images/${auth.currentUser?.uid}/${widget.urunId}.jpg');
      await storageRef.putFile(_selectedImage!);
      imageUrl = await storageRef.getDownloadURL();
    }

    // Firestore'da ürün bilgilerini güncelle
    await FirebaseFirestore.instance
        .collection('Kullanicilar')
        .doc(auth.currentUser?.uid)
        .collection('isletmeMenusu')
        .doc(widget.kategoriId)
        .collection('urunler')
        .doc(widget.urunId)
        .update({
      "urunIsmi": _urunIsmiController.text,
      "urunAciklamasi": _urunAciklamaController.text,
      "urunFiyati": _urunFiyatController.text,
      "urunGorseli": imageUrl,
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Ürün başarıyla güncellendi!'),
    ));

    Navigator.pop(context); // Sayfayı kapat
  }

  Future<void> _urunSil() async {
    // Silme onayı için diyalog göster
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ürünü Sil'),
        content: Text('Bu ürünü silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // İptal butonuna basıldığında
            },
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Onay butonuna basıldığında
            },
            child: Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    // Kullanıcı silme işlemini onayladıysa ürünü sil
    if (confirmDelete == true) {
      await FirebaseFirestore.instance
          .collection('Kullanicilar')
          .doc(auth.currentUser?.uid)
          .collection('isletmeMenusu')
          .doc(widget.kategoriId)
          .collection('urunler')
          .doc(widget.urunId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Ürün başarıyla silindi!'),
      ));

      Navigator.pop(context); // Sayfayı kapat
    }
  }



}
