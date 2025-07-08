from pydantic import BaseModel
from typing import List
from datetime import datetime
import enum


class SenderType(str, enum.Enum):
    USER = "user"
    AI = "ai"

class ChatMessageBase(BaseModel):
    sender_type: SenderType
    content: str

class ChatMessageCreate(ChatMessageBase):
    chat_room_id: int

class ChatMessage(ChatMessageBase):
    id: int
    chat_room_id: int
    created_at: datetime

    class Config:
        orm_mode = True

class ChatMessageInRoom(ChatMessageBase):
    id: int
    created_at: datetime

    class Config:
        orm_mode = True

class ChatRoomBase(BaseModel):
    title: str

class ChatRoomCreate(ChatRoomBase):
    user_id: int

class ChatRoom(ChatRoomBase):
    id: int
    user_id: int
    created_at: datetime
    messages: List[ChatMessage] = []

    class Config:
        orm_mode = True

class MessageRequest(BaseModel):
    content: str
