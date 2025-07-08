import random
import asyncio
from typing import List

from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from sqlalchemy.orm import Session

from .. import crud, schemas
from ..database import get_db, SessionLocal

router = APIRouter(
    prefix="/chat",
    tags=["chat"],
)

# AI의 더미 응답 목록
DUMMY_AI_RESPONSES = [
    "정말 흥미로운 이야기네요! 조금 더 자세히 말씀해주시겠어요?",
    "그 점에 대해서는 미처 생각해보지 못했네요. 좋은 관점이에요.",
    "그렇군요. 충분히 공감되는 이야기입니다.",
    "마음이 많이 힘드셨겠어요. 이야기해주셔서 감사합니다.",
    "제가 더 도움을 드릴 수 있는 부분이 있을까요?",
    "잠시 생각할 시간을 주시겠어요? 이 주제는 저에게도 중요하게 느껴져요.",
    "오늘 대화를 통해 저도 많은 것을 배웁니다.",
]

async def generate_and_save_ai_response(room_id: int):
    """
    백그라운드에서 AI 응답을 생성하고 저장하는 함수.
    이 함수는 독립적인 DB 세션을 생성하여 사용합니다.
    """
    db = SessionLocal()
    try:
        # 2. AI 응답 시간 시뮬레이션
        delay_time = random.uniform(1, 3)
        await asyncio.sleep(delay_time)

        # 3. AI 응답 생성 및 저장
        ai_response_content = random.choice(DUMMY_AI_RESPONSES)
        ai_message_to_create = schemas.ChatMessageCreate(
            chat_room_id=room_id,
            sender_type=schemas.SenderType.AI,
            content=ai_response_content
        )
        crud.create_chat_message(db=db, message=ai_message_to_create)
    finally:
        db.close()

# user_id에 대한 의존성은 추후 인증 기능 구현 시 JWT 토큰으로 대체될 예정
@router.post("/users/{user_id}/rooms", response_model=schemas.ChatRoom, status_code=status.HTTP_201_CREATED)
# 특정 사용자를 위한 새 채팅방을 생성합니다.
def create_room_for_user(user_id: int, chat_room: schemas.ChatRoomBase, db: Session = Depends(get_db)):
    db_user = crud.get_user(db, user_id=user_id)
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")
    
    room_to_create = schemas.ChatRoomCreate(user_id=user_id, title=chat_room.title)
    return crud.create_chat_room(db=db, chat_room=room_to_create)

@router.get("/users/{user_id}/rooms", response_model=List[schemas.ChatRoom])
# 특정 사용자의 채팅방 목록을 페이지네이션으로 조회합니다.
def read_user_chat_rooms(user_id: int, skip: int = 0, limit: int = 10, db: Session = Depends(get_db)):
    db_user = crud.get_user(db, user_id=user_id)
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")
    
    rooms = crud.get_chat_rooms_by_user(db, user_id=user_id, skip=skip, limit=limit)
    return rooms

@router.get("/rooms/{room_id}/messages", response_model=List[schemas.ChatMessageInRoom])
# 특정 채팅방의 메시지 목록을 페이지네이션으로 조회합니다.
def read_chat_messages(room_id: int, skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    db_room = crud.get_chat_room(db, chat_room_id=room_id)
    if not db_room:
        raise HTTPException(status_code=404, detail="Chat room not found")
        
    messages = crud.get_messages_by_chat_room(db, chat_room_id=room_id, skip=skip, limit=limit)
    return messages

@router.post("/rooms/{room_id}/messages", response_model=schemas.ChatMessage, status_code=status.HTTP_202_ACCEPTED)
# 특정 채팅방에 새 메시지를 보내고, AI 응답 생성은 백그라운드 작업으로 넘깁니다.
def create_new_chat_message(
    room_id: int, 
    message: schemas.MessageRequest, 
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db)
):
    db_room = crud.get_chat_room(db, chat_room_id=room_id)
    if not db_room:
        raise HTTPException(status_code=404, detail="Chat room not found")

    # 1. 사용자 메시지를 DB에 즉시 저장합니다.
    user_message_to_create = schemas.ChatMessageCreate(
        chat_room_id=room_id,
        sender_type=schemas.SenderType.USER,
        content=message.content
    )
    db_user_message = crud.create_chat_message(db=db, message=user_message_to_create)

    # 2. AI 응답 생성 및 저장을 백그라운드 작업으로 추가합니다.
    background_tasks.add_task(generate_and_save_ai_response, room_id=room_id)

    # 3. AI 응답을 기다리지 않고, 저장된 사용자 메시지를 즉시 반환합니다.
    return db_user_message

@router.delete("/rooms/{room_id}", status_code=status.HTTP_204_NO_CONTENT)
# 특정 채팅방과 그 안의 모든 메시지를 논리적으로 삭제합니다.
def remove_chat_room(room_id: int, db: Session = Depends(get_db)):
    db_room = crud.delete_chat_room(db, chat_room_id=room_id)
    if db_room is None:
        raise HTTPException(status_code=404, detail="Chat room not found")
    return None

@router.delete("/messages/{message_id}", status_code=status.HTTP_204_NO_CONTENT)
# 특정 메시지를 논리적으로 삭제합니다.
def remove_chat_message(message_id: int, db: Session = Depends(get_db)):
    db_message = crud.delete_chat_message(db, message_id=message_id)
    if db_message is None:
        raise HTTPException(status_code=404, detail="Message not found")
    return None 