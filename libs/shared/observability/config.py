import yaml
from pathlib import Path

def load_observability_config(config_path: str = "observability.yaml") -> dict:
    if not Path(config_path).exists():
        return {}
    with open(config_path, "r") as f:
        return yaml.safe_load(f)
