# 🔑 Guía: Obtener API Key de Hugging Face

## Pasos para obtener tu API Key gratuita

1. **Ve a Hugging Face**
   - Visita: https://huggingface.co/
   - Crea una cuenta (es gratis) o inicia sesión

2. **Obtén tu Token**
   - Ve a: https://huggingface.co/settings/tokens
   - Haz clic en "New token"
   - Dale un nombre (ej: "tarjetas-flores")
   - **Selecciona el tipo: "Read"** (suficiente para inferencia)
   
3. **Configura los Permisos Necesarios**
   
   En la sección **"User permissions"**, marca estos permisos:
   
   ✅ **Repositories:**
   - ☑️ "Read access to contents of all repos under your personal namespace"
   - ☑️ "Read access to contents of all public gated repos you can access"
   
   ✅ **Inference:**
   - ☑️ **"Make calls to Inference Providers"** ← **ESTE ES EL MÁS IMPORTANTE**
   
   ✅ **Collections:**
   - ☑️ "Read access to all collections under your personal namespace"
   
   ✅ **Billing:**
   - ☑️ "Read access to your billing usage and know if a payment method is set"
   
   **NO necesitas marcar:**
   - ❌ Write access (solo lectura es suficiente)
   - ❌ Webhooks
   - ❌ Discussions & Posts
   - ❌ Jobs
   
4. **Crea el Token**
   - Haz clic en "Create token"
   - **Copia el token inmediatamente** (empieza con `hf_`)
   - ⚠️ **IMPORTANTE**: Solo lo verás una vez, guárdalo bien

3. **Usa el Token en la App**
   - En la pantalla de personalización
   - Busca el campo "API Key de Hugging Face"
   - Pega tu token
   - ¡Listo! Ya puedes generar fondos

## ⚠️ Importante

- **Gratis**: Hugging Face ofrece tokens gratuitos
- **Límites**: Puede haber límites de uso en el plan gratuito
- **Seguridad**: No compartas tu token públicamente
- **Alternativa**: Si no quieres usar API, los diseños normales funcionan perfectamente

## 💡 Nota

Si no configuras la API key, la aplicación funcionará normalmente con los diseños predefinidos. Los fondos con IA son una característica opcional.

