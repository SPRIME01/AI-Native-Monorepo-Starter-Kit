import unittest
from unittest.mock import MagicMock
from libs.shared.vector.embedding_service import EmbeddingService
from libs.shared.vector.pgvector_adapter import PgVectorAdapter
from libs.shared.vector.similarity_search import SimilaritySearch

class TestSimilaritySearch(unittest.TestCase):
    def setUp(self):
        self.embedder = EmbeddingService()
        # Mock the vector_db
        self.vector_db = MagicMock(spec=PgVectorAdapter)
        self.search = SimilaritySearch(self.vector_db, self.embedder)

    def test_search(self):
        # This is a placeholder test; in real usage, mock DB or use test DB
        self.vector_db.query.return_value = [("doc1", 0.9), ("doc2", 0.8), ("doc3", 0.7)]
        results = self.search.search("test query", top_k=3)
        self.assertIsInstance(results, list)
        self.assertEqual(len(results), 3)

if __name__ == "__main__":
    unittest.main()
