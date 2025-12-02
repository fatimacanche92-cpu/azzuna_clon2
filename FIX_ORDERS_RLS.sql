-- Fix RLS policy for orders table to allow users to insert their own orders

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow users to insert their own orders" ON public.orders;
DROP POLICY IF EXISTS "Allow users to read their own orders" ON public.orders;
DROP POLICY IF EXISTS "Allow users to update their own orders" ON public.orders;
DROP POLICY IF EXISTS "Allow users to delete their own orders" ON public.orders;

-- Ensure RLS is enabled
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

-- Policy: Users can INSERT their own orders
CREATE POLICY "Allow users to insert their own orders" 
ON public.orders 
FOR INSERT 
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can SELECT their own orders
CREATE POLICY "Allow users to read their own orders" 
ON public.orders 
FOR SELECT 
USING (auth.uid() = user_id);

-- Policy: Users can UPDATE their own orders
CREATE POLICY "Allow users to update their own orders" 
ON public.orders 
FOR UPDATE 
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can DELETE their own orders
CREATE POLICY "Allow users to delete their own orders" 
ON public.orders 
FOR DELETE 
USING (auth.uid() = user_id);
