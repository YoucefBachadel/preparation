import 'package:flutter/material.dart';
import 'package:preparation/shared.dart';

class Pointeur {
  int id;
  String name;
  int etat;
  Color color = Colors.transparent;
  Color statusColor;

  Pointeur(this.id, this.name, this.etat, this.statusColor) {
    color = preparateurs.firstWhere((preparateur) => preparateur.id == id).color;
  }
}
