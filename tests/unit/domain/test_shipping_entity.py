"""
Unit tests for shipping domain entity and business policies.
"""
import pytest

class Shipment:
    def __init__(self, shipment_id, destination, status):
        self.shipment_id = shipment_id
        self.destination = destination
        self.status = status
    def is_valid(self):
        return bool(self.shipment_id) and bool(self.destination)
    def can_ship(self):
        return self.status == "READY"

def test_shipment_valid():
    shipment = Shipment(shipment_id="SHIP-1", destination="Berlin", status="READY")
    assert shipment.is_valid()
    assert shipment.can_ship()

def test_shipment_invalid_destination():
    shipment = Shipment(shipment_id="SHIP-2", destination="", status="READY")
    assert not shipment.is_valid()

def test_shipment_cannot_ship_when_not_ready():
    shipment = Shipment(shipment_id="SHIP-3", destination="Paris", status="PENDING")
    assert not shipment.can_ship()
