from dataclasses import dataclass
from datetime import datetime
from typing import Optional, List, Callable
from .websocket_client import WebSocketClient
from .event_manager import EventManager
from PyQt6.QtCore import QObject, pyqtSignal
from cryptography.fernet import Fernet
import base64

@dataclass
class Message:
    id: str
    content: str
    from_user_id: int
    to_user_id: int
    read: bool
    created_at: datetime

class MessagingClient(QObject):
    message_received = pyqtSignal(Message)
    user_presence_changed = pyqtSignal(int, bool)  # user_id, is_online

    def __init__(self, event_manager: EventManager, user_id: int, encryption_key: str):
        super().__init__()
        self.event_manager = event_manager
        self.user_id = user_id
        self.cipher_suite = Fernet(base64.b64encode(encryption_key.encode()))
        self.ws_client = WebSocketClient(
            event_manager,
            f"ws://localhost:4000/socket/websocket"
        )
        
    async def connect(self):
        await self.ws_client.connect()
        await self.join_user_channel()

    async def join_user_channel(self):
        join_msg = {
            "topic": f"user:{self.user_id}",
            "event": "phx_join",
            "payload": {},
            "ref": "1"
        }
        await self.ws_client.ws.send(json.dumps(join_msg))

    async def send_message(self, recipient_id: int, content: str):
        encrypted_content = self.cipher_suite.encrypt(content.encode()).decode()
        message = {
            "topic": f"user:{self.user_id}",
            "event": "new_message",
            "payload": {
                "recipient_id": recipient_id,
                "content": encrypted_content,
                "encrypted": True
            },
            "ref": "1"
        }
        await self.ws_client.ws.send(json.dumps(message))

    async def handle_message(self, message):
        if message.get("event") == "new_message":
            payload = message["payload"]
            if payload["encrypted"]:
                msg = Message(
                    id=payload["id"],
                    content=self._decrypt_message(payload["content"]),
                    from_user_id=payload["from_user_id"],
                    to_user_id=payload["to_user_id"],
                    read=payload["read"],
                    created_at=datetime.fromisoformat(payload["created_at"])
                )
            else:
                msg = Message(
                    id=payload["id"],
                    content=payload["content"],
                    from_user_id=payload["from_user_id"],
                    to_user_id=payload["to_user_id"],
                    read=payload["read"],
                    created_at=datetime.fromisoformat(payload["created_at"])
                )
            self.message_received.emit(msg)

    def _decrypt_message(self, encrypted_content: str) -> str:
        return self.cipher_suite.decrypt(encrypted_content.encode()).decode()