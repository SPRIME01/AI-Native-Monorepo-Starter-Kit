"""
Unit tests for observability logging utilities.
"""
import pytest
from unittest.mock import MagicMock

def test_logging_basic():
    """Test basic logging functionality with real logger."""
    import logging
    from io import StringIO

    # Create a string buffer to capture log output
    log_buffer = StringIO()
    handler = logging.StreamHandler(log_buffer)
    logger = logging.getLogger('test_logger')
    logger.addHandler(handler)
    logger.setLevel(logging.INFO)

    # Test actual logging
    test_message = 'test log'
    logger.info(test_message)

    # Verify the message was logged
    log_output = log_buffer.getvalue()
    assert test_message in log_output
