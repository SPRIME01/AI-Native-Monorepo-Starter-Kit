from functools import wraps
from .factory import get_observability_provider
import time

def observe_llm_call(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        provider = get_observability_provider()
        start = time.time()
        try:
            result = func(*args, **kwargs)
            latency = (time.time() - start) * 1000
            provider.trace_llm_call(model=kwargs.get('model', 'unknown'), prompt=kwargs.get('prompt', ''), response=str(result))
            provider.log_model_performance(latency=latency, error_rate=0.0)
            return result
        except Exception as e:
            latency = (time.time() - start) * 1000
            provider.log_model_performance(latency=latency, error_rate=1.0)
            provider.log_event('llm_call_error', data=str(e))
            raise
    return wrapper
