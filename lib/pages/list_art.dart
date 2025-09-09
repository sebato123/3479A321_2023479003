
import 'package:flutter/material.dart';


final List<String> elementos = [
  'Elemento 1',
  'Elemento 2',
  'Elemento 3',
  'Elemento 4',
  'Elemento 5',
];

class ListArt extends StatelessWidget {
  const ListArt({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: 
         ListView.builder(
            itemCount: elementos.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(elementos[index]),
              );
            },

          ),
        bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Volver'),
        ),
    ),
    );

  }
}