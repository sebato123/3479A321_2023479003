import 'dart:io';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'about.dart';
import 'config_screen.dart';
import 'package:lab2/providers/ConfigurationData.dart';
import 'pixel_art_screen.dart';
import 'package:lab2/pages/list_creation.dart';

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final logger = Logger();
  File? _lastImage;
  DateTime? _lastModified;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLastCreation();
  }

  Future<void> _loadLastCreation() async {
    try {
      setState(() => _loading = true);
      final dir = await getApplicationDocumentsDirectory();
      final all = await dir.list().toList();
      final files = all
          .whereType<File>()
          .where((f) => f.path.endsWith('.png') && f.path.contains('pixel_art_'))
          .toList();

      if (files.isEmpty) {
        setState(() {
          _lastImage = null;
          _lastModified = null;
          _loading = false;
        });
        return;
      }

      // archivo más reciente por fecha de modificación
      files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      final latest = files.first;
      setState(() {
        _lastImage = latest;
        _lastModified = latest.statSync().modified;
        _loading = false;
      });
    } catch (e, st) {
      logger.e('Error cargando última creación', error: e, stackTrace: st);
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cargar la última creación')),
      );
    }
  }

  Future<void> _goTo(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    // Al volver, refrescamos por si se creó algo nuevo
    await _loadLastCreation();
  }

  @override
  Widget build(BuildContext context) {
    logger.d("Home build");
    final cfg = context.watch<ConfigurationData>();
    final size = cfg.size;
    final colorsCount = cfg.palette.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(120, 216, 18, 18),
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Refrescar',
            onPressed: _loadLastCreation,
            icon: const Icon(Icons.refresh),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => _goTo(const About()),
            child: const Text("About", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double w = constraints.maxWidth;
          int columns;
          if (w < 420) {
            columns = 1;
          } else if (w < 680) {
            columns = 2;
          } else {
            columns = 3;
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Estado actual
                        Text(
                          'Tamaño actual: ${size}px · Colores en paleta: $colorsCount',
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Última creación
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Última creación',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _loading
                            ? const SizedBox(
                                height: 160,
                                child: Center(child: CircularProgressIndicator()),
                              )
                            : (_lastImage == null)
                                ? Container(
                                    height: 120,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Aún no hay imágenes guardadas',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Column(
                                      children: [
                                        AspectRatio(
                                          aspectRatio: 1.8, // miniatura panorámica
                                          child: Image.file(
                                            _lastImage!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(Icons.image_not_supported, size: 48),
                                          ),
                                        ),
                                        if (_lastModified != null)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 6),
                                            child: Text(
                                              'Guardado: ${_lastModified!.toLocal()}',
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                        const SizedBox(height: 20),

                        // Botones en grilla adaptable
                        GridView.count(
                          crossAxisCount: columns,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 3.2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _goTo(const ConfigScreen()),
                              icon: const Icon(Icons.settings_applications),
                              label: const Text("Configuración"),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _goTo(const PixelArtScreen(title: "Pixel Art")),
                              icon: const Icon(Icons.brush),
                              label: const Text("Dibujar PixelArt"),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _goTo(const ListCreation()),
                              icon: const Icon(Icons.image),
                              label: const Text("Creaciones"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
