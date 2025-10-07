import 'package:flutter/material.dart';


class ConfigurationData extends ChangeNotifier {
  
  int _size = 16;
  int get size => _size;
  final List<int> allowedSizes = const [12, 16, 18, 20, 24, 28, 32];

  void setSize(int newSize) {
    if (newSize == _size) return;
    _size = newSize;
    notifyListeners();
  }

  // Paleta de colores
  final List<Color> _palette = [
    Colors.black,
    Colors.white,
    const Color(0xFF555555),
    const Color(0xFF964B00), 
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
  ];

  List<Color> get palette => List.unmodifiable(_palette);

  // Agregar color "#RRGGBB" o "RRGGBB"
  void addColorFromHex(String hex) {
    final c = _parseHex(hex);
    if (c == null) return;
    _palette.add(c);
    notifyListeners();
  }

  // Reemplazar color en índice
  void updateColorAt(int index, String hex) {
    if (index < 0 || index >= _palette.length) return;
    final c = _parseHex(hex);
    if (c == null) return;
    _palette[index] = c;
    notifyListeners();
  }

  // Eliminar color por índice
  void removeColorAt(int index) {
    if (index < 0 || index >= _palette.length) return;
    _palette.removeAt(index);
    notifyListeners();
  }

  // helpers 
  Color? _parseHex(String hex) {
    var v = hex.trim();
    if (v.startsWith('#')) v = v.substring(1);
    if (v.length != 6) return null;
    final int? rgb = int.tryParse(v, radix: 16);
    if (rgb == null) return null;
    return Color(0xFF000000 | rgb); // alpha 0xFF
  }
}
