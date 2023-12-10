import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Classes/pointeur.dart';
import '../Classes/prepatarateur.dart';
import '../Classes/qr.dart';

List<Preparateur> preparateurs = [];
List<Pointeur> pointeurs = [];
Color enCoursColor = Colors.transparent;
Color preteColor = Colors.transparent;
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

Color getColor(int decimalNumber) {
  // Extract BGR components
  int blue = (decimalNumber >> 16) & 0xFF;
  int green = (decimalNumber >> 8) & 0xFF;
  int red = decimalNumber & 0xFF;

  return Color.fromRGBO(red, green, blue, 1.0);
}

Future dialog(BuildContext context, String message, {Color backgroundColor = Colors.white24}) async {
  await showDialog(
    context: context,
    builder: (context) {
      Future.delayed(const Duration(seconds: 3), () => Navigator.of(context).pop());

      return Material(
          color: Colors.transparent,
          child: Column(
            children: [
              const Spacer(flex: 5),
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(8)),
                    child: Text(message,
                        style: TextStyle(
                            fontSize: 24,
                            color: ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark
                                ? Colors.white
                                : Colors.black)),
                  ),
                ),
              )
            ],
          ));
    },
  );
}
