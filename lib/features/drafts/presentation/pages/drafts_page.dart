import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; // For image picking
import 'dart:io'; // For File

import '../../domain/models/draft_album.dart';
import 'package:flutter_app/features/drafts/data/repositories/draft_service.dart';

class DraftsPage extends StatefulWidget {
  const DraftsPage({super.key});

  @override
  _DraftsPageState createState() => _DraftsPageState();
}

class _DraftsPageState extends State<DraftsPage> {
  final DraftService _draftService = DraftService();
  List<DraftAlbum> _allDraftAlbums = [];
  bool _isLoading = true;

  static const Color primaryColor = Color(0xFF340A6B);

  @override
  void initState() {
    super.initState();
    _loadDraftAlbums();
  }

  Future<void> _loadDraftAlbums() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final albums = await _draftService.getDraftAlbums();
      setState(() {
        _allDraftAlbums = albums;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar álbumes: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDraftAlbumForm([DraftAlbum? album]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _DraftAlbumForm(
          album: album,
          onSave: () {
            _loadDraftAlbums();
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Borradores',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF3E5F5),
      floatingActionButton: FloatingActionButton(
        heroTag: 'draftsFAB',
        onPressed: () => _showDraftAlbumForm(),
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _allDraftAlbums.isEmpty
                ? const Center(child: Text('No hay álbumes en borrador.'))
                : ListView.builder(
                    itemCount: _allDraftAlbums.length,
                    itemBuilder: (context, index) {
                      return _buildDraftAlbumCard(_allDraftAlbums[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraftAlbumCard(DraftAlbum album) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        title: Text(
          album.title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (album.description != null && album.description!.isNotEmpty)
              Text(album.description!),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'Clasificación: ${album.classification}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.grey),
              onPressed: () => _showDraftAlbumForm(album),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirmar eliminación'),
                    content: const Text(
                      '¿Estás seguro de que quieres eliminar este álbum?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text(
                          'Eliminar',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  try {
                    await _draftService.deleteDraftAlbum(album.id);
                    _loadDraftAlbums();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Álbum eliminado.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
            ),
          ],
        ),
        children: [
          if (album.photoUrls.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: album.photoUrls.length,
                itemBuilder: (context, index) {
                  // For now, assuming photoUrls are local paths or network URLs
                  // In a real app, you'd handle network images vs local files
                  final imageUrl = album.photoUrls[index];
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.file(
                      File(imageUrl),
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Image.network(
                            imageUrl,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 90,
                                  height: 90,
                                  color: Colors.grey,
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.white,
                                  ),
                                ),
                          ),
                    ),
                  );
                },
              ),
            ),
          if (album.photoUrls.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No hay fotos en este álbum.'),
            ),
        ],
      ),
    );
  }
}

class _DraftAlbumForm extends StatefulWidget {
  final DraftAlbum? album;
  final VoidCallback onSave;

  const _DraftAlbumForm({this.album, required this.onSave});

  @override
  __DraftAlbumFormState createState() => __DraftAlbumFormState();
}

class __DraftAlbumFormState extends State<_DraftAlbumForm> {
  final _formKey = GlobalKey<FormState>();
  final _draftService = DraftService();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _classification; // Changed to non-nullable
  List<String> _selectedPhotoPaths = [];
  bool _isSaving = false;

  static const Color primaryColor = Color(
    0xFF340A6B,
  ); // Defined primaryColor here

  final List<String> _classificationOptions = [
    'Completo',
    'En Revisión',
    'Incompleto',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.album?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.album?.description ?? '',
    );
    _classification =
        widget.album?.classification ??
        'Incompleto'; // Ensure it's always non-null
    _selectedPhotoPaths = List.from(widget.album?.photoUrls ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();

    if (images != null && images.isNotEmpty) {
      setState(() {
        _selectedPhotoPaths.addAll(images.map((e) => e.path));
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isSaving = true);

      try {
        if (widget.album == null) {
          await _draftService.addDraftAlbum(
            title: _titleController.text,
            description: _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
            photoUrls: _selectedPhotoPaths.isEmpty ? null : _selectedPhotoPaths,
            classification: _classification, // Now non-nullable
          );
        } else {
          final updatedAlbum = widget.album!.copyWith(
            title: _titleController.text,
            description: _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
            photoUrls: _selectedPhotoPaths.isEmpty ? [] : _selectedPhotoPaths,
            classification: _classification, // Now non-nullable
            updatedAt: DateTime.now(),
          );
          await _draftService.updateDraftAlbum(updatedAlbum);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Álbum guardado.'),
              backgroundColor: Colors.green,
            ),
          );
        }
        widget.onSave();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.album == null ? 'Crear Nuevo Álbum' : 'Editar Álbum',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título del Álbum',
                ),
                validator: (value) =>
                    value!.isEmpty ? 'El título no puede estar vacío' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (Opcional)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _classification,
                decoration: const InputDecoration(labelText: 'Clasificación'),
                items: _classificationOptions.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _classification = newValue!; // Safely assign non-null value
                  });
                },
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Fotos del Álbum:',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  ..._selectedPhotoPaths
                      .map(
                        (path) => Stack(
                          children: [
                            Image.file(
                              File(path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedPhotoPaths.remove(path);
                                  });
                                },
                                child: const CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add_a_photo, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      )
                    : const Text(
                        'Guardar Álbum',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
