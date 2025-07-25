"""
Unit tests for Supabase client and database utilities.
"""
import pytest
from unittest.mock import patch, MagicMock

from libs.shared.data_access.supabase.client import get_supabase_client

def test_connection_with_valid_credentials():
    mock_client = MagicMock()
    with patch('libs.shared.data_access.supabase.client.create_client', return_value=mock_client):
        client = get_supabase_client()
        assert client is not None
