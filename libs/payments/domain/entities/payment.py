from dataclasses import dataclass

@dataclass(frozen=True)
class Payment:
    amount: float
    currency: str
