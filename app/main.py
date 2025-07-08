from fastapi import FastAPI

app = FastAPI(
    title="Intellius Chat Service",
    description="AI 상담 채팅 서비스 API",
    version="1.0.0",
)

# app.include_router(chat.router)

@app.get("/", tags=["Root"])
def read_root():
    return {"message": "Welcome to the Intellius Chat Service API!"} 