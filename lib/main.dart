import 'package:cafe_adisyon/firebase_options.dart';
import 'package:cafe_adisyon/view/garson_ekran.dart';
import 'package:cafe_adisyon/view/giris_ekran.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter'ın başlatılması için çağrılır

  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(AnaUygulama());
}

class AnaUygulama extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cafemiz', // Uygulama başlığı
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GirisEkran(), // Yönlendirme ekranını başlatır
    );
  }
}
