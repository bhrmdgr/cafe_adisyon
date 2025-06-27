// lib/models/functions.dart
import 'dart:ffi';

import 'package:cafe_adisyon/view/bar_ekran.dart';
import 'package:cafe_adisyon/view/garson_ekran.dart';
import 'package:cafe_adisyon/view/giris_ekran.dart';
import 'package:cafe_adisyon/view/giris_secenek_ekran.dart';
import 'package:cafe_adisyon/view/isletme_kayit.dart';
import 'package:cafe_adisyon/view/masalar.dart';
import 'package:cafe_adisyon/view/menuye_ekle.dart';
import 'package:cafe_adisyon/view/menuyu_duzenle.dart';
import 'package:cafe_adisyon/view/mutfak_ekran.dart';
import 'package:cafe_adisyon/view/yonetici_ekran.dart';
import 'package:flutter/material.dart';


////////////////////////BUTONLAR///////////////////////////////

Widget buildButton({
  required String text,
  required Color color,
  required VoidCallback onPressed,
}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 5,
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 18, color: Colors.white),
    ),
    onPressed: onPressed,
  );
}





//////////////////////////SAYFA GEÇİŞLERİ///////////////////////////////////


void kayitEkranGec(BuildContext context){

  Navigator.push(context,
      MaterialPageRoute(
          builder: (context) => IsletmeKayit()
      )
  );
}
void girisEkranGec(BuildContext context){

  Navigator.push(context, MaterialPageRoute(builder: (context) => GirisEkran()));
}

void girisSecenekleriGec(BuildContext context){
  Navigator.pushAndRemoveUntil(
      context, MaterialPageRoute(
      builder: (context) => GirisSecenekEkran()), (Route<dynamic> route) => false,);
}
void garsonEkranGec(BuildContext context){

  Navigator.push(context,
      MaterialPageRoute(
          builder: (context) => GarsonEkran()
      )
  );
}
void mutfakEkranGec(BuildContext context){

  Navigator.push(context,
      MaterialPageRoute(
          builder: (context) => MutfakEkran()
      )
  );
}
void barEkranGec(BuildContext context){

  Navigator.push(context,
      MaterialPageRoute(
          builder: (context) => BarEkran()
      )
  );
}
void yoneticiEkranGec(BuildContext context){

  Navigator.push(context,
      MaterialPageRoute(
          builder: (context) => YoneticiEkran()
      )
  );
}

void menuDuzenleGec(BuildContext context){

  Navigator.push(context,
      MaterialPageRoute(
          builder: (context) => MenuyuDuzenle()
      )
  );
}
void menuyeEkleGec(BuildContext context){

  Navigator.push(context,
      MaterialPageRoute(
          builder: (context) => MenuyeEkle()
      )
  );
}

void masalarGec(BuildContext context){

  Navigator.push(context,
      MaterialPageRoute(
          builder: (context) => Masalar()
      )
  );
}

////////////////////EKRAN ARKAPLAN////////////////////////

Widget backgroundContainer({required Widget child}) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blueAccent, Colors.purpleAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Center(child: child),
  );
}

//////////////////////////KAYIT İŞLEMİ////////////////////////


