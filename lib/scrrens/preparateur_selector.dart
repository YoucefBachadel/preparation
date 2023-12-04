import 'package:flutter/material.dart';
import '../Classes/prepatarateur.dart';
import '../main.dart';
import '../shared.dart';

class PreparateurSelector extends StatefulWidget {
  const PreparateurSelector({Key? key}) : super(key: key);

  @override
  State<PreparateurSelector> createState() => _PreparateurSelectorState();
}

class _PreparateurSelectorState extends State<PreparateurSelector> {
  int selectedPreparateur = -1;

  void selectPreparateur(Preparateur item) async {
    if (selectedPreparateur != -1) {
      return;
    } else {
      setState(() => selectedPreparateur = item.id);

      await sqlQuery(cmc, {
        'inabex':
            'UPDATE Effet SET Effet.CleEtatEffet = 2 , Effet.CleCommercial = ${item.id} WHERE Effet.CleEffet = ${scannedQr.idEffit};',
        'sql1': 'INSERT INTO encours VALUES (${scannedQr.idEffit});',
        'sql2': '''INSERT INTO transaction(idBc,refBc,etat,preparateur,creationBc,aPreparer,enCours) VALUES
                               (${scannedQr.idEffit},'${scannedQr.ref}',${scannedQr.etatEffet},${item.id},'${scannedQr.creationTime}','${scannedQr.lastModified}','${DateTime.now()}') ON DUPLICATE KEY UPDATE
                               refBc = '${scannedQr.ref}' , etat = ${scannedQr.etatEffet} , preparateur = ${item.id} , creationBc = '${scannedQr.creationTime}' , aPreparer = '${scannedQr.lastModified}' , enCours = '${DateTime.now()}';'''
      });

      await dialog(context, '${scannedQr.ref} est en cours');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Scanner()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          children: preparateurs
              .map((item) => InkWell(
                    onTap: () => selectPreparateur(item),
                    child: Card(
                      color: Colors.white,
                      margin: const EdgeInsets.all(8.0),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(8.0),
                        child: selectedPreparateur == item.id
                            ? const CircularProgressIndicator()
                            : Text(
                                item.name,
                                style: const TextStyle(fontSize: 24.0),
                              ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
