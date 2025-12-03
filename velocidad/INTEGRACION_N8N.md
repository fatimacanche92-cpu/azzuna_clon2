# 🔗 Integración con n8n Webhook - Implementada

## ✅ Cambios Realizados

### 1. Servicio Modificado: `lib/services/stable_diffusion_service.dart`

**Antes:**
- Llamaba directamente a la API de Hugging Face
- Múltiples modelos con fallback
- Manejo complejo de errores de API

**Ahora:**
- Llama al webhook de n8n: `https://dynamite666.app.n8n.cloud/webhook-test/azzuna-card`
- n8n maneja la comunicación con Stable Diffusion
- Procesa respuesta base64 de n8n

---

## 📡 Formato de Petición a n8n

El servicio envía un POST con este formato:

```json
{
  "prompt": "romantic red roses, soft pink petals...",
  "occasion": "valentines",
  "template": "romantic"
}
```

**Headers:**
```
Content-Type: application/json
```

---

## 📥 Formato de Respuesta Esperado de n8n

El código está preparado para manejar **múltiples formatos** posibles:

### Formato 1 (Recomendado):
```json
{
  "image": "data:image/png;base64,iVBORw0KGgo..."
}
```

### Formato 2:
```json
{
  "data": "data:image/png;base64,iVBORw0KGgo..."
}
```

### Formato 3:
```json
{
  "body": {
    "image": "data:image/png;base64,iVBORw0KGgo..."
  }
}
```

### Formato 4 (Array de n8n):
```json
[
  {
    "image": "data:image/png;base64,iVBORw0KGgo..."
  }
]
```

### Formato 5 (JSON anidado):
```json
[
  {
    "json": {
      "image": "data:image/png;base64,iVBORw0KGgo..."
    }
  }
]
```

**El código detecta automáticamente cuál formato estás usando.**

---

## 🔧 Configuración del Flujo de n8n

### Paso 1: Webhook Node
- **Método:** POST
- **Path:** `azzuna-card` (o el que prefieras)
- **Authentication:** None (o la que necesites)

### Paso 2: HTTP Request Node
- **URL:** `https://api.stability.ai/v2beta/stable-image/generate/sd3`
- **Método:** POST
- **Headers:**
  ```
  Authorization: Bearer YOUR_STABILITY_AI_API_KEY
  Content-Type: application/json
  ```
- **Body:**
  ```json
  {
    "prompt": "{{ $json.prompt }}",
    "aspect_ratio": "1:1",
    "output_format": "png"
  }
  ```

### Paso 3: Code Node (JavaScript)
Procesa la respuesta y devuelve base64:

```javascript
// Obtener la imagen de la respuesta
const imageBytes = $input.item.json.image;

// Convertir a base64
const base64Image = Buffer.from(imageBytes).toString('base64');

// Devolver con el formato esperado
return {
  json: {
    image: `data:image/png;base64,${base64Image}`
  }
};
```

**O si Stability AI ya devuelve base64:**
```javascript
// Si la respuesta ya viene en base64
return {
  json: {
    image: $input.item.json.image // o el campo que tenga la imagen
  }
};
```

### Paso 4: Respond to Webhook Node
- Devuelve el JSON con la imagen en base64

---

## 🧪 Probar el Webhook

### Con Postman o curl:

```bash
curl -X POST https://dynamite666.app.n8n.cloud/webhook-test/azzuna-card \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "romantic red roses, soft pink petals, elegant floral arrangement",
    "occasion": "valentines",
    "template": "romantic"
  }'
```

**Respuesta esperada:**
```json
{
  "image": "data:image/png;base64,iVBORw0KGgo..."
}
```

---

## 🐛 Debugging

### Si el webhook no funciona:

1. **Verifica que el flujo esté activo en n8n**
   - Debe estar en estado "Active" (toggle verde)

2. **Revisa los logs de n8n**
   - Ve a "Executions" en n8n
   - Revisa los errores de cada ejecución

3. **Verifica el formato de respuesta**
   - El código imprime la respuesta completa en la consola
   - Busca en los logs de Flutter: `📡 Respuesta de n8n recibida:`

4. **Prueba el webhook manualmente**
   - Usa Postman o curl para verificar que funciona
   - Verifica que devuelva el formato correcto

### Logs en Flutter:

El servicio imprime información detallada:
```
🔵 Llamando a n8n webhook...
   URL: https://dynamite666.app.n8n.cloud/webhook-test/azzuna-card
   Prompt: romantic red roses...
   Ocasión: valentines
   Template: romantic

📡 Respuesta de n8n recibida:
   Status: 200
   Content-Type: application/json
   Body length: 12345 caracteres

✅ Imagen decodificada: 123456 bytes
✅ Fondo generado exitosamente a través de n8n
```

---

## ⚙️ Configuración Avanzada

### Cambiar URL del Webhook

Edita `lib/services/stable_diffusion_service.dart`:

```dart
static const String _n8nWebhookUrl = 
  'https://dynamite666.app.n8n.cloud/webhook/azzuna-card'; // Producción
```

**Nota:** Cambia de `/webhook-test/` a `/webhook/` cuando esté listo para producción.

### Agregar Autenticación

Si n8n requiere autenticación, modifica la petición:

```dart
final response = await http.post(
  Uri.parse(_n8nWebhookUrl),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer YOUR_N8N_TOKEN', // Si es necesario
  },
  body: requestBody,
);
```

---

## ✅ Ventajas de Esta Solución

1. **✅ Funciona** - n8n ya está funcionando
2. **✅ Sin CORS** - n8n maneja las peticiones
3. **✅ Más confiable** - n8n puede tener retry y manejo de errores
4. **✅ Flexible** - Puedes modificar el flujo en n8n sin cambiar código
5. **✅ Mantiene cache** - El sistema de cache sigue igual
6. **✅ Mejor debugging** - Logs detallados en ambos lados

---

## 🚀 Próximos Pasos

1. **Probar el webhook manualmente** con Postman
2. **Verificar el formato de respuesta** que devuelve n8n
3. **Ajustar el código si es necesario** según el formato real
4. **Probar en la app** generando un fondo
5. **Cambiar a producción** cuando esté listo (`/webhook/` en lugar de `/webhook-test/`)

---

## 📝 Notas Importantes

- El cache sigue funcionando igual que antes
- Los prompts se generan igual que antes
- Solo cambió la fuente de la imagen (n8n en lugar de Hugging Face directo)
- El código es flexible y detecta automáticamente el formato de respuesta

---

## ❓ ¿Necesitas Ayuda?

Si el formato de respuesta de n8n es diferente, comparte:
1. Un ejemplo de la respuesta JSON que devuelve n8n
2. Los logs de Flutter cuando falla
3. Los logs de n8n de la ejecución

Con eso puedo ajustar el código para que funcione perfectamente.

