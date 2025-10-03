import 'package:flutter/material.dart';


class ConfigurationData extends ChangeNotifier {
  // Tamaño por defecto
  int _size = 12;
  int get size => _size;

  // Valores permitidos para el dropdown
  final List<int> allowedSizes = const [12, 16, 18, 20, 24, 28, 32];

  void setSize(int newSize) {
    if (_size == newSize) return;
    _size = newSize;
    notifyListeners();
  }
}