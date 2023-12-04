import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Classes/pointeur.dart';
import '../Classes/prepatarateur.dart';
import '../Classes/qr.dart';

List<Preparateur> preparateurs = [];
List<Pointeur> pointeurs = [];
QR scannedQr = QR();
bool dataLoaded = false;
String host = 'http://10.10.10.5:8081/preparation/php/';
String initialData = '${host}data.php';
String cmc = '${host}cmc.php';
String checkEnCour = '${host}checkEnCour.php';

dynamic sqlQuery(String url, dynamic params) async {
  var res = await http.post(Uri.parse(url), body: jsonEncode(params));
  return jsonDecode(res.body);
}

Future dialog(BuildContext context, String message) async {
  await showDialog(
    context: context,
    builder: (context) {
      Future.delayed(const Duration(seconds: 3), () => Navigator.of(context).pop());

      return Material(
          color: const Color.fromRGBO(0, 0, 0, 0),
          child: Column(
            children: [
              const Spacer(flex: 5),
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                    child: Text(message, style: const TextStyle(fontSize: 24, color: Colors.white)),
                  ),
                ),
              )
            ],
          ));
    },
  );
}
