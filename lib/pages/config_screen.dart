import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lab2/providers/ConfigurationData.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cfg = context.watch<ConfigurationData>();
    final sizes = cfg.allowedSizes;

    // Asegura que el valor actual exista en la lista (fallback si no está)
    final current = sizes.contains(cfg.size) ? cfg.size : sizes.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tamaño del Pixel Art',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: current,
                  decoration: const InputDecoration(
                    labelText: 'Selecciona el tamaño por defecto',
                    border: OutlineInputBorder(),
                  ),
                  items: sizes
                      .map((v) => DropdownMenuItem(
                            value: v,
                            child: Text('$v'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    context.read<ConfigurationData>().setSize(value);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tamaño actualizado a $value')),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Valor actual: ${cfg.size}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
