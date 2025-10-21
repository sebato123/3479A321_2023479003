import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:lab2/providers/ConfigurationData.dart';
import 'about.dart';

class PixelArtScreen extends StatefulWidget {
  const PixelArtScreen({super.key, required this.title});
  final String title;

  @override
  State<PixelArtScreen> createState() => __PixelArtScreenState();
}

class __PixelArtScreenState extends State<PixelArtScreen> {
  final Logger logger = Logger();

  int _sizeGrid = 16;
  Color _selectedColor = Colors.black;
  bool _showIndices = true;

  final List<Color> _fallbackColors = const [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.brown,
    Colors.grey,
    Colors.pink,
  ];

  late List<Color> _cellColors;

  @override
  void initState() {
    super.initState();
    logger.d("PixelArtScreen initialized. Mounted: $mounted");

    _cellColors = List<Color>.filled(
      _sizeGrid * _sizeGrid,
      Colors.transparent,
      growable: false,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final providerSize = context.read<ConfigurationData>().size;
      if (providerSize != _sizeGrid) {
        setState(() {
          _sizeGrid = providerSize;
          _cellColors = List<Color>.filled(
            _sizeGrid * _sizeGrid,
            Colors.transparent,
            growable: false,
          );
        });
        logger.d("Grid size set from provider (post-frame): $_sizeGrid");
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newSize = context.watch<ConfigurationData>().size;
    if (newSize != _sizeGrid) {
      setState(() {
        _sizeGrid = newSize;
        _cellColors = List<Color>.filled(
          _sizeGrid * _sizeGrid,
          Colors.transparent,
          growable: false,
        );
      });
      logger.d("Dependencies changed. New grid size: $_sizeGrid");
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.d("Logger is working!");

    final cfg = context.read<ConfigurationData>();
    final palette = cfg.palette.isNotEmpty ? cfg.palette : _fallbackColors;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(120, 216, 18, 18),
        title: Text(widget.title),
        actions: [
          // Botón de guardado 
          IconButton(
            tooltip: 'Guardar imagen',
            icon: const Icon(Icons.save_alt),
            onPressed: _savePixelArt,
          ),
          // Botón de compartir
          IconButton(
            tooltip: 'Compartir imagen',
            icon: const Icon(Icons.share),
            onPressed: _sharePixelArt,
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const About()));
            },
            child: const Text("About", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 380;
            final paletteAsTwoRows = constraints.maxWidth < 340;

            return Column(
              children: [
                // HEADER flexible
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Text('$_sizeGrid x $_sizeGrid'),
                      SizedBox(
                        width: isNarrow ? constraints.maxWidth : 260,
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Ingrese título',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onSubmitted: (value) => logger.d('Título ingresado: $value'),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Números'),
                          Switch(
                            value: _showIndices,
                            onChanged: (v) => setState(() => _showIndices = v),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // GRID principal
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _sizeGrid,
                    ),
                    itemCount: _sizeGrid * _sizeGrid,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() => _cellColors[index] = _selectedColor);
                        },
                        child: Container(
                          margin: const EdgeInsets.all(1),
                          color: _cellColors[index],
                          child: _showIndices
                              ? Center(
                                  child: Text(
                                    '$index',
                                    style: TextStyle(
                                      color: _cellColors[index] == Colors.black
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      );
                    },
                  ),
                ),

                // PALETA adaptativa
                _ResponsivePalette(
                  colors: palette,
                  selected: _selectedColor,
                  twoRows: paletteAsTwoRows,
                  onSelect: (c) => setState(() => _selectedColor = c),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // Función para guardar imagen
  // ----------------------------------------------------------
  Future<void> _savePixelArt() async {
    try {
      final double cell = context.read<ConfigurationData>().size.toDouble();
      final int width = (_sizeGrid * cell).toInt();
      final int height = (_sizeGrid * cell).toInt();

      final recorder = ui.PictureRecorder();
      final canvas =
          Canvas(recorder, Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()));

      final bg = Paint()..color = Colors.white;
      canvas.drawRect(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), bg);

      for (int row = 0; row < _sizeGrid; row++) {
        for (int col = 0; col < _sizeGrid; col++) {
          final paint = Paint()..color = _cellColors[row * _sizeGrid + col];
          final rect = Rect.fromLTWH(col * cell, row * cell, cell, cell);
          canvas.drawRect(rect, paint);
        }
      }

      final picture = recorder.endRecording();
      final image = await picture.toImage(width, height);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/pixel_art_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(path);
      await file.writeAsBytes(bytes);

      logger.d("Pixel art guardado en: $path");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pixel art guardado en:\n$path')),
      );
    } catch (e, st) {
      logger.e('Error al guardar pixel art', error: e, stackTrace: st);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar la imagen')),
      );
    }
  }

  // Renderiza y guarda la imagen, devuelve la ruta del fichero guardado
  Future<String> _renderAndSaveImage() async {
    final double cell = context.read<ConfigurationData>().size.toDouble();
    final int width = (_sizeGrid * cell).toInt();
    final int height = (_sizeGrid * cell).toInt();

    final recorder = ui.PictureRecorder();
    final canvas =
        Canvas(recorder, Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()));

    final bg = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), bg);

    for (int row = 0; row < _sizeGrid; row++) {
      for (int col = 0; col < _sizeGrid; col++) {
        final paint = Paint()..color = _cellColors[row * _sizeGrid + col];
        final rect = Rect.fromLTWH(col * cell, row * cell, cell, cell);
        canvas.drawRect(rect, paint);
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/pixel_art_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File(path);
    await file.writeAsBytes(bytes);
    return path;
  }

  // Guarda y luego comparte la imagen (sin texto adicional)
  Future<void> _sharePixelArt() async {
    final path = await _renderAndSaveImage();
    logger.d('Compartiendo imagen: $path');
    if (!mounted) return;

    // Intentamos compartir usando share_plus. En Windows el diálogo
    // puede no mostrar target; en ese caso usamos un fallback que
    // abre el Explorador y selecciona el fichero para que el usuario lo
    // comparta manualmente.
    try {
      if (Platform.isWindows) {
        // En Windows es común que el share sheet no muestre targets.
  // Intentamos abrir el Explorador con el fichero seleccionado.
        try {
          Process.run('explorer', ['/select,${path.replaceAll('/', r'\\')}']);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Se abrió la carpeta con la imagen (Windows).')),
          );
          return;
        } catch (e) {
          // Si no podemos abrir explorer, aún intentamos el share normal
          logger.w('No se pudo abrir Explorer como fallback: $e');
        }
      }

      await Share.shareXFiles([XFile(path)]);
    } catch (e, st) {
      logger.e('Error al compartir pixel art', error: e, stackTrace: st);
      // Fallback adicional en Windows: abrir carpeta si la llamada a share falla
      if (Platform.isWindows) {
        try {
          Process.run('explorer', ['/select,${path.replaceAll('/', r'\\')}']);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Se abrió la carpeta con la imagen (fallback).')),
          );
          return;
        } catch (e2) {
          logger.w('Fallback explorer falló: $e2');
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al compartir la imagen')),
      );
    }
  }
}

// ----------------------------------------------------------
// Paleta adaptativa para distintas pantallas
// ----------------------------------------------------------
class _ResponsivePalette extends StatelessWidget {
  const _ResponsivePalette({
    required this.colors,
    required this.selected,
    required this.onSelect,
    required this.twoRows,
  });

  final List<Color> colors;
  final Color selected;
  final ValueChanged<Color> onSelect;
  final bool twoRows;

  @override
  Widget build(BuildContext context) {
    if (twoRows) {
      return Container(
        color: Colors.grey[200],
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Center(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: colors
                .map((c) => _ColorDot(color: c, selected: selected == c, onTap: () => onSelect(c)))
                .toList(),
          ),
        ),
      );
    }

    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: colors
              .map((c) => _ColorDot(color: c, selected: selected == c, onTap: () => onSelect(c)))
              .toList(),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.all(selected ? 12 : 8),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selected ? Border.all(color: Colors.black, width: 2) : null,
        ),
        width: selected ? 36 : 28,
        height: selected ? 36 : 28,
      ),
    );
  }
}
