
import os
import pytest
from dotenv import load_dotenv, find_dotenv
from libs.shared.data_access.supabase.client import get_supabase_client

load_dotenv(find_dotenv())

def test_supabase_connection():
    if not os.environ.get("SUPABASE_URL") or not os.environ.get("SUPABASE_KEY"):
        pytest.skip("Supabase credentials not found in .env file")
    client = get_supabase_client()
    response = client.table('vectors').select('id').limit(1).execute()
    assert response
