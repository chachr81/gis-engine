from fastapi import FastAPI
app = FastAPI()

@app.get("/")
def read_root():
    return {"mensaje": "¡FastAPI espacial funcionando!", "status": "ok"}
