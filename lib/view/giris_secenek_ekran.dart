import 'package:cafe_adisyon/models/functions.dart';
import 'package:cafe_adisyon/view/giris_ekran.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GirisSecenekEkran extends StatelessWidget {
  const GirisSecenekEkran({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Giriş Seçenekleri",
        style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepPurple,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app ,
            color: Colors.white,),
            onPressed: () {
              _oturumuKapat(context);
            },
          )
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return backgroundContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            _buildButton(
              context,
              text: 'Garson Girişi Yap',
              color: Colors.blueAccent,
              icon: Icons.person,
              onPressed: () {
                garsonEkranGec(context);
              },
            ),
            SizedBox(height: 20),
            _buildButton(
              context,
              text: 'Mutfak Girişi Yap',
              color: Colors.green,
              icon: Icons.restaurant,
              onPressed: () {
                mutfakEkranGec(context);
              },
            ),
            SizedBox(height: 20),
            _buildButton(
              context,
              text: 'Bar Girişi Yap',
              color: Colors.orange,
              icon: Icons.local_bar,
              onPressed: () {
                barEkranGec(context);
              },
            ),
            SizedBox(height: 20),
            _buildButton(
              context,
              text: 'Yönetici Girişi Yap',
              color: Colors.redAccent,
              icon: Icons.admin_panel_settings,
              onPressed: () {
                yoneticiEkranGec(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _oturumuKapat(BuildContext context) async {
    bool? confirmSignOut = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Çıkış Yap"),
          content: Text("Çıkış yapmak istediğinizden emin misiniz?"),
          actions: <Widget>[
            TextButton(
              child: Text("Hayır"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text("Evet"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmSignOut == true) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => GirisEkran()),
            (Route<dynamic> route) => false,
      );
    }
  }

  Widget _buildButton(BuildContext context,
      {required String text,
        required Color color,
        required IconData icon,
        required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 32),
      label: Text(
        text,
        style: TextStyle(fontSize: 20),
      ),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(MediaQuery.of(context).size.width * 0.8, 60),
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 5,
      ),
    );
  }
}
