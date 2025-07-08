-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Create vectors table
CREATE TABLE IF NOT EXISTS vectors (
    id TEXT PRIMARY KEY,
    embedding vector(1536) NOT NULL,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index for fast similarity search
CREATE INDEX IF NOT EXISTS idx_vectors_embedding ON vectors USING ivfflat (embedding vector_cosine_ops);
