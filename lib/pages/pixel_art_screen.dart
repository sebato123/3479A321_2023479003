import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:lab2/providers/ConfigurationData.dart';
import 'about.dart';
import 'package:image_picker/image_picker.dart';
// ...existing code...

class PixelArtScreen extends StatefulWidget {
  const PixelArtScreen({super.key, required this.title});
  final String title;

  @override
  State<PixelArtScreen> createState() => __PixelArtScreenState();
}

class __PixelArtScreenState extends State<PixelArtScreen> with WidgetsBindingObserver {
  final Logger logger = Logger();
  File? _backgroundImage;
  
  int _sizeGrid = 16;
  Color _selectedColor = Colors.black;
  bool _showIndices = true;

  // Autosave state
  bool _isSaved = true;
  static const _sessionFileName = 'pixelart_session.json';
  static const _sessionBgName = 'pixelart_session_bg.png';

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
    WidgetsBinding.instance.addObserver(this);
    logger.d("PixelArtScreen initialized. Mounted: $mounted");

    _cellColors = List<Color>.filled(
      _sizeGrid * _sizeGrid,
      Colors.transparent,
      growable: false,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
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
      await _loadSession();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _saveSessionIfNeeded();
    }
    super.didChangeAppLifecycleState(state);
  }

  void _markDirty() {
    if (_isSaved) {
      setState(() => _isSaved = false);
    }
  }

  Future<File> _sessionFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_sessionFileName');
  }

  Future<File> _sessionBgFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_sessionBgName');
  }

  Future<void> _saveSessionIfNeeded() async {
    if (_isSaved) return;
    try {
      final sessionFile = await _sessionFile();
      final Map<String, dynamic> data = {
        'sizeGrid': _sizeGrid,
        'showIndices': _showIndices,
        'backgroundOpacity': context.read<ConfigurationData>().backgroundOpacity,
        'selectedColor': _selectedColor.value,
        'cellColors': _cellColors.map((c) => c.value).toList(),
      };

      if (_backgroundImage != null && _backgroundImage!.existsSync()) {
        final bgFile = await _sessionBgFile();
        await _backgroundImage!.copy(bgFile.path);
        data['backgroundPath'] = bgFile.path.split(Platform.pathSeparator).last;
      }

      await sessionFile.writeAsString(jsonEncode(data));
      logger.d('Sesión guardada en ${sessionFile.path}');
    } catch (e, st) {
      logger.w('No se pudo guardar sesión automática', error: e, stackTrace: st);
    }
  }

  Future<void> _loadSession() async {
    try {
      final sessionFile = await _sessionFile();
      if (!sessionFile.existsSync()) return;
      final content = await sessionFile.readAsString();
      final Map<String, dynamic> data = jsonDecode(content);

      final int savedSize = (data['sizeGrid'] as num).toInt();
      final List<dynamic> savedColors = data['cellColors'] as List<dynamic>;

      setState(() {
        _sizeGrid = savedSize;
        _cellColors = List<Color>.filled(
          _sizeGrid * _sizeGrid,
          Colors.transparent,
          growable: false,
        );
        for (int i = 0; i < _cellColors.length && i < savedColors.length; i++) {
          _cellColors[i] = Color((savedColors[i] as num).toInt());
        }
        _showIndices = data['showIndices'] as bool? ?? _showIndices;
        _selectedColor = Color((data['selectedColor'] as num?)?.toInt() ?? Colors.black.value);
      });

      final bgFile = await _sessionBgFile();
      if (bgFile.existsSync()) setState(() => _backgroundImage = bgFile);

      _isSaved = false;
      logger.d('Sesión restaurada desde ${sessionFile.path}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Se restauró el último progreso no guardado.')),
        );
      }
    } catch (e, st) {
      logger.w('No se pudo restaurar sesión', error: e, stackTrace: st);
    }
  }

  Future<void> _clearSession() async {
    try {
      final sessionFile = await _sessionFile();
      if (sessionFile.existsSync()) await sessionFile.delete();
      final bgFile = await _sessionBgFile();
      if (bgFile.existsSync()) await bgFile.delete();
      _isSaved = true;
      logger.d('Sesión automática borrada');
    } catch (e, st) {
      logger.w('Error al limpiar sesión automática', error: e, stackTrace: st);
    }
  }

 @override
Widget build(BuildContext context) {
  logger.d("Logger is working!");

  final cfg = context.read<ConfigurationData>();
  final bgOpacity = context.watch<ConfigurationData>().backgroundOpacity;
  final palette = cfg.palette.isNotEmpty ? cfg.palette : _fallbackColors;

  return Scaffold(
    appBar: AppBar(
      backgroundColor: const Color.fromARGB(120, 216, 18, 18),
      title: Text(widget.title),
      actions: [
        IconButton(
          tooltip: 'Guardar imagen',
          icon: const Icon(Icons.save_alt),
          onPressed: _savePixelArt,
        ),
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

              // GRID con fondo en Stack
              
              Expanded(
                child: Stack(
                  
                  children: [
                    
                   if (_backgroundImage != null)
                      Opacity(
                        opacity: bgOpacity,
                        child: Image.file(
                          _backgroundImage!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    GridView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _sizeGrid,
                      ),
                      itemCount: _sizeGrid * _sizeGrid,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() => _cellColors[index] = _selectedColor);
                            _markDirty();
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
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),

    
    bottomNavigationBar: SafeArea(
      child: Container(
        color: Colors.grey[200],
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fila de botones: Tomar / Eliminar
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _takePicture,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Tomar fondo'),
                  ),
                ),
                const SizedBox(width: 12),
                if (_backgroundImage != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _deleteBackgroundImage,
                      icon: const Icon(Icons.delete),
                      label: const Text('Eliminar fondo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                    ),
                  ),
              ],
            ),

            // Slider de opacidad (solo si hay fondo)
           if (_backgroundImage != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Opacidad'),
                    Expanded(
                      child: Slider(
                        value: context.watch<ConfigurationData>().backgroundOpacity,  // <- obtener
                        min: 0.1,
                        max: 1.0,
                        divisions: 10,
                        label: '${(context.watch<ConfigurationData>().backgroundOpacity * 100).toInt()}%',
                        onChanged: (v) {
                          context.read<ConfigurationData>().setBackgroundOpacity(v);  // <- configurar
                        },
                      ),
                    ),
                  ],
                ),
              ],

            // Paleta (scroll horizontal)
            const SizedBox(height: 8),
            _ResponsivePalette(
              colors: palette,
              selected: _selectedColor,
              twoRows: false, // en barra inferior: una fila con scroll
              onSelect: (c) {
                setState(() => _selectedColor = c);
                _markDirty();
              },
            ),
          ],
        ),
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

      // Al guardar manualmente limpiamos el autosave
      await _clearSession();
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

  // ----------------------------------------------------------
  // Funciones para manejar imagen de fondo
  // ----------------------------------------------------------

Future<void> _takePicture() async {

  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/background_image.png';
    // Save the new image and delete the old one if it exists
    final newImage = File(pickedFile.path);
      if (_backgroundImage != null && _backgroundImage!.existsSync()) {
      _backgroundImage!.deleteSync();
      }
    newImage.copySync(filePath);
    setState(() {
    _backgroundImage = File(filePath);
    });
    _markDirty();
    }
    }
    void _deleteBackgroundImage() {
    if (_backgroundImage != null && _backgroundImage!.existsSync()) {
    _backgroundImage!.deleteSync();
    }
  setState(() {
  _backgroundImage = null;
  });
  _markDirty();
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