"""
Supabase client abstraction for shared data-access.
"""
import os
from supabase import create_client, Client

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

if not SUPABASE_URL or not SUPABASE_KEY:
    raise RuntimeError("Supabase credentials not set in environment variables.")

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
