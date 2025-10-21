import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ListCreation extends StatefulWidget {
  const ListCreation({super.key});

  @override
  State<ListCreation> createState() => _ListCreationState();
}

class _ListCreationState extends State<ListCreation> {
  List<File> _creations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCreations();
  }

  Future<void> _loadCreations() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final List<FileSystemEntity> all = await dir.list().toList();

      // Filtra los PNG generados por tu pantalla (pixel_art_*.png)
      final files = all
          .whereType<File>()
          .where((f) => f.path.endsWith('.png') && f.path.contains('pixel_art_'))
          .toList();

      // Ordena por fecha de modificación (desc), más reciente arriba
      files.sort((a, b) {
        final am = a.statSync().modified;
        final bm = b.statSync().modified;
        return bm.compareTo(am);
      });

      setState(() {
        _creations = files;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      // opcional: mostrar snackbar de error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudieron cargar las creaciones')),
        );
      }
    }
  }

  void _openPreview(File file) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ImagePreviewScreen(imageFile: file),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis creaciones')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCreations,
              child: _creations.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        Center(
                          child: Text(
                            'Aun no tienes creaciones guardadas.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _creations.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final file = _creations[index];
                        final name = file.uri.pathSegments.isNotEmpty
                            ? file.uri.pathSegments.last
                            : file.path.split(Platform.pathSeparator).last;
                        final modified = file.statSync().modified;

                        return Card(
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                file,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                              ),
                            ),
                            title: Text(name),
                            subtitle: Text(
                              'Modificado: ${modified.toLocal()}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _openPreview(file),
                          ),
                        );
                      },
                    ),
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

/// Pantalla simple para previsualizar la imagen completa
class _ImagePreviewScreen extends StatelessWidget {
  const _ImagePreviewScreen({required this.imageFile});

  final File imageFile;

  @override
  Widget build(BuildContext context) {
    final name = imageFile.uri.pathSegments.isNotEmpty
        ? imageFile.uri.pathSegments.last
        : imageFile.path.split(Platform.pathSeparator).last;

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5,
          child: Image.file(
            imageFile,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 64),
          ),
        ),
      ),
    );
  }
}
