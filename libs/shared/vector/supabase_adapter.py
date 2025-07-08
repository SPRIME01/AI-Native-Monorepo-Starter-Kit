from supabase import create_client, Client
from typing import List, Any, Dict
from .adapter import VectorDBAdapter
import os

class SupabaseVectorAdapter(VectorDBAdapter):
    def __init__(self, url: str = None, key: str = None):
        self.url = url or os.getenv("SUPABASE_URL")
        self.key = key or os.getenv("SUPABASE_SERVICE_ROLE_KEY")
        self.client: Client = create_client(self.url, self.key)

    def upsert(self, ids: List[str], vectors: List[List[float]], metadata: List[dict]) -> None:
        records = [
            {"id": ids[i], "embedding": vectors[i], "metadata": metadata[i]} for i in range(len(ids))
        ]
        self.client.table("vectors").upsert(records).execute()

    def query(self, vector: List[float], top_k: int = 5) -> List[Any]:
        # Supabase REST API does not support vector search natively; use RPC or SQL function
        # This is a placeholder for a custom RPC function
        response = self.client.rpc("vector_search", {"query_embedding": vector, "top_k": top_k}).execute()
        return response.data

    def delete(self, ids: List[str]) -> None:
        for id_ in ids:
            self.client.table("vectors").delete().eq("id", id_).execute()
