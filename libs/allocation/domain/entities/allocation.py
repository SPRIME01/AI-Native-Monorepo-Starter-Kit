from dataclasses import dataclass
from uuid import UUID

@dataclass
class Allocation:
    id: UUID
    order_id: str
    product_id: str
    quantity: int
    status: str

    def is_valid(self) -> bool:
        return self.quantity > 0
