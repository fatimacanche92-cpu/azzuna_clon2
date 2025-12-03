# 📋 Formato de Respuesta de n8n - Confirmado

## ✅ Formato Real

Según la prueba en Postman, n8n devuelve:

```json
{
  "json": {
    "image": "iVBORw0KGgoAAAANSUhEUgAABgAAAAYACAIAAAA/jBQ8AABEUGNhQ1gAAES4anVtYgAAAB5qdW1kY..."
  }
}
```

**Estructura:**
- Objeto raíz con clave `"json"`
- Dentro de `"json"`, hay una clave `"image"`
- El valor de `"image"` es un string base64 (sin prefijo `data:image/...`)

---

## 🔧 Código Actualizado

El código ahora maneja este formato como **prioridad principal**:

```dart
// Formato PRINCIPAL (Stability AI a través de n8n): { "json": { "image": "..." } }
if (jsonResponse.containsKey('json') && jsonResponse['json'] is Map) {
  final json = jsonResponse['json'] as Map;
  if (json.containsKey('image')) {
    base64Image = json['image'] as String?;
  }
}
```

---

## 🌐 URL Actualizada

**URL de Producción:**
```
https://dynamite666.app.n8n.cloud/webhook/azzuna-card
```

(Actualizada de `/webhook-test/` a `/webhook/`)

---

## ✅ Estado

- ✅ URL actualizada a producción
- ✅ Formato de respuesta detectado correctamente
- ✅ Código prioriza el formato real de n8n
- ✅ Mantiene compatibilidad con otros formatos por si acaso

---

## 🧪 Prueba

El webhook ya fue probado en Postman y devuelve:
- Status: `200 OK`
- Formato: `{"json": {"image": "base64..."}}`
- Funciona correctamente ✅

---

## 🚀 Listo para Usar

El código está listo para generar fondos usando Stability AI a través de n8n.

