from typing import List, Any
from .adapter import VectorDBAdapter
from .embedding_service import EmbeddingService

class SimilaritySearch:
    def __init__(self, vector_db: VectorDBAdapter, embedder: EmbeddingService):
        self.vector_db = vector_db
        self.embedder = embedder

    def search(self, query_text: str, top_k: int = 5) -> List[Any]:
        query_vec = self.embedder.embed([query_text])[0]
        return self.vector_db.query(query_vec, top_k=top_k)
