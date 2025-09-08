import 'dart:math';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  Color _currentColor = Colors.red;
  
  get _logger => null;  


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
      appBar: AppBar(
        backgroundColor: _currentColor,
        title: Text(widget.title),
      ),

      body: Center(
        child:  Card (
          margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                    height: 400, // altura del carrusel
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children:[
                      Image.asset("Assets/Pixel-Art-Hot-Pepper-2-1.webp", width: 600, fit: BoxFit.cover),
                      Image.asset("Assets/Pixel-Art-Pizza-2.webp",        width: 600, fit: BoxFit.cover),
                      Image.asset("Assets/Pixel-Art-Watermelon-3.webp",   width: 600, fit: BoxFit.cover),
                      ],
                    ),
                  ),
        
        
        const SizedBox(height: 12),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.create),
                      label: const Text("Crear"),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.share),
                      label: const Text("Compartir"),
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