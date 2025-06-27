import 'package:flutter/material.dart';
import '../models/functions.dart'; // backgroundContainer için import

class YoneticiEkran extends StatelessWidget {
  const YoneticiEkran({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yönetici Paneli',
        style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepPurple,
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
            /*SizedBox(height: 20),
            _buildButton(
              context: context,
              text: 'Masa Sayısı Düzenle',
              color: Colors.blueAccent,
              icon: Icons.table_chart,
              onPressed: () {
                // Masa sayısı düzenleme işlemi
              },
            ),*/
            SizedBox(height: 20),
            _buildButton(
              context: context,
              text: 'Masalar',
              color: Colors.green,
              icon: Icons.chair,
              onPressed: () {
                masalarGec(context);
              },
            ),
            SizedBox(height: 20),
            _buildButton(
              context: context,
              text: 'Menüyü Düzenle',
              color: Colors.orange,
              icon: Icons.menu_book,
              onPressed: () {
                menuDuzenleGec(context);
              },
            ),
            SizedBox(height: 20),
            _buildButton(
              context: context,
              text: 'Rapor',
              color: Colors.redAccent,
              icon: Icons.analytics,
              onPressed: () {
                // Rapor işlemi
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String text,
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 32, color: Colors.white),
      label: Text(
        text,
        style: TextStyle(fontSize: 18, color: Colors.white),
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
