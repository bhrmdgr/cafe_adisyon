import 'package:cafe_adisyon/view/giris_secenek_ekran.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/functions.dart'; // functions.dart dosyasını import ediyoruz


class GirisEkran extends StatefulWidget {
  const GirisEkran({super.key});

  @override
  State<GirisEkran> createState() => _GirisEkranState();
}

class _GirisEkranState extends State<GirisEkran> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _parolaController = TextEditingController();

  String _errorMessage = '';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.coffee,
                  size: 150,
                  color: Colors.white,
                ),
                SizedBox(height: 20),
                Text(
                  "Cafemiz",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 80),
                _buildTextField(
                  controller: _emailController,
                  label: 'E-posta',
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _parolaController,
                  label: 'Şifre',
                  obscureText: true,
                ),
                SizedBox(height: 50),
                buildButton(
                  text: "İşletme Olarak Giriş Yap",
                  color: Colors.deepOrangeAccent,
                  onPressed: () {
                    _girisYap();
                  },
                ),
                SizedBox(height: 20),
                buildButton(
                  text: "İşletme Hesabı Oluştur",
                  color: Colors.greenAccent,
                  onPressed: () {
                    kayitEkranGec(context);
                  },
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _girisYap() async {

    try{
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
          email: _emailController.text, password: _parolaController.text
      );

      girisSecenekleriGec(context);

    }on FirebaseAuthException catch (e) {
      // Hata mesajı yakalama
      setState(() {
        if (e.code == 'user-not-found') {
          _errorMessage = 'Kullanıcı bulunamadı. Lütfen kayıt olun.';
        } else if (e.code == 'wrong-password') {
          _errorMessage = 'Hatalı şifre. Lütfen şifrenizi kontrol edin.';
        } else {
          _errorMessage = 'Giriş yapılamadı: ${e.message}';
        }
      });
    }

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
}
