class NotificationsService {
  int _unreadCount = 0;

  int get unreadCount => _unreadCount;

  void incrementUnreadCount() {
    _unreadCount++;
  }

  void resetUnreadCount() {
    _unreadCount = 0;
  }
}
