from abc import ABC, abstractmethod
from typing import Any

class ObservabilityProvider(ABC):
    @abstractmethod
    def trace_llm_call(self, model: str, prompt: str, response: str, **kwargs) -> None:
        pass

    @abstractmethod
    def record_token_usage(self, tokens: int, cost: float, **kwargs) -> None:
        pass

    @abstractmethod
    def log_model_performance(self, latency: float, error_rate: float, **kwargs) -> None:
        pass

    @abstractmethod
    def log_event(self, event: str, data: Any = None, **kwargs) -> None:
        pass
