import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart'; // For social media sharing
import 'package:path_provider/path_provider.dart'; // For saving PDF
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io'; // For File

import '../../domain/models/catalog_album.dart';
import 'package:flutter_app/features/catalogs/data/repositories/catalog_service.dart';

class CatalogsPage extends StatefulWidget {
  const CatalogsPage({super.key});

  @override
  _CatalogsPageState createState() => _CatalogsPageState();
}

class _CatalogsPageState extends State<CatalogsPage> {
  final CatalogService _catalogService = CatalogService();
  List<CatalogAlbum> _allCatalogAlbums = [];
  bool _isLoading = true;

  static const Color primaryColor = Color(0xFF340A6B);

  @override
  void initState() {
    super.initState();
    _loadCatalogAlbums();
  }

  Future<void> _loadCatalogAlbums() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final albums = await _catalogService.getCatalogAlbums();
      setState(() {
        _allCatalogAlbums = albums;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar catálogos: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _exportAlbumAsPdf(CatalogAlbum album) async {
    setState(() {
      _isLoading = true; // Indicate loading during PDF generation
    });
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  album.title,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (album.description != null && album.description!.isNotEmpty)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 10),
                    child: pw.Text(album.description!),
                  ),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 10),
                  child: pw.Text('Estado: ${album.status}'),
                ),
                pw.SizedBox(height: 20),
                if (album.photoUrls.isNotEmpty)
                  pw.GridView(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    children: album.photoUrls.map((imageUrl) {
                      // For PDF, we need to load images as bytes
                      // This is a simplified example, in a real app you'd handle network/local images
                      // and potentially convert them to PdfImage
                      return pw.Container(
                        height: 150,
                        width: 150,
                        color: PdfColors.grey300,
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          'Image Placeholder',
                        ), // Placeholder for actual image
                      );
                    }).toList(),
                  ),
              ],
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File(
        "${output.path}/${album.title.replaceAll(' ', '_')}.pdf",
      );
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF exportado a ${file.path}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _shareAlbum(CatalogAlbum album) async {
    try {
      String shareText = '''¡Mira este álbum de flores: ${album.title}!
''';
      if (album.description != null && album.description!.isNotEmpty) {
        shareText += '''${album.description}
''';
      }
      shareText += '''Estado: ${album.status}
''';
      shareText += 'Fotos: ${album.photoUrls.length}';

      await Share.share(shareText);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al compartir: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Catálogos',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF3E5F5),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _allCatalogAlbums.isEmpty
                ? const Center(child: Text('No hay álbumes en catálogo.'))
                : ListView.builder(
                    itemCount: _allCatalogAlbums.length,
                    itemBuilder: (context, index) {
                      return _buildCatalogAlbumCard(_allCatalogAlbums[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogAlbumCard(CatalogAlbum album) {
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
                'Estado: ${album.status}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'export_pdf') {
              _exportAlbumAsPdf(album);
            } else if (value == 'share') {
              _shareAlbum(album);
            } else if (value == 'delete') {
              // Implement delete functionality
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'export_pdf',
              child: Text('Exportar a PDF'),
            ),
            const PopupMenuItem<String>(
              value: 'share',
              child: Text('Compartir'),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Text('Eliminar'),
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
