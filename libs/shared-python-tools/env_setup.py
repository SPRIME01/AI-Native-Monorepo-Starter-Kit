import os
import sys
from pathlib import Path

REQUIRED_VARS = [
    'OPENAI_API_KEY', 'ANTHROPIC_API_KEY', 'COHERE_API_KEY',
    'PINECONE_API_KEY', 'CHROMADB_URL', 'WEAVIATE_URL',
    'MODEL_PROVIDER', 'MODEL_NAME', 'MODEL_ENV',
    'LANGSMITH_API_KEY', 'DEEPEVAL_API_KEY',
    'RAY_SERVE_URL', 'SAGEMAKER_ENDPOINT', 'SECRET_KEY'
]

def check_env():
    missing = []
    for var in REQUIRED_VARS:
        if not os.getenv(var):
            missing.append(var)
    if missing:
        print(f"\n❌ Missing required environment variables: {', '.join(missing)}")
        print("Copy .env.template to .env and fill in the values.")
        sys.exit(1)
    print("\n✅ All required AI/ML environment variables are set.")

if __name__ == "__main__":
    check_env()
