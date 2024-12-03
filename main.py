import os

from fastapi import FastAPI

from src.database import SessionLocal, engine, Base

app = FastAPI()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.on_event("startup")
def startup():
    Base.metadata.create_all(bind=engine)

@app.on_event("shutdown")
def shutdown():
    pass

@app.get("/")
async def read_root():
    return "Hello, world!"

@app.get('/version')
async def version():
    return {
        "version": os.getenv('LAST_COMMIT_HASH', 'unknown')
    }
