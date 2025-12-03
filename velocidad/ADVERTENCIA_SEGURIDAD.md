# ⚠️ Advertencia de Seguridad

## API Key Incluida en el Código

Tu API key de Hugging Face está incluida directamente en el código:
- Archivo: `lib/services/stable_diffusion_service.dart`
- Variable: `_apiKey`

## ⚠️ IMPORTANTE - Lee esto:

### ✅ Está bien si:
- Solo usas la app localmente
- No compartes el código
- No subes el proyecto a GitHub/GitLab públicos
- Es solo para uso personal

### ❌ NO hagas esto:
- ❌ Subir el código a un repositorio público (GitHub, GitLab, etc.)
- ❌ Compartir el código con la key incluida
- ❌ Publicar el código en foros o comunidades

### 🔒 Si necesitas compartir el código:

**Opción 1: Quitar la key antes de compartir**
```dart
static const String _apiKey = 'YOUR_HUGGING_FACE_API_KEY';
```

**Opción 2: Usar variables de entorno (recomendado para producción)**
```dart
static const String _apiKey = String.fromEnvironment('HF_API_KEY');
```
Y ejecutar con:
```bash
flutter run --dart-define=HF_API_KEY=tu_key_aqui
```

**Opción 3: Archivo de configuración (no versionado)**
Crear un archivo `config.dart` (agregado a .gitignore) con la key.

## 🛡️ Si tu key se expone:

1. Ve a: https://huggingface.co/settings/tokens
2. Elimina el token expuesto
3. Crea uno nuevo
4. Actualiza el código con el nuevo token

## 📝 Nota

El archivo `.gitignore` ya está configurado para que si cambias a un archivo de configuración separado, no se suba accidentalmente.

---

**Por ahora, está bien tenerla en el código si solo la usas tú localmente. Solo ten cuidado si compartes el proyecto.**

