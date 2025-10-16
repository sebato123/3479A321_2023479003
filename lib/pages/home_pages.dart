import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'about.dart';
import 'config_screen.dart';
import 'package:lab2/providers/ConfigurationData.dart';
import 'pixel_art_screen.dart'; 

class MyHomePage extends StatelessWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final logger = Logger();
    logger.d("Home build");

    final cfg = context.watch<ConfigurationData>();
    final size = cfg.size;
    final colorsCount = cfg.palette.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(120, 216, 18, 18),
        title: Text(title),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const About()),
              );
            },
            child: const Text("About", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Estado actual (útil para comprobar persistencia y provider)
                Text(
                  'Tamaño actual: ${size}px · Colores en paleta: $colorsCount',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),

                // SOLO LOS DOS BOTONES
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ConfigScreen()),
                        );
                      },
                      icon: const Icon(Icons.settings_applications),
                      label: const Text("Configuración"),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PixelArtScreen(title: "Pixel Art"),
                          ),
                        );
                      },
                      icon: const Icon(Icons.brush),
                      label: const Text("Dibujar PixelArt"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
