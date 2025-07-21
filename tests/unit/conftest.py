"""
Global pytest configuration and shared plugins for unit tests.
"""
import pytest

# Register global plugins, hooks, and shared fixtures here

# Example: Enable pytest-randomly for test order randomization if installed
try:
    import pytest_randomly  # noqa: F401
except ImportError:
    pass

# Example: Add custom marker for slow tests
def pytest_configure(config):
    config.addinivalue_line("markers", "slow: mark test as slow-running")
