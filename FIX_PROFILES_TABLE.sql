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

-- Actualizar updated_at trigger para la tabla profiles
DROP TRIGGER IF EXISTS on_profiles_updated ON public.profiles;

-- Crear o reemplazar la función handle_updated_at
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Crear el trigger para actualizar updated_at
CREATE TRIGGER on_profiles_updated
BEFORE UPDATE ON public.profiles
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Re-habilitar RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Eliminar políticas viejas si existen
DROP POLICY IF EXISTS "profiles_select_own" ON public.profiles;
DROP POLICY IF EXISTS "profiles_update_own" ON public.profiles;
DROP POLICY IF EXISTS "profiles_insert_own" ON public.profiles;

-- Crear nuevas políticas
CREATE POLICY "profiles_select_own"
ON public.profiles FOR SELECT
USING (auth.uid() = id);

CREATE POLICY "profiles_update_own"
ON public.profiles FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

CREATE POLICY "profiles_insert_own"
ON public.profiles FOR INSERT
WITH CHECK (auth.uid() = id);
