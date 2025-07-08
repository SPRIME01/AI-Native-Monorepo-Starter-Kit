import unittest
from .embedding_service import EmbeddingService
from .pgvector_adapter import PgVectorAdapter
from .similarity_search import SimilaritySearch

class TestSimilaritySearch(unittest.TestCase):
    def setUp(self):
        self.embedder = EmbeddingService()
        self.vector_db = PgVectorAdapter(conn_str="postgresql://user:password@localhost:5432/dbname")
        self.search = SimilaritySearch(self.vector_db, self.embedder)

    def test_search(self):
        # This is a placeholder test; in real usage, mock DB or use test DB
        results = self.search.search("test query", top_k=3)
        self.assertIsInstance(results, list)

if __name__ == "__main__":
    unittest.main()
