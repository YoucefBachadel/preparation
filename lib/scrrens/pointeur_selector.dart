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

      await dialog(context, '${scannedQr.ref} est contrôler', backgroundColor: item.statusColor);
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
              children: pointeurs
                  .map((item) => InkWell(
                        onTap: () => selectPointeur(item),
                        child: Card(
                          color: item.color,
                          margin: const EdgeInsets.all(8.0),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(8.0),
                            child: selectedPointeur == item.id
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
