
from dataclasses import dataclass
from decimal import Decimal

@dataclass(frozen=True)
class Payment:
    amount: Decimal
    currency: str
