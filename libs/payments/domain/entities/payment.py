from dataclasses import dataclass

@dataclass(frozen=True)
class Payment:
from decimal import Decimal
from dataclasses import dataclass

@dataclass(frozen=True)
class Payment:
    amount: Decimal
    currency: str
    currency: str
