import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  
  static const String keyBoardSize = 'board_size';
  static const String keyIsResetEnabled = 'isResetEnabled';
  static const String keyPalette = 'palette_hex'; // paleta
  static const String keyBgOpacity = 'bg_opacity';


   // Guardar
  Future<void> savePreferences({
    required int boardSize,
    required bool isResetEnabled,
    required List<Color> palette,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(keyBoardSize, boardSize);
    await prefs.setBool(keyIsResetEnabled, isResetEnabled);

    // Convertimos Color → HEX string
    final hexList = palette.map(_toHex6).toList();
    await prefs.setStringList(keyPalette, hexList);
  }

  
  Future<Map<String, dynamic>> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final size = prefs.getInt(keyBoardSize) ?? 16;
    final reset = prefs.getBool(keyIsResetEnabled) ?? false;

    final paletteHex = prefs.getStringList(keyPalette) ?? [
      // paleta por defecto si no hay guardada
      '#000000',
      '#FFFFFF',
      '#FF0000',
      '#00FF00',
      '#0000FF',
      '#FFFF00',
    ];

    // Convertimos HEX → Color
    final palette = paletteHex.map(_colorFromHex).toList();

    return {
      'board_size': size,
      'isResetEnabled': reset,
      'palette': palette,
    };
  }

  // Conversion colores
  Color _colorFromHex(String hex) {
    var v = hex.trim();
    if (v.startsWith('#')) v = v.substring(1);
    if (v.length != 6) v = v.padLeft(6, '0');
    final int rgb = int.parse(v, radix: 16);
    return Color(0xFF000000 | rgb);
  }

  //Slider de opacidad
  Future<double> getBackgroundOpacity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(keyBgOpacity) ?? 0.5; // default 0.5
  }

  Future<void> setBackgroundOpacity(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(keyBgOpacity, value.clamp(0.0, 1.0));
  }

  String _toHex6(Color c) =>
      '#${(c.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
