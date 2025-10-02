import 'dart:math';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'list_art.dart';
import 'about.dart';
import 'list_creation.dart';

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
  int _counter = 0;
  Color _currentColor = const Color.fromARGB(255, 49, 28, 25);
  
  Logger logger = Logger();
  int _sizeGrid = 12;

  @override
  void initState(){
    super.initState();
    logger.d("PixelArtScreen initialized. Mounted $mounted");
    //_sizeGrid = context.read<ConfigurationData>().size;
    logger.d("Grid size set to: $_sizeGrid");
  }

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    logger.d("Dependencies changed. Mounted: $mounted");
  }

  @override
  void didUpdateWidget(covariant PixelArtScreen oldWidget){
    super.didUpdateWidget(oldWidget);
    logger.d("PixelArtScreen widget updated. Mounted: $mounted");
  }

  @override
  void deactivate(){
    super.deactivate();
    logger.d("Deactivate activado. Mounted: $mounted");
  }

  @override
  void dispose(){
    super.dispose();
    logger.d("Dispose activado. Mounted: $mounted");
  }

  @override
  void reassemble(){
    super.reassemble();
    logger.d("Reassamble activado. Mounted: $mounted");
  }



  void _incrementCounter() {
  setState(() {
    _counter++;
  });
  
}



  @override
  Widget build(BuildContext context) {
    var logger = Logger();

    logger.d("Logger is working!");
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color.fromARGB(120, 216, 18, 18), title: Text(widget.title),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),     // fondo del botón
        foregroundColor: Colors.white,    // color del texto/icono
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // bordes redondeados
        ),
      ),
          onPressed: () {
            Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const About()),
        );
      },
      child: const Text(
        "About",
        style: TextStyle(
          color: Colors.white, // texto blanco para que se vea sobre el AppBar
          fontSize: 16,
        ),
      ),
    ),
  ],
),

      body: Center(
        child:  Card (
          margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    
        const SizedBox(height: 12),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ListArt()),
                          );
                        },
                      icon: const Icon(Icons.create),
                      label: const Text("Crear"),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ListCreation()), 
                          );
                          },
                          icon: const Icon(Icons.share),
                          label: const Text("Creaciones"),
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
