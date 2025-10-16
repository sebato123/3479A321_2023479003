import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:lab2/pages/home_pages.dart';
import 'package:lab2/pages/config_screen.dart';
import 'package:lab2/pages/pixel_art_screen.dart';

import 'package:lab2/providers/ConfigurationData.dart';
import 'package:lab2/service/preferences.dart'; 

void main() {
  runApp(
    ChangeNotifierProvider<ConfigurationData>(
      // pasa el servicio al provider
      create: (_) => ConfigurationData(SharedPreferencesService()),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pixel Art App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 255, 255, 255),
          brightness: Brightness.dark,
        ),
        textTheme: TextTheme(
          displayLarge: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
          titleLarge: GoogleFonts.oswald(fontSize: 30, fontStyle: FontStyle.italic),
          bodyMedium: GoogleFonts.merriweather(),
          displaySmall: GoogleFonts.pacifico(),
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Display de imágenes'),
      routes: {
        '/config': (_) => const ConfigScreen(),
        '/pixel': (_) => const PixelArtScreen(title: 'Pixel Art'),
      },
    );
  }
}