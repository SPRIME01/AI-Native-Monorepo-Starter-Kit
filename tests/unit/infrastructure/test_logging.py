"""
Unit tests for observability logging utilities.
"""
import pytest
from unittest.mock import MagicMock

def test_logging_basic():
    logger = MagicMock()
    logger.info('test log')
    logger.info.assert_called_with('test log')
