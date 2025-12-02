-- ===================================================
-- COMPLETE DATABASE MIGRATION: profiles + orders
-- ===================================================

-- 1. ADD MISSING COLUMNS TO PROFILES TABLE
ALTER TABLE IF EXISTS public.profiles ADD COLUMN IF NOT EXISTS phone TEXT;
ALTER TABLE IF EXISTS public.profiles ADD COLUMN IF NOT EXISTS address TEXT;
ALTER TABLE IF EXISTS public.profiles ADD COLUMN IF NOT EXISTS schedule TEXT;
ALTER TABLE IF EXISTS public.profiles ADD COLUMN IF NOT EXISTS avatar_url TEXT;
ALTER TABLE IF EXISTS public.profiles ADD COLUMN IF NOT EXISTS shop_name TEXT;
ALTER TABLE IF EXISTS public.profiles ADD COLUMN IF NOT EXISTS shop_description TEXT;
ALTER TABLE IF EXISTS public.profiles ADD COLUMN IF NOT EXISTS social_links JSONB;

-- Ensure updated_at trigger exists on profiles
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_profiles_updated_at ON public.profiles;
DROP TRIGGER IF EXISTS on_profiles_updated ON public.profiles;

CREATE TRIGGER trg_profiles_updated_at
BEFORE UPDATE ON public.profiles
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ===================================================
-- 2. CREATE ORDERS TABLE (if missing)
-- ===================================================

CREATE TABLE IF NOT EXISTS public.orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  client_name TEXT,
  arrangement_type TEXT,
  arrangement_size TEXT,
  arrangement_color TEXT,
  arrangement_flower_type TEXT,
  price NUMERIC(10, 2),
  delivery_type TEXT,
  delivery_address TEXT,
  payment_status TEXT DEFAULT 'pendiente',
  scheduled_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Add updated_at trigger to orders
DROP TRIGGER IF EXISTS trg_orders_updated_at ON public.orders;

CREATE TRIGGER trg_orders_updated_at
BEFORE UPDATE ON public.orders
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ===================================================
-- 3. RLS POLICIES FOR PROFILES
-- ===================================================

ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "profiles_select_own" ON public.profiles;
DROP POLICY IF EXISTS "profiles_update_own" ON public.profiles;
DROP POLICY IF EXISTS "profiles_insert_own" ON public.profiles;

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

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

-- ===================================================
-- 4. RLS POLICIES FOR ORDERS
-- ===================================================

ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "orders_select_own" ON public.orders;
DROP POLICY IF EXISTS "orders_insert_own" ON public.orders;
DROP POLICY IF EXISTS "orders_update_own" ON public.orders;
DROP POLICY IF EXISTS "orders_delete_own" ON public.orders;

CREATE POLICY "orders_select_own"
ON public.orders FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "orders_insert_own"
ON public.orders FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "orders_update_own"
ON public.orders FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "orders_delete_own"
ON public.orders FOR DELETE
USING (auth.uid() = user_id);

-- ===================================================
-- END MIGRATION - Run this SQL in Supabase console
-- ===================================================
