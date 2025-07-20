from .config import load_observability_config
from .otel_provider import OTelObservabilityProvider
from .local_provider import LocalObservabilityProvider
# from .gcloud_provider import GoogleCloudObservabilityProvider  # Example for future extension

def get_observability_provider(service_name: str = "ai-app"):
    config = load_observability_config()
    provider = (config.get("provider") or "local").lower()
    if provider == "otel" or provider == "opentelemetry":
        return OTelObservabilityProvider(service_name)
    # elif provider == "google-cloud":
    #     return GoogleCloudObservabilityProvider(service_name)
    else:
        return LocalObservabilityProvider(service_name)
