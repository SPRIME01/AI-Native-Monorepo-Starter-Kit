from .provider import ObservabilityProvider
from opentelemetry import trace, metrics
from opentelemetry.trace import get_tracer
from opentelemetry.metrics import get_meter
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor, ConsoleSpanExporter
from opentelemetry.sdk.metrics.export import ConsoleMetricExporter, PeriodicExportingMetricReader
import logging

class OTelObservabilityProvider(ObservabilityProvider):
    def __init__(self, service_name: str = "ai-app"):
        resource = Resource.create({"service.name": service_name})
        trace.set_tracer_provider(TracerProvider(resource=resource))
        self.tracer = get_tracer(service_name)
        metrics.set_meter_provider(MeterProvider(resource=resource))
        self.meter = get_meter(service_name)
        # Console exporters for demo; replace with Jaeger/Prometheus exporters as needed
        span_processor = BatchSpanProcessor(ConsoleSpanExporter())
        trace.get_tracer_provider().add_span_processor(span_processor)
        metric_reader = PeriodicExportingMetricReader(ConsoleMetricExporter())
        metrics.get_meter_provider().register_metric_reader(metric_reader)
        self.logger = logging.getLogger(service_name)

    def trace_llm_call(self, model: str, prompt: str, response: str, **kwargs) -> None:
        with self.tracer.start_as_current_span("llm_call", attributes={"model": model}):
            self.logger.info(f"LLM call: model={model}, prompt={prompt}, response={response}")

    def record_token_usage(self, tokens: int, cost: float, **kwargs) -> None:
        counter = self.meter.create_counter("llm_token_usage", unit="tokens")
        counter.add(tokens, {"cost": cost})
        self.logger.info(f"Token usage: tokens={tokens}, cost={cost}")

    def log_model_performance(self, latency: float, error_rate: float, **kwargs) -> None:
        histogram = self.meter.create_histogram("llm_latency", unit="ms")
        histogram.record(latency)
        self.logger.info(f"Model performance: latency={latency}, error_rate={error_rate}")

    def log_event(self, event: str, data=None, **kwargs) -> None:
        self.logger.info(f"Event: {event}, data={data}")
