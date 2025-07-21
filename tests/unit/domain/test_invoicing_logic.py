"""
Unit tests for invoicing domain logic and calculation accuracy.
"""
import pytest

class Invoice:
    def __init__(self, invoice_id, amount, tax):
        self.invoice_id = invoice_id
        self.amount = amount
        self.tax = tax
    def total(self):
        return self.amount + self.tax
    def is_valid(self):
        return self.amount >= 0 and self.tax >= 0 and bool(self.invoice_id)

def test_invoice_valid():
    invoice = Invoice(invoice_id="INV-1", amount=100, tax=20)
    assert invoice.is_valid()
    assert invoice.total() == 120

def test_invoice_negative_amount():
    invoice = Invoice(invoice_id="INV-2", amount=-50, tax=10)
    assert not invoice.is_valid()

def test_invoice_calculation_accuracy():
    invoice = Invoice(invoice_id="INV-3", amount=200, tax=30)
    assert invoice.total() == 230
