from sqlalchemy.orm import Session
from . import models, schemas

# ID로 특정 사용자 조회
def get_user(db: Session, user_id: int):
    return db.query(models.User).filter(models.User.id == user_id, models.User.is_deleted == False).first()

# ID로 특정 채팅방 조회
def get_chat_room(db: Session, chat_room_id: int):
    return db.query(models.ChatRoom).filter(models.ChatRoom.id == chat_room_id, models.ChatRoom.is_deleted == False).first()

# 특정 사용자의 채팅방 목록 조회 (페이지네이션)
def get_chat_rooms_by_user(db: Session, user_id: int, skip: int = 0, limit: int = 100):
    return db.query(models.ChatRoom).filter(models.ChatRoom.user_id == user_id, models.ChatRoom.is_deleted == False).offset(skip).limit(limit).all()

# 새로운 채팅방 생성
def create_chat_room(db: Session, chat_room: schemas.ChatRoomCreate):
    db_chat_room = models.ChatRoom(
        user_id=chat_room.user_id,
        title=chat_room.title
    )
    db.add(db_chat_room)
    db.commit()
    db.refresh(db_chat_room)
    return db_chat_room

# 특정 채팅방의 메시지 목록 조회 (페이지네이션)
def get_messages_by_chat_room(db: Session, chat_room_id: int, skip: int = 0, limit: int = 100):
    return db.query(models.ChatMessage).filter(models.ChatMessage.chat_room_id == chat_room_id, models.ChatMessage.is_deleted == False).order_by(models.ChatMessage.created_at.asc()).offset(skip).limit(limit).all()

# 새로운 채팅 메시지 생성
def create_chat_message(db: Session, message: schemas.ChatMessageCreate):
    db_message = models.ChatMessage(
        chat_room_id=message.chat_room_id,
        sender_type=message.sender_type,
        content=message.content
    )
    db.add(db_message)
    db.commit()
    db.refresh(db_message)
    return db_message

# ID로 특정 메시지 조회
def get_chat_message(db: Session, message_id: int):
    return db.query(models.ChatMessage).filter(models.ChatMessage.id == message_id, models.ChatMessage.is_deleted == False).first()

# 특정 메시지 논리적 삭제 (연관된 AI 응답 포함)
def delete_chat_message(db: Session, message_id: int):
    # 1. 삭제할 메시지를 찾습니다.
    message_to_delete = get_chat_message(db, message_id)
    if not message_to_delete:
        return None

    # 2. 삭제할 메시지의 is_deleted 플래그를 True로 설정합니다.
    message_to_delete.is_deleted = True

    # 3. 만약 사용자가 보낸 메시지라면, 바로 다음에 온 AI 응답도 함께 삭제합니다.
    if message_to_delete.sender_type == schemas.SenderType.USER:
        # 같은 채팅방에서, 해당 메시지 바로 다음에 생성된, 삭제되지 않은 AI 메시지를 찾습니다.
        related_ai_response = db.query(models.ChatMessage).filter(
            models.ChatMessage.chat_room_id == message_to_delete.chat_room_id,
            models.ChatMessage.created_at > message_to_delete.created_at,
            models.ChatMessage.sender_type == schemas.SenderType.AI,
            models.ChatMessage.is_deleted == False
        ).order_by(models.ChatMessage.created_at.asc()).first()

        if related_ai_response:
            related_ai_response.is_deleted = True

    db.commit()
    return message_to_delete

# 특정 채팅방 및 하위 메시지 모두 논리적 삭제
def delete_chat_room(db: Session, chat_room_id: int):
    db_room = get_chat_room(db, chat_room_id)
    if not db_room:
        return None
    
    # 1. 채팅방의 is_deleted 플래그를 True로 설정
    db_room.is_deleted = True
    
    # 2. 해당 채팅방의 모든 메시지들의 is_deleted 플래그를 True로 설정
    db.query(models.ChatMessage).filter(models.ChatMessage.chat_room_id == chat_room_id).update({"is_deleted": True})
    
    db.commit()
    return db_room
