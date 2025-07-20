// AI_PRESETS: Centralized AI/ML dependency presets for auto-discovery and scaffolding
// Used by generators and Makefile automation

const AI_PRESETS = {
  // ──────────────────────────────── BUILD ────────────────────────────────
  llm_provider: ["openai", "anthropic", "cohere"], // model APIs
  ml_framework: ["torch", "jax", "tensorflow"], // train / fine-tune
  tokenizer: ["tiktoken", "sentencepiece"], // encode / decode
  vector_store: ["chromadb", "pinecone-client", "weaviate-client"],

  // ─────────────────────────────── DEVELOP ───────────────────────────────
  code_assistant: ["github-copilot", "cody-ai", "tabnine"], // IDE completions
  orchestration: ["langchain", "llama-index", "semantic-kernel"], // pipelines / agents
  rag_toolkit: ["haystack", "crew-ai", "autogen"], // retrieval-aug. generation

  // ─────────────────────────────── TEST  ────────────────────────────────
  evaluation: ["deepeval", "langsmith", "giskard"], // offline & online eval
  testing: ["pytest", "codium", "great-expectations"], // unit, integration, data tests

  // ─────────────────────────────── SHIP  ────────────────────────────────
  deployment: ["ray-serve", "modal", "sagemaker"], // serve & scale models
  monitoring: ["arize-phoenix", "whylogs", "evidently-ai"], // drift / quality dashboards
};

module.exports = { AI_PRESETS };
