import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BarEkran extends StatefulWidget {
  @override
  State<BarEkran> createState() => _BarEkranState();
}

class _BarEkranState extends State<BarEkran> {

  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bar Siparişleri'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Kullanicilar').doc(auth.currentUser?.uid).collection('BarSiparisler').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var siparisler = snapshot.data!.docs;

          return ListView.builder(
            itemCount: siparisler.length,
            itemBuilder: (context, index) {
              var siparis = siparisler[index];
              return Card(
                child: ListTile(
                  title: Text(siparis['urunIsmi']),
                  subtitle: Text('Masa: ${siparis['masaNumarasi']}'),
                  trailing: IconButton(
                    icon: Icon(Icons.check),
                    onPressed: () {
                      _siparisiTamamla(siparis.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _siparisiTamamla(String siparisId) async {
    await FirebaseFirestore.instance.collection('Kullanicilar').doc(auth.currentUser?.uid).collection('BarSiparisler').doc(siparisId).delete();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sipariş tamamlandı')));
  }
}
