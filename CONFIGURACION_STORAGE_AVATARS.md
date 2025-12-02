# 📸 Configuración del Bucket "avatars" en Supabase Storage

## ❌ Problema Actual
El bucket `avatars` no existe en Supabase. La app intenta subir imágenes pero falla.

## ✅ Solución: Crear el Bucket y Configurar RLS

### **Paso 1: Ir a Supabase Console**

1. Abre [https://app.supabase.com](https://app.supabase.com)
2. Selecciona tu proyecto
3. Ve a **Storage** en el menú izquierdo

---

### **Paso 2: Crear el Bucket "avatars"**

1. Haz clic en **"New Bucket"**
2. Nombre: `avatars`
3. Privacidad: **Marcar "Public bucket"** (para que las URLs públicas funcionen)
4. Haz clic en **Create Bucket**

---

### **Paso 3: Configurar Políticas RLS del Bucket**

1. En el bucket `avatars`, haz clic en los tres puntos (⋯)
2. Selecciona **Policies**
3. Haz clic en **"New policy"** → Selecciona **For users using ANON KEY**

#### **Política 1: Permitir lectura pública (GET)**
- **Template**: `GET` - permitir acceso público a objetos
- **Usar plantilla** (simplemente aplica la que viene por defecto para GET público)
- **Guardar**

#### **Política 2: Permitir que usuarios autenticados suban (POST/PUT)**
- Haz clic nuevamente en **"New policy"**
- **Selecciona**: `INSERT` - con condiciones personalizadas
- **Reemplaza el SQL con**:

```sql
(bucket_id = 'avatars'::text) AND (auth.uid()::text = (storage.foldername(name))[1])
```

- **Guardar**

#### **Política 3: Permitir que usuarios actualicen sus propias imágenes (UPDATE)**
- Haz clic en **"New policy"**
- **Selecciona**: `UPDATE` - con condiciones personalizadas
- **Reemplaza el SQL con**:

```sql
(bucket_id = 'avatars'::text) AND (auth.uid()::text = (storage.foldername(name))[1])
```

- **Guardar**

---

### **Paso 4: Verificar que las Políticas se Ven Así**

En la sección Policies del bucket `avatars`, deberías ver:

```
✅ GET (Public) - [x] Enabled
✅ INSERT - Autenticados pueden subir a su carpeta
✅ UPDATE - Autenticados pueden actualizar su carpeta
```

---

## 📝 Política SQL Explicada

```sql
(bucket_id = 'avatars'::text) AND (auth.uid()::text = (storage.foldername(name))[1])
```

**Qué hace:**
- `bucket_id = 'avatars'` → Solo aplica al bucket `avatars`
- `auth.uid()::text` → El ID del usuario autenticado (UUID)
- `(storage.foldername(name))[1]` → Extrae la primera parte del path (la carpeta)
  - Ejemplo: si `name = "44ec7047-a831-496f-94d3-a14280ff88a0/profile_1234.jpg"`
  - Extrae: `"44ec7047-a831-496f-94d3-a14280ff88a0"` (el UUID del usuario)
- Los usuarios solo pueden subir a su propia carpeta

**Resultado:**
- ✅ Usuario A solo puede subir a `{su-uuid}/...`
- ✅ Usuario B solo puede subir a `{su-uuid}/...`
- ❌ No pueden editar archivos del otro

---

## 🔗 URL Pública del Avatar

Una vez subida, la URL será algo como:

```
https://mecyjjuuzzwjrujkcckd.supabase.co/storage/v1/object/public/avatars/44ec7047-a831-496f-94d3-a14280ff88a0/profile_1764698011720.jpg
```

**Estructura:**
- `https://{PROJECT_ID}.supabase.co/storage/v1/object/public/avatars/{user-id}/{file-name}`

---

## ✅ Verificación en la App

Después de configurar el bucket:

1. Abre la app
2. Ve a **Mi Perfil**
3. Toca el **icono de cámara** (en el avatar)
4. Selecciona una imagen de tu galería
5. Espera a que se suba (verás "Subiendo imagen...")
6. Si tiene éxito, verás: ✅ **"Imagen subida exitosamente"**
7. El avatar aparecerá en la UI
8. Haz clic en **Guardar** (botón de check)
9. Verás: ✅ **"Perfil guardado exitosamente"**

---

## 🐛 Si Aún Hay Errores

### **Error: "Storage bucket not found"**
→ El bucket no existe. Vuelve al Paso 2 y créalo.

### **Error: "Permission denied" (403)**
→ Las políticas RLS no están correctas. Verifica el Paso 3.

### **Error: "Connection reset by peer" (104)**
→ Problema de red/Supabase. Espera unos minutos e intenta nuevamente.

### **Error: "avatar_url is null" o no se guarda**
→ Verifica que después de subir la imagen, el código llama a `saveProfile()`.

---

## 📚 Para Más Información

- [Docs de Storage en Supabase](https://supabase.com/docs/guides/storage)
- [RLS Policies de Storage](https://supabase.com/docs/guides/storage/security/access-control)
