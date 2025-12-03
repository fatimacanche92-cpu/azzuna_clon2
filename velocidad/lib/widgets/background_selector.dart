import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/card_data.dart';
import '../services/stable_diffusion_service.dart';
import 'dart:io';

class BackgroundSelector extends StatefulWidget {
  final CardData cardData;
  final Function(CardData) onBackgroundChanged;

  const BackgroundSelector({
    super.key,
    required this.cardData,
    required this.onBackgroundChanged,
  });

  @override
  State<BackgroundSelector> createState() => _BackgroundSelectorState();
}

class _BackgroundSelectorState extends State<BackgroundSelector> {
  bool _isGenerating = false;
  String? _errorMessage;
  late TextEditingController _promptController;

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController(
      text: widget.cardData.customBackgroundPrompt,
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _generateBackground() async {
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    // Guardar el prompt personalizado antes de generar
    final customPrompt = _promptController.text.trim();
    widget.onBackgroundChanged(
      widget.cardData.copyWith(customBackgroundPrompt: customPrompt),
    );

    try {
      final backgroundPath = await StableDiffusionService.generateBackground(
        occasion: widget.cardData.occasion,
        template: widget.cardData.template,
        customPrompt: customPrompt.isNotEmpty ? customPrompt : null,
      );

      if (backgroundPath != null && mounted) {
        widget.onBackgroundChanged(
          widget.cardData.copyWith(
            backgroundImageUrl: backgroundPath,
            useAIGeneratedBackground: true,
          ),
        );
        setState(() {
          _errorMessage = null; // Limpiar error si tuvo éxito
        });
      } else {
        setState(() {
          _errorMessage = 'No se pudo generar el fondo. Verifica tu conexión a internet y tu API key.';
        });
      }
    } catch (e) {
      String errorMsg = '';
      final errorString = e.toString();
      
      if (errorString.contains('CORS') || errorString.contains('Failed to fetch') || errorString.contains('Network')) {
        errorMsg = '⚠️ Error de conexión. Verifica tu internet. En Flutter Web hay restricciones CORS - usa Android para mejor compatibilidad.';
      } else if (errorString.contains('401') || errorString.contains('API key')) {
        errorMsg = '❌ API key inválida. Verifica tu token de Hugging Face en el código.';
      } else if (errorString.contains('429') || errorString.contains('Límite')) {
        errorMsg = '⏳ Límite de peticiones alcanzado. Espera unos minutos e intenta de nuevo.';
      } else if (errorString.contains('503')) {
        errorMsg = '⏳ El modelo está cargándose. Espera unos segundos e intenta de nuevo.';
      } else {
        errorMsg = 'Error: ${e.toString().replaceAll('Exception: ', '')}';
      }
      
      setState(() {
        _errorMessage = errorMsg;
      });
      
      // Log detallado para debugging
      print('Error completo generando fondo: $e');
      print('Stack trace: ${StackTrace.current}');
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  void _removeBackground() {
    widget.onBackgroundChanged(
      widget.cardData.copyWith(
        backgroundImageUrl: null,
        useAIGeneratedBackground: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Fondo Generado con IA',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            if (widget.cardData.useAIGeneratedBackground)
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: _removeBackground,
                tooltip: 'Quitar fondo',
              ),
          ],
        ),
        const SizedBox(height: 10),
        
        // Vista previa del fondo
        if (widget.cardData.backgroundImageUrl != null)
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(widget.cardData.backgroundImageUrl!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.error_outline, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ),
        
        const SizedBox(height: 15),
        
        // Campo de prompt personalizado
        Text(
          'Prompt Personalizado (Opcional)',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _promptController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Ej: "rosas rojas elegantes, fondo suave, estilo acuarela"',
            hintStyle: TextStyle(fontSize: 12, color: Colors.grey[500]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue[400]!, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.all(12),
          ),
          style: GoogleFonts.poppins(fontSize: 13),
          onChanged: (value) {
            // Guardar el prompt mientras el usuario escribe
            widget.onBackgroundChanged(
              widget.cardData.copyWith(customBackgroundPrompt: value),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Deja vacío para usar el prompt automático basado en la ocasión',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 15),
        
        // Botón para generar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isGenerating ? null : _generateBackground,
            icon: _isGenerating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(_isGenerating ? 'Generando...' : 'Generar Fondo con IA'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        
        if (_errorMessage != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.blue[700], size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '💡 Tip: Describe el fondo que quieres en español o inglés. Ejemplos: "flores rosas suaves", "fondo minimalista azul", "naturaleza verde vibrante"',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue[900],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

