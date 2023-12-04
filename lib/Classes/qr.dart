class QR {
  String type;
  int idEffit;
  int etatEffet;
  String ref;
  int nbProd;
  String refAssociers;
  DateTime creationTime;
  DateTime lastModified;

  QR({
    this.type = '',
    this.idEffit = 0,
    this.ref = '',
    this.etatEffet = 0,
    this.nbProd = 0,
    this.refAssociers = '',
    DateTime? creationTime,
    DateTime? lastModified,
  })  : creationTime = creationTime ?? DateTime.now(),
        lastModified = lastModified ?? DateTime.now();

  String refAssociersToList() {
    String result = '';
    for (var item in refAssociers.split(',')) {
      result += "'$item',";
    }
    return result.substring(0, result.length - 1);
  }
}
