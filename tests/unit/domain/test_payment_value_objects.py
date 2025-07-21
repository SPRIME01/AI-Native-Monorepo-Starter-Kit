"""
Unit tests for payment value object validation.
"""
import pytest
from dataclasses import FrozenInstanceError

from libs.payments.domain.entities.payment import Payment


def test_payment_value_object_equality():
    """Test that payment value objects with same values are equal."""
    payment1 = Payment(amount=100, currency="USD")
    payment2 = Payment(amount=100, currency="USD")
    assert payment1 == payment2


def test_payment_value_object_immutability():
    """Test that payment value objects are immutable."""
    payment = Payment(amount=100, currency="USD")
    with pytest.raises(FrozenInstanceError):
        payment.amount = 200  # Should raise FrozenInstanceError


def test_payment_value_object_inequality():
    """Test that payment value objects with different values are not equal."""
    payment1 = Payment(amount=100, currency="USD")
    payment2 = Payment(amount=200, currency="USD")
    payment3 = Payment(amount=100, currency="EUR")

    assert payment1 != payment2
    assert payment1 != payment3
    assert payment2 != payment3
