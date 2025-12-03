import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/card_data.dart';
import '../services/message_generator.dart';
import '../widgets/card_factory.dart';
import 'customization_screen.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:screenshot/screenshot.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CardData _cardData = CardData();
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _updateMessage();
  }

  void _updateMessage() {
    setState(() {
      _cardData = _cardData.copyWith(
        message: MessageGenerator.generateMessage(
          _cardData.occasion,
          customMessage: _cardData.customMessage,
        ),
        // NO sobrescribir primaryColor - mantener el que el usuario eligió
      );
    });
  }

  void _onCardDataChanged(CardData newData) {
    setState(() {
      // Usar directamente los datos nuevos (ya incluyen los colores que el usuario eligió)
      _cardData = newData;
      
      // Solo actualizar mensaje si no hay mensaje personalizado
      if (newData.customMessage.isEmpty) {
        _updateMessage();
      }
      // Si hay mensaje personalizado, ya está en newData, no hacer nada más
    });
  }

  Future<void> _exportCard() async {
    if (!mounted) return;
    
    try {
      // Mostrar indicador de carga
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Generando PDF...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Capturar la imagen de la tarjeta
      final image = await _screenshotController.capture();
      
      if (image == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al capturar la tarjeta'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Convertir la imagen a PDF usando sharePdf
      await Printing.sharePdf(
        bytes: await _imageToPdf(image),
        filename: 'tarjeta_flores_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF generado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<Uint8List> _imageToPdf(Uint8List imageBytes) async {
    final pdf = pw.Document();
    final image = pw.MemoryImage(imageBytes);
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image, fit: pw.BoxFit.contain),
          );
        },
      ),
    );
    
    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768; // Breakpoint para móvil
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tarjetas de Flores',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: isMobile ? _buildMobileLayout(context) : _buildDesktopLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Vista previa de la tarjeta (arriba en móvil)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple[100]!,
                  Colors.pink[100]!,
                  Colors.purple[50]!,
                ],
              ),
            ),
            child: Column(
              children: [
                // Tarjeta adaptada al ancho del móvil
                Screenshot(
                  controller: _screenshotController,
                  child: SizedBox(
                    width: double.infinity,
                    child: AspectRatio(
                      aspectRatio: 2 / 3, // Proporción de tarjeta vertical
                      child: CardFactory.createCard(
                        cardData: _cardData,
                        // width y height null = responsive automático
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Botones adaptados para móvil
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullCardView(
                              cardData: _cardData,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.fullscreen),
                      label: const Text('Vista Completa'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _exportCard,
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Exportar PDF'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // Panel de personalización (abajo en móvil)
          Container(
            color: Colors.grey[50],
            child: CustomizationScreen(
              cardData: _cardData,
              onCardDataChanged: _onCardDataChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Panel de personalización
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.grey[50],
            child: CustomizationScreen(
              cardData: _cardData,
              onCardDataChanged: _onCardDataChanged,
            ),
          ),
        ),
        // Vista previa de la tarjeta
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple[100]!,
                  Colors.pink[100]!,
                  Colors.purple[50]!,
                ],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Screenshot(
                      controller: _screenshotController,
                      child: CardFactory.createCard(
                        cardData: _cardData,
                        // width y height null = responsive automático
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullCardView(
                                  cardData: _cardData,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.fullscreen),
                          label: const Text('Vista Completa'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        ElevatedButton.icon(
                          onPressed: _exportCard,
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Exportar PDF'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FullCardView extends StatelessWidget {
  final CardData cardData;

  const FullCardView({super.key, required this.cardData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista Completa'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple[100]!,
              Colors.pink[100]!,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: CardFactory.createCard(
              cardData: cardData,
              // width y height null = responsive automático
            ),
          ),
        ),
      ),
    );
  }
}

