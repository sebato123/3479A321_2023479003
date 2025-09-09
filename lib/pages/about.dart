
import 'package:flutter/material.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Center(
              child: Text(
                'About',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox( 
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); 
                },
                child: const Text('Volver'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}