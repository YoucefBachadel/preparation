import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:wakelock/wakelock.dart';
import 'package:audioplayers/audioplayers.dart';
import '../Classes/pointeur.dart';
import '../Classes/prepatarateur.dart';
import '../Classes/qr.dart';
import '../scrrens/pointeur_selector.dart';
import '../scrrens/preparateur_selector.dart';
import '../shared.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //full screen mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  //keep the device awake
  Wakelock.enable();

  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: Scanner()));
}

class Scanner extends StatefulWidget {
  const Scanner({Key? key}) : super(key: key);

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final audioPlayer = AudioPlayer();

  QRViewController? controller;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (!dataLoaded) loaddata();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void loaddata() async {
    setState(() => isLoading = true);
    var res = await http.post(Uri.parse(initialData));
    if (res.statusCode == 200) {
      var data = json.decode(res.body);
      for (var ele in data['preparateurs']) {
        preparateurs.add(Preparateur(
          int.parse(ele.toString().split('/')[0]),
          ele.split('/')[1],
          getColor(int.parse(ele.split('/')[2])),
        ));
      }
      for (var ele in data['pointeurs']) {
        pointeurs.add(Pointeur(
          int.parse(ele.toString().split('/')[0]),
          ele.split('/')[1],
          int.parse(ele.split('/')[2]),
          getColor(int.parse(ele.split('/')[3])),
        ));
      }

      preparateurs.sort((a, b) => a.name.compareTo(b.name));
      pointeurs.sort((a, b) => a.name.compareTo(b.name));

      enCoursColor = getColor(data['enCoursColor']);
      preteColor = getColor(data['preteColor']);

      dataLoaded = true;

      setState(() => isLoading = false);
    }
  }

  void alertPlayer() async {
    final player = AudioCache(prefix: 'assets/');
    final url = await player.load('scan.mp3');
    audioPlayer.play(UrlSource(url.path));
  }

  Future changeToPret(BuildContext context) async {
    await sqlQuery(cmc, {
      'inabex': 'UPDATE Effet SET Effet.CleEtatEffet = 3 WHERE Effet.CleEffet = ${scannedQr.idEffit};',
      'sql1': 'DELETE FROM encours WHERE idBc = ${scannedQr.idEffit};',
      'sql2': '''UPDATE transaction SET pret = '${DateTime.now()}' WHERE idBc = ${scannedQr.idEffit};''',
    });

    await dialog(context, '${scannedQr.ref} est prête', backgroundColor: preteColor);
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      await controller.pauseCamera();
      alertPlayer();

      String? result = scanData.code.toString();
      bool isEnCour = false;
      bool idExiste = false;

      if (result.startsWith('bc') || result.startsWith('bl')) {
        scannedQr = QR(
          type: result.split('\\')[0],
          idEffit: int.parse(result.split('\\')[1]),
          ref: result.split('\\')[2],
          creationTime: DateFormat('dd-MM-yyyy HH:mm:ss').parse(result.split('\\')[3]),
          lastModified: DateFormat('dd-MM-yyyy HH:mm:ss').parse(result.split('\\')[4]),
          refAssociers: result.split('\\')[0] == 'bl' ? result.split('\\')[5] : '',
          etatEffet: result.split('\\')[0] == 'bc' ? int.parse(result.split('\\')[5]) : 0,
        );

        var data = await sqlQuery(checkEnCour, {
          'type': scannedQr.type,
          'sql1': scannedQr.type == 'bc'
              ? 'SELECT COUNT(*) as count FROM encours WHERE idBc = ${scannedQr.idEffit}'
              : 'SELECT COUNT(*) as count FROM controler WHERE idBl = ${scannedQr.idEffit}',
          if (scannedQr.type == 'bc')
            'sql2': 'SELECT COUNT(*) as count FROM transaction WHERE idBc = ${scannedQr.idEffit}',
        });

        if (data == 1) {
          isEnCour = true;
          setState(() => isLoading = true);
        } else if (data == -1) {
          idExiste = true;
          await dialog(
              context, scannedQr.type == 'bc' ? '${scannedQr.ref} existe déjà' : '${scannedQr.ref} existe déjà');
        }

        if (!idExiste) {
          if (isEnCour) {
            await changeToPret(context);
          } else {
            await showDialog(
              context: context,
              builder: (context) => (scannedQr.type == 'bc') ? const PreparateurSelector() : const PointeurSelector(),
            );
          }
        }
      } else {
        await dialog(context, 'Le code est invalide');
      }

      setState(() => isLoading = false);
      controller.resumeCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderRadius: 10,
              borderWidth: 10,
              borderLength: 20,
              borderColor: Theme.of(context).colorScheme.secondary,
              cutOutSize: MediaQuery.of(context).size.width * .9,
            ),
          ),
          if (isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
