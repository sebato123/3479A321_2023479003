import 'package:flutter/material.dart';


final List<String> creaciones = [
  'Creacion 1',
  'Creacion 2',
  'Creacion 3',
  'Creacion 4',
  'Creacion 5',
];

class ListCreation extends StatelessWidget {
  const ListCreation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: 
         ListView.builder(
            itemCount: creaciones.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(creaciones[index]),
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