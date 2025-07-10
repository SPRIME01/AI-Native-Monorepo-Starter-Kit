
import os
import pytest
from libs.shared.data_access.supabase.client import get_supabase_client

def test_supabase_connection():
    if not os.environ.get("SUPABASE_URL") or not os.environ.get("SUPABASE_ANON_KEY"):
        pytest.skip("Supabase credentials not found in .env file")
    client = get_supabase_client()

    supabase_url = os.environ.get("SUPABASE_URL")

    if supabase_url and "localhost" in supabase_url:
        # If using local Supabase, just verify client creation
        # No insert/select operations as local Supabase might not be running
        print("Skipping insert/select operations for local Supabase connection test.")
        assert client is not None
    else:
        # For remote Supabase, perform insert and select operations
        test_id = "test_vector_123"
        test_embedding = [0.1] * 1536  # Example embedding
        test_metadata = {"source": "test"}

        try:
            # Insert a row
            insert_response = client.table('vectors').insert({"id": test_id, "embedding": test_embedding, "metadata": test_metadata}).execute()
            assert insert_response.data is not None
            assert len(insert_response.data) > 0

            # Select the inserted row
            select_response = client.table('vectors').select('*').eq('id', test_id).execute()
            assert select_response.data is not None
            assert len(select_response.data) == 1
            assert select_response.data[0]['id'] == test_id

        finally:
            # Clean up: delete the inserted row
            client.table('vectors').delete().eq('id', test_id).execute()
