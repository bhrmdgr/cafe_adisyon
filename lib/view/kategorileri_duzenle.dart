import 'dart:io';
import 'package:cafe_adisyon/models/functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class KategorileriDuzenle extends StatefulWidget {
  const KategorileriDuzenle({super.key});

  @override
  _KategorileriDuzenleState createState() => _KategorileriDuzenleState();
}

class _KategorileriDuzenleState extends State<KategorileriDuzenle> {
  final TextEditingController _kategoriIsmiController = TextEditingController();
  String? _selectedBirim; // Seçilen birim için bir değişken
  File? _selectedImage;
  final picker = ImagePicker();
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kategorileri Düzenle',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return backgroundContainer(
      child: Column(
        children: [
          Expanded(child: _buildCategoryList()), // Kategorileri listele
          _buildCategoryForm(), // Yeni kategori ekleme formu
        ],
      ),
    );
  }

  // Firestore'dan kategorileri çekip listeler
  Widget _buildCategoryList() {
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
          return Center(child: Text('Henüz kategori oluşturulmadı.'));
        }

        var kategoriler = snapshot.data!.docs;
        return ListView.builder(
          itemCount: kategoriler.length,
          itemBuilder: (context, index) {
            var kategori = kategoriler[index];
            String kategoriIsmi = kategori['kategoriIsmi'];
            String kategoriGorseli = kategori['kategoriGorseli'];
            String kategoriId = kategori.id; // Silme işlemi için belge ID'si

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                leading: kategoriGorseli.isNotEmpty
                    ? Image.network(
                  kategoriGorseli,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
                    : Icon(Icons.image, size: 50),
                title: Text(kategoriIsmi),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _confirmDelete(context, kategoriId); // Silme onayı
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Silme işlemi için onay diyaloğu
  Future<void> _confirmDelete(BuildContext context, String kategoriId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Silme Onayı'),
        content: Text('Bu kategoriyi silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            child: Text('İptal'),
            onPressed: () {
              Navigator.of(context).pop(); // Diyalogdan çık
            },
          ),
          TextButton(
            child: Text('Sil', style: TextStyle(color: Colors.red)),
            onPressed: () {
              _deleteCategory(kategoriId); // Kategori silme işlemi
              Navigator.of(context).pop(); // Diyalogdan çık
            },
          ),
        ],
      ),
    );
  }

  // Kategori silme fonksiyonu
  Future<void> _deleteCategory(String kategoriId) async {
    // İlgili kategoriyi Firestore'dan sil
    await FirebaseFirestore.instance
        .collection('Kullanicilar')
        .doc(auth.currentUser?.uid)
        .collection('isletmeMenusu')
        .doc(kategoriId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Kategori başarıyla silindi')),
    );
  }

  // Yeni kategori ekleme formu
  Widget _buildCategoryForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _selectedImage != null
              ? Image.file(
            _selectedImage!,
            height: 100,
            width: 100,
            fit: BoxFit.cover,
          )
              : Text('Henüz kategori görseli seçilmedi'),
          ElevatedButton(
            onPressed: _kategoriGorseliEkle,
            child: Text('Kategori Görseli Seç'),
          ),
          TextFormField(
            controller: _kategoriIsmiController,
            decoration: InputDecoration(
              labelText: 'Kategori İsmi',
            ),
          ),
          SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _selectedBirim,
            items: ['Mutfak', 'Bar']
                .map((birim) => DropdownMenuItem(
              value: birim,
              child: Text(birim),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedBirim = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Sorumlu Birim',
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _kategoriOlustur,
            child: Text('Kategori Oluştur'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }

  // Görsel seçme fonksiyonu
  Future<void> _kategoriGorseliEkle() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
      } else {
        print('Görsel seçilmedi');
      }
    });
  }

  // Yeni kategori oluşturma fonksiyonu
  Future<void> _kategoriOlustur() async {
    if (_kategoriIsmiController.text.isEmpty || _selectedImage == null || _selectedBirim == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen kategori ismi, görseli ve sorumlu birimi ekleyin')),
      );
      return;
    }

    // Kategori görselini Firebase Storage'a yükle
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('kategori_gorselleri/${auth.currentUser?.uid}/${_kategoriIsmiController.text}.jpg');
    await storageRef.putFile(_selectedImage!);
    final imageUrl = await storageRef.getDownloadURL();

    // Firestore'a kategori bilgilerini ekle
    await FirebaseFirestore.instance
        .collection('Kullanicilar')
        .doc(auth.currentUser?.uid)
        .collection('isletmeMenusu')
        .add({
      'kategoriIsmi': _kategoriIsmiController.text,
      'kategoriGorseli': imageUrl,
      'sorumluBirim': _selectedBirim, // Sorumlu birimi ekliyoruz
    });

    // Formu sıfırla
    _kategoriIsmiController.clear();
    setState(() {
      _selectedImage = null;
      _selectedBirim = null; // Seçilen birimi sıfırlıyoruz
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Kategori başarıyla oluşturuldu')),
    );
  }
}
