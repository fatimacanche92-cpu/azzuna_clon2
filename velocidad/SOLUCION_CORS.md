# 🔧 Solución al Problema de CORS

## Problema

Cuando intentas generar fondos con IA desde Flutter Web, obtienes un error de CORS:
```
Access to fetch at 'https://api-inference.huggingface.co/...' 
has been blocked by CORS policy
```

## ¿Por qué pasa esto?

Los navegadores bloquean peticiones HTTP directas a APIs externas por seguridad. Hugging Face API no permite peticiones directas desde el navegador.

## Soluciones

### ✅ Opción 1: Usar la App en Android (RECOMENDADO)

**La forma más fácil:**
- Construye la app para Android: `flutter build apk --release`
- En Android NO hay problema de CORS
- Funciona perfectamente sin configuración adicional

### ✅ Opción 2: Crear un Backend/Proxy Simple

Crea un servidor pequeño que haga las peticiones por ti:

**Ejemplo con Node.js/Express:**
```javascript
// server.js
const express = require('express');
const cors = require('cors');
const fetch = require('node-fetch');

const app = express();
app.use(cors());

app.post('/api/generate-background', async (req, res) => {
  const { prompt, apiKey } = req.body;
  
  const response = await fetch('https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ inputs: prompt }),
  });
  
  const imageBuffer = await response.buffer();
  res.set('Content-Type', 'image/png');
  res.send(imageBuffer);
});

app.listen(3000);
```

Luego actualiza `stable_diffusion_service.dart` para usar tu servidor:
```dart
static const String _apiUrl = 'http://localhost:3000/api/generate-background';
```

### ⚠️ Opción 3: Proxy CORS Público (Solo Desarrollo)

**NO recomendado para producción**, pero útil para pruebas:

```dart
// En stable_diffusion_service.dart
static const String _corsProxy = 'https://cors-anywhere.herokuapp.com/';
static const String _apiUrl = '${_corsProxy}https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0';
```

**Problemas:**
- Puede ser lento
- No confiable
- Puede tener límites
- No seguro para producción

## 🎯 Recomendación

**Para tu caso (negocio de flores, sin dinero, poco tiempo):**

1. **Usa Android**: Construye el APK y úsalo en un dispositivo Android
   ```bash
   flutter build apk --release
   ```
   - ✅ No hay problema de CORS
   - ✅ Funciona perfectamente
   - ✅ No necesitas servidor

2. **Para Web**: Si realmente necesitas web, crea un backend simple (puede ser gratis con servicios como Vercel, Netlify Functions, o Railway)

## 📝 Nota

El código actual funciona perfectamente en Android. El problema de CORS solo afecta a Flutter Web cuando se ejecuta en el navegador.

