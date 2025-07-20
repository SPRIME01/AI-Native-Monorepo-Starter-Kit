import psycopg2
from typing import List, Any
from .adapter import VectorDBAdapter

class PgVectorAdapter(VectorDBAdapter):
    def __init__(self, conn_str: str):
        self.conn_str = conn_str

    def upsert(self, ids: List[str], vectors: List[List[float]], metadata: List[dict]) -> None:
        # Example: Upsert vectors into a pgvector table
        with psycopg2.connect(self.conn_str) as conn:
            with conn.cursor() as cur:
                for i, vec in enumerate(vectors):
                    cur.execute("""
                        INSERT INTO vectors (id, embedding, metadata)
                        VALUES (%s, %s, %s)
                        ON CONFLICT (id) DO UPDATE SET embedding = EXCLUDED.embedding, metadata = EXCLUDED.metadata
                    """, (ids[i], vec, metadata[i]))
            conn.commit()

    def query(self, vector: List[float], top_k: int = 5) -> List[Any]:
        # Example: Query most similar vectors using pgvector
        with psycopg2.connect(self.conn_str) as conn:
            with conn.cursor() as cur:
                cur.execute("""
                    SELECT id, embedding, metadata
                    FROM vectors
                    ORDER BY embedding <-> %s
                    LIMIT %s
                """, (vector, top_k))
                return cur.fetchall()

    def delete(self, ids: List[str]) -> None:
        with psycopg2.connect(self.conn_str) as conn:
            with conn.cursor() as cur:
                cur.executemany("DELETE FROM vectors WHERE id = %s", [(i,) for i in ids])
            conn.commit()
