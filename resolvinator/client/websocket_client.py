import json
import websockets
import asyncio
from typing import Optional
from .event_manager import EventManager, SystemEvent, EventPriority
import logging
import time

class WebSocketClient:
    def __init__(self, event_manager: EventManager, url: str = "wss://localhost:4000/socket/websocket"):
        super().__init__()
        # Enforce WSS
        if not url.startswith(('wss://', 'ws://')):
            url = f"wss://{url}"
        elif url.startswith('ws://') and not url.startswith('ws://localhost'):
            url = f"wss://{url[5:]}"
        self.url = url
        self.event_manager = event_manager
        self.ws: Optional[websockets.WebSocketClientProtocol] = None
        self.running = False
        
        # Add message validation
        self.last_message_time = 0
        self.message_count = 0
        self.rate_limit_window = 60  # 60 seconds
        self.rate_limit_max = 100    # max 100 messages per minute

    async def connect(self):
        try:
            # Add security parameters
            params = {
                "vsn": "2.0.0",
                "client_version": "1.0.0"
            }
            param_string = "&".join(f"{k}={v}" for k, v in params.items())
            url = f"{self.url}?{param_string}"
            
            self.ws = await websockets.connect(
                url,
                extra_headers={
                    "Content-Type": "application/json",
                    "X-Client-Version": "1.0.0"
                }
            )
            # Join the events channel
            join_msg = {
                "topic": "events:global",
                "event": "phx_join",
                "payload": {},
                "ref": "1"
            }
            await self.ws.send(json.dumps(join_msg))
            self.running = True
            await self.listen()
        except Exception as e:
            logging.error(f"WebSocket connection error: {e}")
            self.running = False

    async def listen(self):
        while self.running and self.ws:
            try:
                message = await self.ws.recv()
                await self.handle_message(json.loads(message))
            except websockets.ConnectionClosed:
                logging.warning("WebSocket connection closed")
                self.running = False
                break
            except Exception as e:
                logging.error(f"Error handling message: {e}")

    def _validate_message(self, data: dict) -> bool:
        """Validate incoming messages for rate limiting and structure"""
        current_time = time.time()
        
        # Rate limiting
        if current_time - self.last_message_time > self.rate_limit_window:
            self.message_count = 0
            self.last_message_time = current_time
        
        self.message_count += 1
        if self.message_count > self.rate_limit_max:
            logging.warning("Rate limit exceeded")
            return False

        # Message structure validation
        required_fields = ["topic", "event", "payload"]
        if not all(field in data for field in required_fields):
            logging.warning("Invalid message structure")
            return False

        # Payload size validation (prevent memory attacks)
        payload_size = len(json.dumps(data.get("payload", {})))
        if payload_size > 1024 * 1024:  # 1MB limit
            logging.warning("Message payload too large")
            return False

        return True

    async def handle_message(self, message):
        try:
            # Validate message before processing
            if not self._validate_message(message):
                logging.warning("Message validation failed")
                return
                
            if message.get("event") == "phx_reply":  # Handle join response
                if message.get("payload", {}).get("status") == "ok":
                    logging.info("Successfully joined events channel")
                return
            elif message.get("event") == "phx_error":
                if "unauthorized" in str(message.get("payload")):
                    logging.error("Authentication failed")
                    return

            payload = message.get("payload", {})
            msg_type = payload.get("type")

            # Add security audit logging for sensitive operations
            if msg_type in ["user:join", "user:leave", "system:update"]:
                logging.info(f"Security audit: {msg_type}")

            if msg_type == "system_event":
                event_type = payload.get("event")
                event_data = payload.get("payload", {})
                try:
                    system_event = SystemEvent[event_type.upper()]
                    self.event_manager.system_event.emit(system_event, event_data)
                except KeyError:
                    logging.warning(f"Unknown system event type: {event_type}")

            elif msg_type == "news":
                news_data = payload.get("payload", {})
                title = news_data.get("title", "")
                message = self._sanitize_content(news_data.get("message", ""))
                priority_str = news_data.get("priority", "NORMAL")
                try:
                    priority = EventPriority[priority_str.upper()]
                    self.event_manager.broadcast_news(title, message, priority)
                except KeyError:
                    logging.warning(f"Unknown priority level: {priority_str}")

        except Exception as e:
            logging.error(f"Error processing message: {e}")

    @staticmethod
    def _sanitize_content(content: str) -> str:
        """Basic content sanitization"""
        # Add your content sanitization logic here
        # For example, remove HTML tags, scripts, etc.
        return content

    async def close(self):
        self.running = False
        if self.ws:
            await self.ws.close()

class WebSocketClient(QObject):
    # Signals for connection state
    connected = pyqtSignal()
    disconnected = pyqtSignal()
    error = pyqtSignal(str)
    state_changed = pyqtSignal(WebSocketState)
    auth_failed = pyqtSignal(str)

    # Signals for different resource types
    risk_created = pyqtSignal(dict)
    risk_updated = pyqtSignal(dict)
    risk_deleted = pyqtSignal(int)  # risk_id

    mitigation_created = pyqtSignal(dict)
    mitigation_updated = pyqtSignal(dict)
    mitigation_deleted = pyqtSignal(int)

    task_created = pyqtSignal(dict)
    task_updated = pyqtSignal(dict)
    task_completed = pyqtSignal(dict)

    # Add new signals for news and events
    news_received = pyqtSignal(dict)
    event_received = pyqtSignal(dict)
    notification_received = pyqtSignal(dict)
    system_status_updated = pyqtSignal(dict)
    message_received = pyqtSignal(dict)
    user_presence_changed = pyqtSignal(int, bool)  # user_id, is_online

    def __init__(self, base_url: str, token: str, event_manager: EventManager = None):
        super().__init__()
        # Enforce WSS
        if not base_url.startswith(('wss://', 'ws://')):
            base_url = f"wss://{base_url}"
        elif base_url.startswith('ws://') and not base_url.startswith('ws://localhost'):
            base_url = f"wss://{base_url[5:]}"
        self.base_url = base_url
        self.token = token
        self.event_manager = event_manager
        
        # Initialize WebSocket with security headers
        self.socket = QWebSocket()
        self.socket.setProperty("Authorization", f"Bearer {self.token}")
        self.socket.setProperty("X-Client-Version", "1.0.0")
        
        # Add message validation
        self.last_message_time = 0
        self.message_count = 0
        self.rate_limit_window = 60  # 60 seconds
        self.rate_limit_max = 100    # max 100 messages per minute

        # Connection state
        self.current_state = WebSocketState.DISCONNECTED
        self.reconnect_attempts = 0
        self.max_reconnect_attempts = 5
        
        # Setup reconnection timer
        self.reconnect_timer = QTimer(self)
        self.reconnect_timer.setInterval(5000)  # 5 seconds
        self.reconnect_timer.timeout.connect(self._try_reconnect)
        
        # Track subscriptions
        self.subscribed_channels = {
            "projects": set(),
            "news": False,
            "events": False,
            "system": False
        }
        
        # Operation tracking
        self.operation_counter = 0
        self.ref_counter = 0
        self.channels = {}

        # Connect socket signals
        self.socket.connected.connect(self._on_connected)
        self.socket.disconnected.connect(self._on_disconnected)
        self.socket.textMessageReceived.connect(self._on_message)
        self.socket.error.connect(self._on_error)

    def connect_to_server(self):
        """Connect to Phoenix WebSocket server with security checks"""
        if self.current_state != WebSocketState.CONNECTED:
            self._set_state(WebSocketState.CONNECTING)
            
            # Add security parameters
            params = {
                "token": self.token,
                "vsn": "2.0.0",
                "client_version": "1.0.0"
            }
            param_string = "&".join(f"{k}={v}" for k, v in params.items())
            url = f"{self.base_url}/socket/websocket?{param_string}"
            
            self.socket.open(url)

    def _validate_message(self, data: dict) -> bool:
        """Validate incoming messages for rate limiting and structure"""
        current_time = time.time()
        
        # Rate limiting
        if current_time - self.last_message_time > self.rate_limit_window:
            self.message_count = 0
            self.last_message_time = current_time
        
        self.message_count += 1
        if self.message_count > self.rate_limit_max:
            logging.warning("Rate limit exceeded")
            return False

        # Message structure validation
        required_fields = ["topic", "event", "payload"]
        if not all(field in data for field in required_fields):
            logging.warning("Invalid message structure")
            return False

        # Payload size validation (prevent memory attacks)
        payload_size = len(json.dumps(data.get("payload", {})))
        if payload_size > 1024 * 1024:  # 1MB limit
            logging.warning("Message payload too large")
            return False

        return True

    def _on_message(self, message: str):
        """Handle Phoenix channel messages with security validation"""
        try:
            data = json.loads(message)
            
            # Validate message before processing
            if not self._validate_message(data):
                logging.warning("Message validation failed")
                return
                
            # Handle authentication errors
            if data.get("event") == "phx_error":
                if "unauthorized" in str(data.get("payload")):
                    self.auth_failed.emit("Authentication failed")
                    return

            topic = data.get("topic", "")
            event = data.get("event")
            payload = data.get("payload", {})

            # Add security audit logging for sensitive operations
            if event in ["user:join", "user:leave", "system:update"]:
                logging.info(f"Security audit: {event} from {topic}")

            # Handle join responses
            if event == "phx_reply":
                if payload.get("status") == "ok":
                    logging.info(f"Successfully joined channel: {topic}")
                return

            # Handle different types of messages
            if topic.startswith("risks:"):
                self._handle_risk_event(event, payload)
            elif topic.startswith("project:"):
                self._handle_project_event(event, payload)
            elif topic.startswith("user:"):
                self._handle_user_message(event, payload)
            elif topic == "system":
                self._handle_system_event(event, payload)

        except json.JSONDecodeError:
            logging.error(f"Invalid JSON message received")
        except Exception as e:
            logging.error(f"Error processing message: {str(e)}")

    def _handle_system_event(self, event: str, payload: dict):
        """Enhanced system message handler with event manager integration"""
        if not self.event_manager:
            return

        if event == "system:maintenance_start":
            self.event_manager.system_event.emit(
                SystemEvent.MAINTENANCE_STARTED,
                payload
            )
        elif event == "system:maintenance_end":
            self.event_manager.system_event.emit(
                SystemEvent.MAINTENANCE_ENDED,
                payload
            )
        elif event == "system:update_available":
            self.event_manager.system_event.emit(
                SystemEvent.UPDATE_AVAILABLE,
                payload
            )
        elif event == "system:disk_space_warning":
            self.event_manager.system_event.emit(
                SystemEvent.DISK_SPACE_LOW,
                payload
            )
        
        self.system_status_updated.emit(payload)

    def _handle_user_message(self, event: str, payload: dict):
        """Handle user-related messages with security checks"""
        # Validate user IDs
        if "from_user_id" in payload and not isinstance(payload["from_user_id"], int):
            logging.warning("Invalid user ID in message")
            return
            
        if event == "new_message":
            # Sanitize message content
            if "content" in payload:
                payload["content"] = self._sanitize_content(payload["content"])
            self.message_received.emit(payload)
        elif event == "presence_diff":
            for user_id in payload.get("joins", {}):
                self.user_presence_changed.emit(int(user_id), True)
            for user_id in payload.get("leaves", {}):
                self.user_presence_changed.emit(int(user_id), False)

    @staticmethod
    def _sanitize_content(content: str) -> str:
        """Basic content sanitization"""
        # Add your content sanitization logic here
        # For example, remove HTML tags, scripts, etc.
        return content

    def join_channel(self, topic: str, params: dict = None):
        """Join a Phoenix channel"""
        if self.current_state == WebSocketState.CONNECTED:
            ref = self._get_ref()
            message = {
                "topic": topic,
                "event": "phx_join",
                "payload": params or {},
                "ref": ref
            }
            self.socket.sendTextMessage(json.dumps(message))
            self.channels[topic] = ref
            logging.info(f"Joining channel: {topic}")

    def leave_channel(self, topic: str):
        """Leave a Phoenix channel"""
        if topic in self.channels:
            message = {
                "topic": topic,
                "event": "phx_leave",
                "payload": {},
                "ref": self._get_ref()
            }
            self.socket.sendTextMessage(json.dumps(message))
            del self.channels[topic]
            logging.info(f"Left channel: {topic}")

    # Rest of your existing methods remain unchanged...