import 'package:flutter/material.dart';
import 'package:lab2/service/preferences.dart'; 

class ConfigurationData extends ChangeNotifier {
  final SharedPreferencesService _prefs;

  ConfigurationData(this._prefs) {
    _load(); // carga inicial asíncrona
  }

  // --- Estado ---
  int _size = 16;
  int get size => _size;

  bool _isResetEnabled = false;
  bool get isResetEnabled => _isResetEnabled;

  final List<int> allowedSizes = const [12, 16, 18, 20, 24, 28, 32];

  // Paleta única
  List<Color> _palette = [
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

  // --- Carga inicial ---
  Future<void> _load() async {
    final data = await _prefs.loadPreferences();
    _size = (data['board_size'] as int?) ?? _size;
    _isResetEnabled = (data['isResetEnabled'] as bool?) ?? _isResetEnabled;
    final loadedPalette = (data['palette'] as List<Color>?) ?? _palette;
    _palette = List<Color>.from(loadedPalette);
    notifyListeners();
  }

  // --- Guardado 
  Future<void> _save() async {
    await _prefs.savePreferences(
      boardSize: _size,
      isResetEnabled: _isResetEnabled,
      palette: _palette,
    );
  }

  Future<void> setSize(int newSize) async {
    if (newSize == _size) return;
    _size = newSize;
    await _save();
    notifyListeners();
  }

  Future<void> setResetEnabled(bool value) async {
    if (value == _isResetEnabled) return;
    _isResetEnabled = value;
    await _save();
    notifyListeners();
  }

  void addColorFromHex(String hex) {
    final c = _parseHex(hex);
    if (c == null) return;
    _palette.add(c);
    _save(); 
    notifyListeners();
  }

  void updateColorAt(int index, String hex) {
    if (index < 0 || index >= _palette.length) return;
    final c = _parseHex(hex);
    if (c == null) return;
    _palette[index] = c;
    _save();
    notifyListeners();
  }

  void removeColorAt(int index) {
    if (index < 0 || index >= _palette.length) return;
    _palette.removeAt(index);
    _save();
    notifyListeners();
  }

  // --- Helper ---
  Color? _parseHex(String hex) {
    var v = hex.trim();
    if (v.startsWith('#')) v = v.substring(1);
    if (v.length != 6) return null;
    final int? rgb = int.tryParse(v, radix: 16);
    if (rgb == null) return null;
    return Color(0xFF000000 | rgb);
  }
}