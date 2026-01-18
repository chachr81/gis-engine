from fastapi import FastAPI, HTTPException
import httpx

app = FastAPI(
    title="Portal GIS API",
    root_path="/api",
)

@app.get("/health")
def health():
    return {"status": "ok"}