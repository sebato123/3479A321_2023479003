import 'dart:math';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'list_art.dart';
import 'about.dart';
import 'list_creation.dart';
import 'package:lab2/providers/ConfigurationData.dart';

class PixelArtScreen extends StatefulWidget {
  const PixelArtScreen({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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
    Colors.black, Colors.white, Colors.red, Colors.orange, Colors.yellow,
    Colors.green, Colors.blue, Colors.indigo, Colors.purple, Colors.brown,
    Colors.grey, Colors.pink,
  ];

  late List<Color> _cellColors;

  @override
  void initState() {
    super.initState();
    logger.d("PixelArtScreen initialized. Mounted: $mounted");

    // Inicializa con 16x16; luego ajustamos al valor real del provider post-frame
    _cellColors = List<Color>.filled(_sizeGrid * _sizeGrid, Colors.transparent, growable: false);

    // Tomar el size del provider de forma segura (post-frame)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final providerSize = context.read<ConfigurationData>().size;
      if (providerSize != _sizeGrid) {
        setState(() {
          _sizeGrid = providerSize;
          _cellColors = List<Color>.filled(_sizeGrid * _sizeGrid, Colors.transparent, growable: false);
        });
        logger.d("Grid size set from provider (post-frame): $_sizeGrid");
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Si el size cambia en tiempo de ejecución (desde Config), sincronizamos la grilla
    final newSize = context.watch<ConfigurationData>().size;
    if (newSize != _sizeGrid) {
      setState(() {
        _sizeGrid = newSize;
        _cellColors = List<Color>.filled(_sizeGrid * _sizeGrid, Colors.transparent, growable: false);
      });
      logger.d("Dependencies changed. New grid size: $_sizeGrid");
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.d("Logger is working!");

    // Paleta: preferimos la del Provider; si no existe, usamos la fallback
    final cfg = context.read<ConfigurationData>();
    final palette = cfg.palette.isNotEmpty ? cfg.palette : _fallbackColors;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(120, 216, 18, 18),
        title: Text(widget.title),
        actions: [
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
        child: Column(
          children: [
            // Encabezado con tamaño actual y un campo de título
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
  children: [
    Text('$_sizeGrid x $_sizeGrid'),
    const SizedBox(width: 8),
    Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: TextField(
          decoration: const InputDecoration(
            hintText: 'Ingrese título',
            border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) => logger.d('Title entered: $value'),
                  ),
                ),
              ),
              // <- NUEVO: Switch para mostrar/ocultar índices
              Row(
                children: [
                  const Text('Números'),
                  Switch(
                    value: _showIndices,
                    onChanged: (v) => setState(() => _showIndices = v),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => logger.d('Submit pressed'),
                child: const Text('Submit'),
              ),
            ],
),
            ),

            // Grilla pintable
            Expanded(
              child: GridView.builder(
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
                              color: _cellColors[index] == Colors.black ? Colors.white : Colors.black,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                    ),
                  );
                },
              ),
            ),

            // Footer con la paleta seleccionable
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.grey[200],
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: palette.map((color) {
                    final bool isSelected = color == _selectedColor;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: EdgeInsets.all(isSelected ? 12 : 8),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
                        ),
                        width: isSelected ? 36 : 28,
                        height: isSelected ? 36 : 28,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  @override
  void didUpdateWidget(covariant PixelArtScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    logger.d("PixelArtScreen widget updated. Mounted: $mounted");
  }

  @override
  void deactivate() {
    super.deactivate();
    logger.d("PixelArtScreen deactivated. Mounted: $mounted");
  }

  @override
  void dispose() {
    super.dispose();
    logger.d("PixelArtScreen disposed. Mounted: $mounted");
  }

  @override
  void reassemble() {
    super.reassemble();
    logger.d("PixelArtScreen reassembled. Mounted: $mounted");
  }

  
}