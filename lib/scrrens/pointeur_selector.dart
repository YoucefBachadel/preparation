import 'package:flutter/material.dart';
import '../Classes/pointeur.dart';
import '../main.dart';
import '../shared.dart';

class PointeurSelector extends StatefulWidget {
  const PointeurSelector({Key? key}) : super(key: key);

  @override
  State<PointeurSelector> createState() => _PointeurSelectorState();
}

class _PointeurSelectorState extends State<PointeurSelector> {
  int selectedPointeur = -1;

  void selectPointeur(Pointeur item) async {
    if (selectedPointeur != -1) {
      return;
    } else {
      setState(() => selectedPointeur = item.id);

      await sqlQuery(cmc, {
        'inabex':
            'UPDATE Effet SET Effet.CleEtatEffet = ${item.etat} WHERE Effet.Reference IN (${scannedQr.refAssociersToList()});',
        'sql1':
            '''UPDATE transaction SET idBl=${scannedQr.idEffit},refBl='${scannedQr.ref}',pointeur=${item.id},createionBl='${scannedQr.creationTime}',controler='${DateTime.now()}' WHERE refBc IN (${scannedQr.refAssociersToList()});''',
        'sql2': 'INSERT INTO controler VALUES (${scannedQr.idEffit});',
      });

      await dialog(context, '${scannedQr.ref} est contrôler');
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
          children: pointeurs
              .map((item) => InkWell(
                    onTap: () => selectPointeur(item),
                    child: Card(
                      color: Colors.white,
                      margin: const EdgeInsets.all(8.0),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(8.0),
                        child: selectedPointeur == item.id
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
