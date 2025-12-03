# 🎯 Plan de Acción: Integración con n8n Webhook

## 📋 Situación Actual

**Problema:**
- La API directa de Hugging Face no funciona correctamente
- Errores de conexión, CORS, y disponibilidad de modelos

**Solución Propuesta:**
- Usar el webhook de n8n que ya funciona
- n8n maneja la comunicación con Stable Diffusion
- n8n devuelve la imagen en base64 (según las imágenes mostradas)

## 🔍 Análisis del Flujo de n8n

**Flujo actual en n8n:**
1. **Webhook** → Recibe petición POST
2. **HTTP Request** → Llama a Stability AI API
3. **Code (JavaScript)** → Procesa la respuesta
4. **Respond to Webhook** → Devuelve JSON con base64

**URL del Webhook:**
```
https://dynamite666.app.n8n.cloud/webhook-test/azzuna-card
```

**Método:** POST

## 🎯 Plan de Implementación

### Fase 1: Análisis y Preparación ✅

**Tareas:**
1. ✅ Entender el flujo actual de n8n
2. ✅ Identificar qué datos necesita n8n (probablemente el prompt)
3. ✅ Identificar qué devuelve n8n (JSON con base64)
4. ✅ Documentar el formato esperado

**Resultado esperado:**
- Documento con la estructura de petición/respuesta
- Ejemplo de cómo debería funcionar

---

### Fase 2: Modificar el Servicio 🔧

**Archivo a modificar:** `lib/services/stable_diffusion_service.dart`

**Cambios necesarios:**

1. **Reemplazar URLs de Hugging Face por URL de n8n**
   ```dart
   // ANTES:
   static const List<String> _modelUrls = [
     'https://api-inference.huggingface.co/models/...',
     ...
   ];
   
   // DESPUÉS:
   static const String _n8nWebhookUrl = 
     'https://dynamite666.app.n8n.cloud/webhook-test/azzuna-card';
   ```

2. **Cambiar el formato de la petición**
   ```dart
   // n8n probablemente espera:
   {
     "prompt": "romantic red roses...",
     "occasion": "valentines",
     "template": "romantic"
   }
   ```

3. **Procesar respuesta de n8n (base64)**
   ```dart
   // n8n devuelve probablemente:
   {
     "image": "data:image/png;base64,iVBORw0KGgo...",
     "success": true
   }
   
   // Necesitamos:
   // 1. Extraer el base64
   // 2. Decodificar a bytes
   // 3. Guardar como archivo
   ```

4. **Mantener el sistema de cache**
   - El cache sigue funcionando igual
   - Solo cambia la fuente de la imagen

---

### Fase 3: Manejo de Errores ⚠️

**Errores a manejar:**
- Webhook no disponible (404, 500)
- Timeout de n8n
- Respuesta inválida de n8n
- Base64 corrupto o inválido

**Estrategia:**
- Mantener mensajes de error claros
- Logging detallado para debugging
- Fallback a gradientes si n8n falla

---

### Fase 4: Optimizaciones 🚀

**Mejoras posibles:**
1. **Parámetros adicionales para n8n**
   - Dimensiones personalizadas
   - Estilo específico
   - Calidad de imagen

2. **Validación de respuesta**
   - Verificar que el JSON tenga el formato correcto
   - Verificar que el base64 sea válido
   - Verificar que la imagen se pueda decodificar

3. **Retry inteligente**
   - Si n8n falla, reintentar 1-2 veces
   - Con delay exponencial

---

## 📝 Estructura de Código Propuesta

### Nuevo método principal:
```dart
static Future<String?> generateBackground({
  required SpecialOccasion occasion,
  required CardTemplate template,
}) async {
  // 1. Verificar cache (igual que antes)
  
  // 2. Generar prompt (igual que antes)
  
  // 3. Llamar a n8n webhook
  final response = await http.post(
    Uri.parse(_n8nWebhookUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'prompt': prompt,
      'occasion': occasion.name,
      'template': template.name,
    }),
  );
  
  // 4. Procesar respuesta base64
  final jsonResponse = jsonDecode(response.body);
  final base64Image = jsonResponse['image']; // Ajustar según formato real
  
  // 5. Decodificar y guardar
  final imageBytes = base64Decode(base64Image.split(',')[1]);
  final cachedPath = await _saveBackgroundToCache(cacheKey, imageBytes);
  
  return cachedPath;
}
```

---

## 🔧 Pasos de Implementación

### Paso 1: Probar el Webhook Manualmente
- Hacer una petición POST con Postman/curl
- Ver exactamente qué formato devuelve n8n
- Documentar la estructura

### Paso 2: Implementar la Llamada Básica
- Reemplazar URLs de Hugging Face
- Implementar petición a n8n
- Procesar respuesta base64

### Paso 3: Probar y Ajustar
- Probar con diferentes ocasiones
- Verificar que las imágenes se generen correctamente
- Ajustar formato de petición si es necesario

### Paso 4: Manejo de Errores
- Agregar manejo de errores específico
- Mejorar mensajes de error
- Agregar logging

### Paso 5: Optimizaciones
- Agregar parámetros adicionales si n8n los soporta
- Mejorar retry logic
- Optimizar procesamiento de base64

---

## ✅ Ventajas de Esta Solución

1. **✅ Funciona** - n8n ya está funcionando
2. **✅ Sin CORS** - n8n maneja las peticiones
3. **✅ Más confiable** - n8n puede tener retry y manejo de errores
4. **✅ Flexible** - Puedes modificar el flujo en n8n sin cambiar código
5. **✅ Mantiene cache** - El sistema de cache sigue igual

---

## ⚠️ Consideraciones

1. **URL del Webhook:**
   - Actualmente es `/webhook-test/` (test)
   - Probablemente necesites cambiar a `/webhook/` (producción) cuando esté listo

2. **Formato de Respuesta:**
   - Necesitamos confirmar el formato exacto que devuelve n8n
   - Puede ser `{"image": "base64..."}` o `{"data": "base64..."}`

3. **Autenticación:**
   - Verificar si n8n requiere autenticación
   - Si es público, está bien
   - Si requiere auth, agregar headers

4. **Rate Limiting:**
   - n8n puede tener límites de ejecuciones
   - Considerar cache más agresivo

---

## 🚀 Siguiente Paso

**Necesito:**
1. Confirmar el formato exacto que devuelve n8n
2. Confirmar si necesita algún parámetro específico
3. Probar una petición manual para ver la respuesta

**¿Quieres que implemente esto ahora o prefieres probar primero el webhook manualmente?**

