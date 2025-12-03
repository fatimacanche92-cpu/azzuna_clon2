# 🔐 Permisos Necesarios para el Token de Hugging Face

## Permisos Mínimos Requeridos

Para que la aplicación funcione correctamente con Stable Diffusion, necesitas estos permisos:

### ✅ Permisos OBLIGATORIOS

1. **Repositories (Repositorios)**
   - ☑️ "Read access to contents of all repos under your personal namespace"
   - ☑️ "Read access to contents of all public gated repos you can access"
   - **Razón**: Necesario para acceder al modelo de Stable Diffusion

2. **Inference (Inferencia)** ⭐ **MÁS IMPORTANTE**
   - ☑️ **"Make calls to Inference Providers"**
   - **Razón**: Este es el permiso crítico para generar imágenes con la API

3. **Collections (Colecciones)**
   - ☑️ "Read access to all collections under your personal namespace"
   - **Razón**: Acceso a colecciones públicas

4. **Billing (Facturación)**
   - ☑️ "Read access to your billing usage and know if a payment method is set"
   - **Razón**: Para verificar el estado de tu cuenta

### ❌ Permisos NO Necesarios

No necesitas marcar estos (la app funciona sin ellos):

- ❌ Write access (acceso de escritura)
- ❌ Webhooks
- ❌ Discussions & Posts
- ❌ Jobs
- ❌ Inference Endpoints (solo necesitas Inference Providers)
- ❌ Org permissions (solo si trabajas con organizaciones)

## 📋 Resumen Rápido

**Para crear el token:**
1. Tipo: **"Read"** (solo lectura)
2. Nombre: "tarjetas-flores" (o el que prefieras)
3. Permisos mínimos:
   - ✅ Read repos
   - ✅ **Make calls to Inference Providers** ← El más importante
   - ✅ Read collections
   - ✅ Read billing

## ⚠️ Nota Importante

Si solo marcas "Read" como tipo de token, algunos de estos permisos ya vienen incluidos por defecto. Pero asegúrate de que **"Make calls to Inference Providers"** esté marcado, ya que es esencial para generar las imágenes.

## 🔍 Verificación

Después de crear el token, puedes verificar que funciona:
- El token debe empezar con `hf_`
- Debe tener al menos 20 caracteres
- Debe tener el permiso de Inference Providers activado

