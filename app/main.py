from fastapi import FastAPI
from .database import engine, Base
from .routers import chat

Base.metadata.create_all(bind=engine)

app = FastAPI()

app.include_router(chat.router)

@app.get("/")
def read_root():
    return {"message": "Welcome to the Chat Service API"} 