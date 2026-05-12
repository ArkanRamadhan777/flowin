-- ============================================================
-- Flowin App - Supabase Database Setup
-- Run this in: Supabase Dashboard → SQL Editor
-- ============================================================

-- 1. Create transactions table
CREATE TABLE IF NOT EXISTS transactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title text NOT NULL,
  amount numeric NOT NULL CHECK (amount > 0),
  type text NOT NULL CHECK (type IN ('income', 'expense')),
  category text NOT NULL DEFAULT 'Lainnya',
  date timestamp NOT NULL,
  created_at timestamp DEFAULT now() NOT NULL
);

-- 2. Create index for faster queries
CREATE INDEX IF NOT EXISTS transactions_user_id_idx ON transactions (user_id);
CREATE INDEX IF NOT EXISTS transactions_date_idx ON transactions (date DESC);
CREATE INDEX IF NOT EXISTS transactions_type_idx ON transactions (type);

-- 3. Enable Row Level Security (RLS)
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

-- 4. RLS Policy: Users can only SELECT their own transactions
CREATE POLICY "Users can view own transactions"
  ON transactions
  FOR SELECT
  USING (auth.uid() = user_id);

-- 5. RLS Policy: Users can only INSERT their own transactions
CREATE POLICY "Users can insert own transactions"
  ON transactions
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 6. RLS Policy: Users can only UPDATE their own transactions
CREATE POLICY "Users can update own transactions"
  ON transactions
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- 7. RLS Policy: Users can only DELETE their own transactions
CREATE POLICY "Users can delete own transactions"
  ON transactions
  FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================
-- Optional: Sample data (for testing only)
-- First authenticate and replace 'your-user-uuid-here' with actual UUID
-- ============================================================

-- INSERT INTO transactions (user_id, title, amount, type, category, date)
-- VALUES
--   ('your-user-uuid-here', 'Gaji Februari', 5000000, 'income', 'Gaji', NOW()),
--   ('your-user-uuid-here', 'Makan Siang', 35000, 'expense', 'Makanan & Minuman', NOW()),
--   ('your-user-uuid-here', 'Transportasi', 50000, 'expense', 'Transportasi', NOW());
