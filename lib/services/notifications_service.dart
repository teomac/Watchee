class NotificationsService {
  static final NotificationsService _instance =
      NotificationsService._internal();

  factory NotificationsService() {
    return _instance;
  }

  NotificationsService._internal();

  int _unreadCount = 0;

  int get unreadCount => _unreadCount;

  void incrementUnreadCount() {
    _unreadCount++;
  }

  void resetUnreadCount() {
    _unreadCount = 0;
  }
}
