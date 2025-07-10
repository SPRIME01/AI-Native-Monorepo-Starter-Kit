import os
from dotenv import load_dotenv, find_dotenv
from libs.shared.data_access.supabase.client import get_supabase_client

load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), '.env'))

print(f"SUPABASE_URL: {os.environ.get("SUPABASE_URL")}")
print(f"SUPABASE_KEY: {os.environ.get("SUPABASE_KEY")}")

if not os.environ.get("SUPABASE_URL") or not os.environ.get("SUPABASE_KEY"):
    print("Supabase credentials not found in .env file. Skipping test.")
else:
    try:
        client = get_supabase_client()
        response = client.table('vectors').select('id').limit(1).execute()
        print("Test passed!")
    except Exception as e:
        print(f"Test failed: {e}")
