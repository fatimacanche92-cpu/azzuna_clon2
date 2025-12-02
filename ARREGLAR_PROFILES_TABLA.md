# 🔧 INSTRUCCIONES PARA ARREGLAR LA TABLA PROFILES

## El Problema
El error dice: **"Could not find the 'address' column of 'profiles' in the schema cache"**

Esto significa que la tabla `profiles` en Supabase no tiene las columnas que el código intenta guardar:
- ❌ `avatar_url`
- ❌ `address`
- ❌ `schedule`
- ❌ (y posiblemente otras)

## ✅ La Solución (3 pasos)

### **Paso 1: Abre Supabase SQL Editor**

1. Ve a [https://app.supabase.com](https://app.supabase.com)
2. Selecciona tu proyecto
3. En el menú izquierdo, haz clic en **SQL Editor**
4. Haz clic en **"New Query"**

### **Paso 2: Copia y Pega el SQL**

Copia TODO esto y pégalo en el editor SQL:

```sql
-- ========================================
-- FIX: Agregar columnas faltantes a profiles
-- ========================================

-- Primero, desactivar RLS temporalmente para hacer cambios
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;

-- Agregar columnas que faltan (si no existen)
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS phone TEXT,
ADD COLUMN IF NOT EXISTS address TEXT,
ADD COLUMN IF NOT EXISTS schedule TEXT,
ADD COLUMN IF NOT EXISTS avatar_url TEXT,
ADD COLUMN IF NOT EXISTS shop_name TEXT,
ADD COLUMN IF NOT EXISTS shop_description TEXT,
ADD COLUMN IF NOT EXISTS social_links JSONB;

-- Re-habilitar RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Verificar que las políticas existan
CREATE POLICY IF NOT EXISTS "profiles_select_own"
ON public.profiles FOR SELECT
USING (auth.uid() = id);

CREATE POLICY IF NOT EXISTS "profiles_update_own"
ON public.profiles FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

CREATE POLICY IF NOT EXISTS "profiles_insert_own"
ON public.profiles FOR INSERT
WITH CHECK (auth.uid() = id);
```

### **Paso 3: Ejecuta el SQL**

1. Haz clic en el botón **"▶ Run"** (esquina superior derecha)
2. Espera a que termine (deberías ver un mensaje de éxito)
3. ¡Listo! ✅

---

## ✅ Verificación

Después de ejecutar el SQL:

1. En el menú izquierdo, ve a **Table Editor**
2. Selecciona la tabla **profiles**
3. Deberías ver estas columnas:
   - ✅ `id`
   - ✅ `full_name`
   - ✅ `email`
   - ✅ `phone` ← (nueva)
   - ✅ `address` ← (nueva)
   - ✅ `schedule` ← (nueva)
   - ✅ `avatar_url` ← (nueva)
   - ✅ `shop_name` ← (nueva)
   - ✅ `shop_description` ← (nueva)
   - ✅ `social_links` ← (nueva)
   - ✅ `created_at`
   - ✅ `updated_at`

---

## 🚀 Después de esto

1. Vuelve a la app
2. Ve a **Mi Perfil**
3. **Edita** los campos (nombre, teléfono, dirección, horario)
4. **Sube una imagen** (toca el avatar)
5. Haz clic en **Guardar**
6. Deberías ver: ✅ **"Perfil guardado exitosamente"**

---

## 🐛 Si Sigue Dando Error

Si aún ves el error, significa que:
1. El SQL no ejecutó correctamente
2. O hay un problema de cache en Supabase

**Solución alternativa:**
1. Ve a **Table Editor** en Supabase
2. Haz clic en la tabla `profiles`
3. Haz clic en **"Create new column"**
4. Agrega manualmente cada columna que falta:
   - `phone` (TEXT)
   - `address` (TEXT)
   - `schedule` (TEXT)
   - `avatar_url` (TEXT)
   - `shop_name` (TEXT)
   - `shop_description` (TEXT)
   - `social_links` (JSONB)

---

## 📸 Bucket "avatars"

**TAMBIÉN necesitas crear el bucket de storage** si no lo has hecho.

Ver: `CONFIGURACION_STORAGE_AVATARS.md` en la raíz del proyecto.
