# main.py
from fastapi import FastAPI
from prometheus_client import Counter, generate_latest
from starlette.responses import Response

app = FastAPI()
hits = Counter("hits", "Number of hits to the root")

@app.get("/")
def read_root():
    hits.inc()
    return {"message": "Hello World"}

@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type="text/plain")
