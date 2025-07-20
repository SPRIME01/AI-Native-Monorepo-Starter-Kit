from .provider import ObservabilityProvider
import logging

class LocalObservabilityProvider(ObservabilityProvider):
    def __init__(self, service_name: str = "ai-app"):
        self.logger = logging.getLogger(service_name)
        logging.basicConfig(level=logging.INFO)

    def trace_llm_call(self, model: str, prompt: str, response: str, **kwargs) -> None:
        self.logger.info(f"[TRACE] LLM call: model={model}, prompt={prompt}, response={response}")

    def record_token_usage(self, tokens: int, cost: float, **kwargs) -> None:
        self.logger.info(f"[METRIC] Token usage: tokens={tokens}, cost={cost}")

    def log_model_performance(self, latency: float, error_rate: float, **kwargs) -> None:
        self.logger.info(f"[METRIC] Model performance: latency={latency}, error_rate={error_rate}")

    def log_event(self, event: str, data=None, **kwargs) -> None:
        self.logger.info(f"[EVENT] {event}: {data}")
