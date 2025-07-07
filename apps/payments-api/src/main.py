"""
payments-api - Thin interface layer for payments domain
This is just an HTTP adapter that exposes payments domain services
"""
from fastapi import FastAPI
from .api.v1 import router as api_v1_router

app = FastAPI(
    title="Payments API",
    description="Hexagonal architecture interface for payments domain",
    version="1.0.0"
)

app.include_router(api_v1_router, prefix="/api/v1")

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "service": "payments",
        "architecture": "hexagonal"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
