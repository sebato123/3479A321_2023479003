import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lab2/pages/home_pages.dart';
import 'providers/ConfigurationData.dart';                   
import 'package:provider/provider.dart';
import 'pages/pixel_art_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider<ConfigurationData>(               
      create: (_) => ConfigurationData(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 255, 255, 255),
          brightness: Brightness.dark,
        ),
        textTheme: TextTheme(
          displayLarge: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: GoogleFonts.oswald(
            fontSize: 30,
            fontStyle: FontStyle.italic,
          ),
          bodyMedium: GoogleFonts.merriweather(),
          displaySmall: GoogleFonts.pacifico(),
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Display de imagenes'),
    );
  }
}
