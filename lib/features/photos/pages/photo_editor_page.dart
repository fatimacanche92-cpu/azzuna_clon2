import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart' as cropper;
import 'package:image_picker/image_picker.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import '../../gallery/models/album_model.dart';
import '../services/photo_service.dart';

class PhotoEditorPage extends StatefulWidget {
  const PhotoEditorPage({super.key});

  @override
  _PhotoEditorPageState createState() => _PhotoEditorPageState();
}

class _PhotoEditorPageState extends State<PhotoEditorPage> {
  File? _image;
  final PhotoService _photoService = PhotoService();
  final TextEditingController _titleController = TextEditingController();
  AlbumType? _selectedAlbumType;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      _cropImage(File(pickedFile.path));
    }
  }

  Future<void> _cropImage(File imageFile) async {
    final croppedFile = await cropper.ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: const cropper.CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        cropper.AndroidUiSettings(
          toolbarTitle: 'Recortar Imagen',
          toolbarColor: const Color(0xFFE91E63),
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: false,
        ),
        cropper.IOSUiSettings(title: 'Recortar Imagen'),
      ],
    );
    if (croppedFile != null) {
      setState(() {
        _image = File(croppedFile.path);
      });
    }
  }

  void _applyFilter() async {
    if (_image == null) return;

    final editedImage = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageEditor(image: _image!.readAsBytesSync()),
      ),
    );

    if (editedImage != null) {
      final tempFile = File('${Directory.systemTemp.path}/edited_image.jpg');
      await tempFile.writeAsBytes(editedImage);
      setState(() {
        _image = tempFile;
      });
    }
  }

  Future<void> _savePhoto() async {
    if (_image == null ||
        _titleController.text.isEmpty ||
        _selectedAlbumType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, selecciona una imagen, añade un título y elige un álbum.',
          ),
        ),
      );
      return;
    }

    try {
      // Here you would typically upload the image to a storage provider like Supabase Storage
      // and get the URL. For this example, we'll just use the local path.
      final imagePath = _image!.path;

      // This is a simplified logic. In a real app, you'd likely have a more robust
      // way to associate photos with albums, perhaps by selecting an existing album
      // or creating a new one.
      final albumId = _selectedAlbumType.toString(); // Simplified for example

      await _photoService.addPhoto(
        title: _titleController.text,
        path: imagePath,
        albumId: albumId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Foto guardada con éxito!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar la foto: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editor de Fotos',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFFE8F2),
      ),
      backgroundColor: const Color(0xFFFFE8F2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_image == null)
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Toca para seleccionar una imagen'),
                      ],
                    ),
                  ),
                ),
              ),
            if (_image != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.file(_image!, fit: BoxFit.cover),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Cambiar'),
                    style: _buttonStyle(),
                  ),
                  ElevatedButton.icon(
                    onPressed: _applyFilter,
                    icon: const Icon(Icons.filter),
                    label: const Text('Filtros'),
                    style: _buttonStyle(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _titleController,
                decoration: _inputDecoration('Título de la foto'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AlbumType>(
                value: _selectedAlbumType,
                decoration: _inputDecoration('Guardar en'),
                items: AlbumType.values
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type.name)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAlbumType = value;
                  });
                },
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _image != null ? _savePhoto : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE91E63),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            'Guardar Foto',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFE91E63),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(),
      filled: true,
      fillColor: Colors.white.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
