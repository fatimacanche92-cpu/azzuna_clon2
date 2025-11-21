import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/album_model.dart';
import '../services/album_service.dart';
// As AlbumDetailPage is not being fixed in this scope, we can comment out the import
// import 'album_detail_page.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AlbumService _albumService = AlbumService();

  List<Album> _catalogos = [];
  List<Album> _borradores = [];
  bool _isLoading = true;

  static const Color primaryColor = Color(0xFF340A6B);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAlbums();
  }

  Future<void> _loadAlbums() async {
    setState(() => _isLoading = true);
    try {
      final catalogos = await _albumService.getAlbums(AlbumType.catalogo);
      final borradores = await _albumService.getAlbums(AlbumType.borrador);
      setState(() {
        _catalogos = catalogos;
        _borradores = borradores;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar álbumes: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAlbumForm({Album? album}) {
    final currentType = AlbumType.values[_tabController.index];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _AlbumForm(
          album: album,
          albumType: currentType,
          onSave: () {
            _loadAlbums();
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
          'Galería',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Catálogos'),
            Tab(text: 'Borradores'),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF3E5F5),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAlbumGrid(_catalogos),
                _buildAlbumGrid(_borradores),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'galleryFAB',
        onPressed: () => _showAlbumForm(),
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAlbumGrid(List<Album> albums) {
    if (albums.isEmpty) {
      return const Center(child: Text('No hay álbumes en esta sección.'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        return Card(
          elevation: 4,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: InkWell(
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => AlbumDetailPage(album: album),
              //   ),
              // );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Navegando a los detalles de "${album.name}"... (No implementado)',
                  ),
                ),
              );
            },
            child: GridTile(
              footer: GridTileBar(
                backgroundColor: Colors.black45,
                title: Text(
                  album.name,
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
              header: Align(
                alignment: Alignment.topRight,
                child: _buildPopupMenu(album),
              ),
              child: const Icon(
                Icons.photo_album,
                size: 60,
                color: primaryColor,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopupMenu(Album album) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.black54),
      onSelected: (value) {
        if (value == 'edit') {
          _showAlbumForm(album: album);
        } else if (value == 'delete') {
          _deleteAlbum(album);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Text('Editar')),
        const PopupMenuItem(
          value: 'delete',
          child: Text('Eliminar', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  Future<void> _deleteAlbum(Album album) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que quieres eliminar el álbum "${album.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _albumService.deleteAlbum(album.id);
        _loadAlbums();
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
              content: Text('Error al eliminar: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _AlbumForm extends StatefulWidget {
  final Album? album;
  final AlbumType albumType;
  final VoidCallback onSave;

  const _AlbumForm({this.album, required this.albumType, required this.onSave});

  @override
  __AlbumFormState createState() => __AlbumFormState();
}

class __AlbumFormState extends State<_AlbumForm> {
  final _formKey = GlobalKey<FormState>();
  final _albumService = AlbumService();
  late String _name;
  late String _description;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _name = widget.album?.name ?? '';
    _description = widget.album?.description ?? '';
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isSaving = true);

      try {
        if (widget.album == null) {
          await _albumService.addAlbum(
            name: _name,
            description: _description,
            type: widget.albumType,
          );
        } else {
          final updatedAlbum = widget.album!.copyWith(
            name: _name,
            description: _description,
          );
          await _albumService.updateAlbum(updatedAlbum);
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.album == null ? 'Crear Álbum' : 'Editar Álbum',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: _name,
              decoration: const InputDecoration(labelText: 'Nombre del álbum'),
              validator: (value) =>
                  value!.isEmpty ? 'El nombre no puede estar vacío' : null,
              onSaved: (value) => _name = value!,
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: _description,
              decoration: const InputDecoration(
                labelText: 'Descripción (Opcional)',
              ),
              onSaved: (value) => _description = value ?? '',
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSaving ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _GalleryPageState.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    )
                  : const Text(
                      'Guardar',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
