from PyQt6.QtWidgets import QApplication, QMainWindow, QMessageBox, QDockWidget
from PyQt6.QtCore import Qt, QTimer
import signal
import sys
import logging
from .websocket_client import WebSocketClient, WebSocketState
from .event_manager import EventManager, SystemEvent, EventPriority
from .notification_manager import NotificationManager, NotificationType, NotificationPriority
from .notification_center import NotificationCenter
from .messaging_client import MessagingClient, Message

class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.event_manager = EventManager()
        self.ws_client = WebSocketClient(
            base_url="ws://localhost:4000",
            token="your_auth_token"
        )
        
        # Add messaging client initialization
        self.messaging_client = MessagingClient(self.event_manager, user_id=1)  # Replace 1 with actual user_id
        self.messaging_client.message_received.connect(self.handle_new_message)
        self.messaging_client.user_presence_changed.connect(self.handle_presence_change)
        
        # Connect event manager signals
        self.event_manager.system_event.connect(self.handle_system_event)
        self.event_manager.news_broadcast.connect(self.handle_news_broadcast)
        self.event_manager.operation_interrupted.connect(self.handle_operation_interrupt)
        
        # Connect WebSocket signals
        self.ws_client.connected.connect(self.on_ws_connected)
        self.ws_client.disconnected.connect(self.on_ws_disconnected)
        self.ws_client.error.connect(self.on_ws_error)
        
        # Initialize notification system
        self.notification_manager = NotificationManager()
        self.notification_center = NotificationCenter()
        
        # Connect notification signals
        self.notification_manager.notification_added.connect(
            self.notification_center.add_notification
        )
        self.notification_manager.notification_removed.connect(
            self.notification_center.remove_notification
        )

        # Add notification center to a dock widget
        dock = QDockWidget("Notifications", self)
        dock.setWidget(self.notification_center)
        self.addDockWidget(Qt.DockWidgetArea.RightDockWidgetArea, dock)
        
        # Setup UI
        self.setup_ui()
        
        # Start connection
        self.ws_client.connect_to_server()

    def handle_system_event(self, event: SystemEvent, data: dict):
        """Handle system-wide events"""
        if event == SystemEvent.RESTART_REQUESTED:
            self.prepare_for_restart(data.get("reason", ""))
        elif event == SystemEvent.MAINTENANCE_STARTED:
            self.handle_maintenance_mode(True)
        elif event == SystemEvent.MAINTENANCE_ENDED:
            self.handle_maintenance_mode(False)
        elif event == SystemEvent.UPDATE_AVAILABLE:
            self.notification_manager.add_notification(
                type=NotificationType.UPDATE,
                priority=NotificationPriority.INFO,
                title="Update Available",
                message="A new version is available. Would you like to update now?",
                action="Update Now",
                expires_in=timedelta(days=1)
            )
        elif event == SystemEvent.DISK_SPACE_LOW:
            self.notification_manager.add_notification(
                type=NotificationType.SYSTEM,
                priority=NotificationPriority.WARNING,
                title="Low Disk Space",
                message="Your disk space is running low. Please free up some space.",
                expires_in=timedelta(hours=1)
            )
        elif event == SystemEvent.SESSION_EXPIRED:
            self.notification_manager.add_notification(
                type=NotificationType.SECURITY,
                priority=NotificationPriority.CRITICAL,
                title="Session Expired",
                message="Your session has expired. Please log in again.",
                action="Log In"
            )

    def handle_news_broadcast(self, title: str, message: str, priority: EventPriority):
        """Handle news broadcasts"""
        if priority == EventPriority.CRITICAL:
            QMessageBox.critical(self, title, message)
        elif priority == EventPriority.HIGH:
            QMessageBox.warning(self, title, message)
        else:
            self.status_bar.showMessage(f"{title}: {message}", 5000)

    def handle_operation_interrupt(self):
        """Handle interrupted operations"""
        self.status_bar.showMessage("Operations interrupted", 3000)
        # Clean up any ongoing operations in your UI

    def prepare_for_restart(self, reason: str):
        """Prepare application for restart"""
        # Save any necessary state
        self.save_application_state()
        
        # Disconnect from WebSocket
        self.ws_client.disconnect()
        
        # Show restart message
        QMessageBox.information(
            self,
            "Application Restart",
            f"The application will now restart.\nReason: {reason}"
        )
        
        # Schedule actual restart
        QTimer.singleShot(0, self.perform_restart)

    def perform_restart(self):
        """Perform the actual restart"""
        QApplication.quit()
        # You might want to use subprocess to start a new instance
        # before quitting the current one

    def closeEvent(self, event):
        """Handle application shutdown"""
        if self.event_manager.has_active_operations():
            reply = QMessageBox.question(
                self,
                'Confirm Exit',
                'There are ongoing operations. Are you sure you want to exit?',
                QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No,
                QMessageBox.StandardButton.No
            )
            
            if reply == QMessageBox.StandardButton.No:
                event.ignore()
                return

        self.ws_client.disconnect()
        event.accept()

    def handle_new_message(self, message: Message):
        """Handle incoming messages"""
        self.notification_manager.add_notification(
            type=NotificationType.USER,
            priority=NotificationPriority.INFO,
            title=f"New Message",
            message=f"From {message.from_user_id}: {message.content}"
        )

    def handle_presence_change(self, user_id: int, is_online: bool):
        """Handle user presence updates"""
        status = "online" if is_online else "offline"
        self.status_bar.showMessage(f"User {user_id} is now {status}", 3000)

def main():
    # Configure logging
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    
    app = QApplication(sys.argv)
    
    # Handle system signals
    def signal_handler(signum, frame):
        if signum == signal.SIGTERM:
            # Handle SIGTERM (graceful shutdown)
            window.event_manager.request_restart(
                reason="System requested shutdown",
                force=True
            )
        elif signum == signal.SIGUSR1:
            # Handle SIGUSR1 (custom restart signal)
            window.event_manager.request_restart(
                reason="Administrator requested restart"
            )
    
    signal.signal(signal.SIGTERM, signal_handler)
    signal.signal(signal.SIGUSR1, signal_handler)
    
    window = MainWindow()
    window.show()
    
    # Example news broadcast
    QTimer.singleShot(2000, lambda: window.event_manager.broadcast_news(
        "Welcome",
        "Application started successfully",
        EventPriority.NORMAL
    ))
    
    sys.exit(app.exec())

if __name__ == "__main__":
    main()    