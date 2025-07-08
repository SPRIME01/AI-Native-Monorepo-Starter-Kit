-- Row Level Security (RLS) policies for vectors table
ALTER TABLE vectors ENABLE ROW LEVEL SECURITY;

-- Example: Allow only authenticated users to select/insert/update/delete their own vectors
CREATE POLICY "Allow user access to own vectors" ON vectors
  USING (auth.uid() = metadata->>'user_id');

-- Example: Restrict all other access
REVOKE ALL ON TABLE vectors FROM PUBLIC;
