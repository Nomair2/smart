import '../entities/notification_item.dart';

/// Backed by [FakeNotificationRepository] for now — no backend job pushes
/// real weather alerts or route-closure notices yet (that's a server-side
/// trigger, e.g. a Cloud Function watching `path_segments` for a status
/// change admins make on the B5 screen, or a scheduled weather check).
/// Swapping in a Firestore-backed implementation that watches a
/// `notifications/{uid}` subcollection is the same one-line change as every
/// other repository in this app.
abstract class NotificationRepository {
  /// Live, newest first.
  Stream<List<NotificationItem>> watchNotifications();

  Future<void> markAsRead(String id);

  Future<void> markAllAsRead();
}
