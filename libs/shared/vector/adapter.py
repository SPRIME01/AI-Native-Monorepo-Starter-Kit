from abc import ABC, abstractmethod
from typing import List, Any

class VectorDBAdapter(ABC):
    @abstractmethod
    def upsert(self, ids: List[str], vectors: List[List[float]], metadata: List[dict]) -> None:
        pass

    @abstractmethod
    def query(self, vector: List[float], top_k: int = 5) -> List[Any]:
        pass

    @abstractmethod
    def delete(self, ids: List[str]) -> None:
        pass
