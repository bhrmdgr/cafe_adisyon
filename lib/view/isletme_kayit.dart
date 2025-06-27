import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/functions.dart'; // functions.dart dosyasını import ediyoruz

class IsletmeKayit extends StatefulWidget {
  const IsletmeKayit({super.key});

  @override
  _IsletmeKayitState createState() => _IsletmeKayitState();
}

class _IsletmeKayitState extends State<IsletmeKayit> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _isletmeAdiController = TextEditingController();
  final TextEditingController _yoneticiAdiController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonController = TextEditingController();
  final TextEditingController _parolaController = TextEditingController();

  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('İşletme Kaydı'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _buildBody()
    );
  }

  Widget _buildBody(){
    return backgroundContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.business,
                size: 100,
                color: Colors.white,
              ),
              SizedBox(height: 20),
              Text(
                "İşletme Kaydı",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 40),
              _buildTextField(
                controller: _yoneticiAdiController,
                label: 'İşletme Yöneticisi İsmi',
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _isletmeAdiController,
                label: 'İşletme Adı',
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'E-posta',
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _telefonController,
                label: 'Telefon Numarası',
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _parolaController,
                label: 'Şifre',
                obscureText: true,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                    kayitOl();
                    girisEkranGec(context);

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'Kayıt Ol',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
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
        if (label == 'E-posta' && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Geçerli bir e-posta girin';
        }
        if (label == 'Şifre' && value.length < 6) {
          return 'Şifre en az 6 karakter olmalı';
        }
        return null;
      },
    );
  }

  Future<void> kayitOl() async{

    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: _emailController.text, password: _parolaController.text)
          .then((Kullanici) {
        FirebaseFirestore.instance
            .collection('Kullanicilar')
            .doc(auth.currentUser?.uid)
            .set({
          "yoneticiAdi": _yoneticiAdiController.text,
          "isletmeAdi": _isletmeAdiController.text,
          "ePosta": _emailController.text,
          "telefonNumarasi": _telefonController.text,
          "parola": _parolaController.text
        });
      }
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
           content: Text("Kayıt Başarıyla Gerçekleştirildi"),
         duration: Duration(
           seconds: 3
         ),
       ),
      );
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Kayıt Sırasında Bir Hata Oluştu!!!"),
                duration: Duration(seconds: 3)
        ),
      );

    }
  }
}
