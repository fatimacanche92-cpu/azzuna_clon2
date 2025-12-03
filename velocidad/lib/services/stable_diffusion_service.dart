import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/card_data.dart';

class StableDiffusionService {
  // URL del webhook de n8n que maneja Stability AI
  // Usa Stability AI a través de n8n (no Stable Diffusion directo)
  static const String _n8nWebhookUrl = 
    'https://dynamite666.app.n8n.cloud/webhook/azzuna-card';
  
  // Cache de fondos generados
  static final Map<String, String> _backgroundCache = {};

  /// Genera un prompt para el fondo según la ocasión
  static String _generateBackgroundPrompt(SpecialOccasion occasion, CardTemplate template) {
    final occasionPrompts = {
      SpecialOccasion.valentines: 'romantic red roses, soft pink petals, elegant floral arrangement, dreamy atmosphere, soft lighting, watercolor style',
      SpecialOccasion.mothersDay: 'beautiful spring flowers bouquet, pastel colors, soft pink and white roses, delicate petals, warm sunlight, gentle background',
      SpecialOccasion.birthday: 'colorful birthday flowers, vibrant colors, celebration flowers, confetti style, joyful atmosphere, bright and cheerful',
      SpecialOccasion.wedding: 'elegant white flowers, bridal bouquet, soft pastels, romantic garden, sophisticated floral arrangement, elegant style',
      SpecialOccasion.anniversary: 'romantic flower arrangement, elegant roses, soft romantic lighting, sophisticated floral design, warm colors',
      SpecialOccasion.graduation: 'proud graduation flowers, bright and celebratory, achievement flowers, vibrant colors, success theme',
      SpecialOccasion.sympathy: 'peaceful white flowers, serene floral arrangement, calm and gentle, soft pastels, respectful and elegant',
      SpecialOccasion.congratulations: 'celebratory flowers, bright and joyful, success flowers, vibrant arrangement, congratulatory theme',
      SpecialOccasion.thankYou: 'grateful flower arrangement, warm colors, appreciation flowers, friendly and warm, thank you theme',
      SpecialOccasion.christmas: 'christmas flowers, red poinsettias, green holly leaves, festive holiday arrangement, warm christmas colors, elegant winter flowers, holiday spirit',
      SpecialOccasion.newYear: 'celebratory new year flowers, golden accents, elegant arrangement, festive atmosphere, bright and joyful, new beginnings theme',
      SpecialOccasion.easter: 'easter flowers, spring pastels, white lilies, soft colors, fresh spring arrangement, renewal theme, gentle and peaceful',
      SpecialOccasion.halloween: 'dark elegant flowers, deep purple and black, mysterious autumn arrangement, sophisticated dark colors, elegant gothic style',
      SpecialOccasion.none: 'beautiful floral arrangement, elegant flowers, soft colors, gentle background, professional floral design',
    };

    final templateStyles = {
      CardTemplate.romantic: 'romantic, dreamy, soft focus',
      CardTemplate.elegant: 'elegant, sophisticated, refined',
      CardTemplate.modern: 'modern, minimalist, contemporary',
      CardTemplate.classic: 'classic, traditional, timeless',
      CardTemplate.spring: 'spring, fresh, vibrant, natural',
      CardTemplate.wedding: 'bridal, elegant, white and pastels',
    };

    final basePrompt = occasionPrompts[occasion] ?? occasionPrompts[SpecialOccasion.none]!;
    final style = templateStyles[template] ?? '';
    
    return '$basePrompt, $style, background pattern, no text, no words, decorative floral background, high quality, 4k';
  }

  /// Genera un fondo usando Stability AI a través de n8n
  static Future<String?> generateBackground({
    required SpecialOccasion occasion,
    required CardTemplate template,
    String? customPrompt, // Prompt personalizado del usuario
    String? apiKey, // Mantenido para compatibilidad, pero no se usa
  }) async {
    // Determinar si es prompt personalizado
    final isCustomPrompt = customPrompt != null && customPrompt.trim().isNotEmpty;
    
    // Usar prompt personalizado si existe, sino generar uno automático
    // Si es personalizado, hacerlo más explícito para que Stability AI lo respete
    final prompt = isCustomPrompt
        ? '${customPrompt.trim()}, exact colors as described, background pattern, no text, no words, decorative floral background, high quality, 4k'
        : _generateBackgroundPrompt(occasion, template);
    
    // Crear clave de cache que incluye el prompt para diferenciar imágenes personalizadas
    final promptHash = isCustomPrompt
        ? _hashString(customPrompt.trim())
        : 'auto';
    final cacheKey = '${occasion.name}_${template.name}_$promptHash';
    
    // Verificar cache
    if (_backgroundCache.containsKey(cacheKey)) {
      print('✅ Fondo encontrado en cache: $cacheKey');
      return _backgroundCache[cacheKey];
    }

    // Verificar cache persistente
    final cachedPath = await _getCachedBackground(cacheKey);
    if (cachedPath != null) {
      _backgroundCache[cacheKey] = cachedPath;
      print('✅ Fondo encontrado en cache persistente: $cacheKey');
      return cachedPath;
    }
    
    try {
      print('🔵 Llamando a n8n webhook...');
      print('   URL: $_n8nWebhookUrl');
      print('   Prompt: $prompt');
      print('   Ocasión: ${occasion.name}');
      print('   Template: ${template.name}');
      print('   Prompt personalizado: ${isCustomPrompt ? "Sí" : "No (automático)"}');
      
      // Preparar petición para n8n
      // Si es prompt personalizado, enviar SOLO el prompt para evitar que n8n lo modifique
      // Si es automático, enviar prompt + occasion + template para que n8n pueda usar contexto
      final requestBody = isCustomPrompt
          ? jsonEncode({
              'prompt': prompt,
              // NO enviar occasion/template cuando es personalizado para evitar que n8n modifique el prompt
            })
          : jsonEncode({
              'prompt': prompt,
              'occasion': occasion.name,
              'template': template.name,
            });
      
      // Llamar al webhook de n8n
      final response = await http.post(
        Uri.parse(_n8nWebhookUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      ).timeout(
        const Duration(seconds: 90), // n8n puede tardar más
        onTimeout: () {
          throw Exception('Timeout: El webhook de n8n tardó demasiado. Verifica que el flujo esté activo.');
        },
      );
      
      print('📡 Respuesta de n8n recibida:');
      print('   Status: ${response.statusCode}');
      print('   Content-Type: ${response.headers['content-type']}');
      print('   Body length: ${response.body.length} caracteres');

      if (response.statusCode == 200) {
        // n8n devuelve JSON con la imagen en base64
        try {
          final jsonResponse = jsonDecode(response.body);
          
          // Intentar diferentes formatos posibles de respuesta de n8n
          String? base64Image;
          
          // Formato PRINCIPAL (Stability AI a través de n8n): { "json": { "image": "..." } }
          if (jsonResponse.containsKey('json') && jsonResponse['json'] is Map) {
            final json = jsonResponse['json'] as Map;
            if (json.containsKey('image')) {
              base64Image = json['image'] as String?;
            }
          }
          // Formato 1: { "image": "data:image/png;base64,..." }
          else if (jsonResponse.containsKey('image')) {
            base64Image = jsonResponse['image'] as String?;
          }
          // Formato 2: { "data": "data:image/png;base64,..." }
          else if (jsonResponse.containsKey('data')) {
            base64Image = jsonResponse['data'] as String?;
          }
          // Formato 3: { "body": { "image": "..." } }
          else if (jsonResponse.containsKey('body')) {
            final body = jsonResponse['body'];
            if (body is Map && body.containsKey('image')) {
              base64Image = body['image'] as String?;
            }
          }
          // Formato 4: Array con objeto que tiene "image" o "json"
          else if (jsonResponse is List && jsonResponse.isNotEmpty) {
            final firstItem = jsonResponse[0];
            if (firstItem is Map) {
              if (firstItem.containsKey('image')) {
                base64Image = firstItem['image'] as String?;
              } else if (firstItem.containsKey('json') && firstItem['json'] is Map) {
                final json = firstItem['json'] as Map;
                if (json.containsKey('image')) {
                  base64Image = json['image'] as String?;
                }
              }
            }
          }
          
          if (base64Image == null || base64Image.isEmpty) {
            print('⚠️ Respuesta de n8n no contiene imagen. Respuesta completa:');
            print(response.body);
            // Si la respuesta está vacía o no contiene imagen, usar fallback (imagen placeholder)
            print('⚠️ Usando fallback de imagen pública (picsum) por respuesta vacía/no válida.');
            try {
              final fallback = await http.get(Uri.parse('https://picsum.photos/seed/fallback_${DateTime.now().millisecondsSinceEpoch}/800/600')).timeout(const Duration(seconds: 20));
              if (fallback.statusCode == 200 && fallback.bodyBytes.isNotEmpty) {
                final savedPath = await _saveBackgroundToCache(cacheKey, fallback.bodyBytes);
                _backgroundCache[cacheKey] = savedPath;
                print('✅ Fondo de fallback generado y guardado: $savedPath');
                return savedPath;
              } else {
                throw Exception('Fallback failed with status ${fallback.statusCode}');
              }
            } catch (e) {
              print('❌ Error generando fallback: $e');
              throw Exception('El webhook de n8n no devolvió una imagen y el fallback falló.');
            }
          }
          
          // Limpiar el prefijo data:image/...;base64, si existe
          String cleanBase64 = base64Image;
          if (base64Image.contains(',')) {
            cleanBase64 = base64Image.split(',').last;
          }
          
          // Decodificar base64 a bytes
          List<int> imageBytes;
          try {
            imageBytes = base64Decode(cleanBase64);
          } catch (e) {
            print('❌ Error decodificando base64: $e');
            throw Exception('Error al decodificar la imagen base64 del webhook. Verifica el formato de respuesta de n8n.');
          }
          
          if (imageBytes.isEmpty) {
            throw Exception('La imagen decodificada está vacía');
          }
          
          print('✅ Imagen decodificada: ${imageBytes.length} bytes');
          
          // Guardar en cache local
          final savedPath = await _saveBackgroundToCache(cacheKey, imageBytes);
          _backgroundCache[cacheKey] = savedPath;
          
          print('✅ Fondo generado exitosamente a través de n8n');
          return savedPath;
          
        } catch (e) {
          // Si el parseo falla (JSON inválido), intentar fallback igual que en caso de body vacío
          print('❌ Error parseando JSON de n8n: $e');
          try {
            print('Intentando fallback de imagen pública (picsum) tras error de parseo.');
            final fallback = await http.get(Uri.parse('https://picsum.photos/seed/fallback_${DateTime.now().millisecondsSinceEpoch}/800/600')).timeout(const Duration(seconds: 20));
            if (fallback.statusCode == 200 && fallback.bodyBytes.isNotEmpty) {
              final savedPath = await _saveBackgroundToCache(cacheKey, fallback.bodyBytes);
              _backgroundCache[cacheKey] = savedPath;
              print('✅ Fondo de fallback generado y guardado: $savedPath');
              return savedPath;
            } else {
              print('❌ Fallback devolvió status ${fallback.statusCode}');
            }
          } catch (fb) {
            print('❌ Error en fallback tras parseo: $fb');
          }

          // Finalmente, rethrow el error original para que el caller lo conozca si todo falla
          rethrow;
        }
        
      } else if (response.statusCode == 404) {
        throw Exception('Webhook de n8n no encontrado. Verifica que el flujo esté activo y la URL sea correcta.');
      } else if (response.statusCode == 500) {
        throw Exception('Error interno en el webhook de n8n. Verifica los logs de n8n.');
      } else {
        String errorBody = response.body.length > 200 
            ? '${response.body.substring(0, 200)}...' 
            : response.body;
        try {
          final jsonError = jsonDecode(response.body);
          if (jsonError.containsKey('error')) {
            errorBody = jsonError['error'].toString();
          } else if (jsonError.containsKey('message')) {
            errorBody = jsonError['message'].toString();
          }
        } catch (_) {
          // Si no es JSON, usar el body tal cual
        }
        throw Exception('Error ${response.statusCode} del webhook de n8n: $errorBody');
      }
      
    } catch (e) {
      // Error de red, timeout, o procesamiento
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error llamando al webhook de n8n: ${e.toString()}');
    }
  }

  /// Guarda el fondo en cache local
  static Future<String> _saveBackgroundToCache(String key, List<int> imageBytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final backgroundDir = Directory('${directory.path}/card_backgrounds');
    
    if (!await backgroundDir.exists()) {
      await backgroundDir.create(recursive: true);
    }

    final file = File('${backgroundDir.path}/$key.png');
    await file.writeAsBytes(imageBytes);

    // Guardar en SharedPreferences para referencia
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('background_$key', file.path);

    return file.path;
  }

  /// Obtiene fondo del cache
  static Future<String?> _getCachedBackground(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('background_$key');
    
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        return path;
      }
    }
    
    return null;
  }

  /// Limpia el cache de fondos
  static Future<void> clearCache() async {
    _backgroundCache.clear();
    
    final directory = await getApplicationDocumentsDirectory();
    final backgroundDir = Directory('${directory.path}/card_backgrounds');
    
    if (await backgroundDir.exists()) {
      await backgroundDir.delete(recursive: true);
    }

    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('background_'));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  /// Obtiene fondos pre-generados para diferentes ocasiones
  static Future<Map<String, String?>> preGenerateBackgrounds({
    required List<SpecialOccasion> occasions,
    required List<CardTemplate> templates,
    String? apiKey, // Mantenido para compatibilidad
  }) async {
    final results = <String, String?>{};
    
    for (final occasion in occasions) {
      for (final template in templates) {
        final key = '${occasion.name}_${template.name}';
        try {
          final path = await generateBackground(
            occasion: occasion,
            template: template,
            customPrompt: null, // Pre-generar solo con prompts automáticos
            apiKey: apiKey,
          );
          results[key] = path;
        } catch (e) {
          print('Error pre-generando fondo $key: $e');
          results[key] = null;
        }
      }
    }
    
    return results;
  }
  
  /// Genera un hash simple de un string para usar en cache keys
  static String _hashString(String input) {
    // Hash simple basado en el código hash del string
    // Solo para diferenciar prompts en el cache, no necesita ser criptográficamente seguro
    return input.hashCode.abs().toString();
  }
  
  /// Actualiza la URL del webhook de n8n (útil para cambiar entre test y producción)
  static void updateWebhookUrl(String newUrl) {
    // Nota: Como _n8nWebhookUrl es const, esto requeriría refactorizar
    // Por ahora, modifica directamente la constante _n8nWebhookUrl arriba
    print('⚠️ Para cambiar la URL del webhook, modifica _n8nWebhookUrl en stable_diffusion_service.dart');
  }
}

