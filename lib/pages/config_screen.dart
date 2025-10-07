import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lab2/providers/ConfigurationData.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cfg = context.watch<ConfigurationData>();

    
    final sizesStr = cfg.allowedSizes.map((e) => e.toString()).toList();
    final currentSizeStr = cfg.size.toString();

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Tamaño del pixel art (por defecto)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: sizesStr.contains(currentSizeStr) ? currentSizeStr : sizesStr.first,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Selecciona tamaño',
            ),
            items: sizesStr
                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              
              context.read<ConfigurationData>().setSize(int.parse(value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tamaño actualizado a $value')),
              );
            },
          ),

          const SizedBox(height: 24),
          const Divider(),

          const SizedBox(height: 12),
          const Text('Paleta de colores (única)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),

          // Vista de la paleta única + editar/eliminar
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (int i = 0; i < cfg.palette.length; i++)
                _ColorTile(
                  color: cfg.palette[i],
                  onTap: () => _showEditColorDialog(context, i),
                  onLongPress: () =>
                      context.read<ConfigurationData>().removeColorAt(i),
                ),
              // Botón para agregar color por HEX
              OutlinedButton.icon(
                onPressed: () => _showAddColorDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Agregar color'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddColorDialog(BuildContext context) {
    final controller = TextEditingController(text: '#FF8800');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Agregar color (#RRGGBB)'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '#RRGGBB'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              context.read<ConfigurationData>().addColorFromHex(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showEditColorDialog(BuildContext context, int index) {
    final controller = TextEditingController(text: _toHex6(context.read<ConfigurationData>().palette[index]));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar color (#RRGGBB)'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '#RRGGBB'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              context.read<ConfigurationData>().updateColorAt(index, controller.text);
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  static String _toHex6(Color c) {
    final rgb = (c.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase();
    return '#$rgb';
  }
}

class _ColorTile extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ColorTile({
    required this.color,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,          // editar
      onLongPress: onLongPress, // eliminar
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.black26),
        ),
      ),
    );
  }
}
