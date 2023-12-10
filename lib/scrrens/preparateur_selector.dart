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
        'sql2':
            '''INSERT INTO transaction(idBc,refBc,etat,preparateur,creationBc,aPreparer,enCours) VALUES
                               (${scannedQr.idEffit},'${scannedQr.ref}',${scannedQr.etatEffet},${item.id},'${scannedQr.creationTime}','${scannedQr.lastModified}','${DateTime.now()}') ON DUPLICATE KEY UPDATE
                               refBc = '${scannedQr.ref}' , etat = ${scannedQr.etatEffet} , preparateur = ${item.id} , creationBc = '${scannedQr.creationTime}' , aPreparer = '${scannedQr.lastModified}' , enCours = '${DateTime.now()}';'''
      });

      await dialog(context, '${scannedQr.ref} est en cours', backgroundColor: enCoursColor);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Scanner()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: IconButton(
                onPressed: () =>
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Scanner())),
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 48,
                )),
          ),
          Flexible(
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              children: preparateurs
                  .map((item) => InkWell(
                        onTap: () => selectPreparateur(item),
                        child: Card(
                          color: item.color,
                          margin: const EdgeInsets.all(8.0),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(8.0),
                            child: selectedPreparateur == item.id
                                ? const CircularProgressIndicator()
                                : Text(
                                    item.name,
                                    style: TextStyle(
                                      fontSize: 24.0,
                                      color: ThemeData.estimateBrightnessForColor(item.color) == Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
