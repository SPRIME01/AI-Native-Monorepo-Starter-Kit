
import os
from supabase import create_client, Client
from dotenv import load_dotenv

load_dotenv()

def get_supabase_client() -> Client:
    url: str = os.environ.get("SUPABASE_URL")
    key: str = os.environ.get("SUPABASE_ANON_KEY")
    if not url:
        raise ValueError("SUPABASE_URL is not set in .env file")
    if not key:
        raise ValueError("SUPABASE_ANON_KEY is not set in .env file")
    try:
        client = create_client(url, key)
        # Attempt a simple query to verify connection only if not a local Supabase instance
        if "localhost" not in url:
            client.from_('vectors').select('id').limit(0).execute()
        return client
    except Exception as e:
        print(f"Error connecting to Supabase: {e}")
        raise ConnectionError(f"Failed to connect to Supabase. Please check your SUPABASE_URL and SUPABASE_ANON_KEY in the .env file, and ensure Supabase services are running. Original error: {e}") from e
