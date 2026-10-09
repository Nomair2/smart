import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../domain/entities/notification_item.dart';
import '../../domain/repositories/notification_repository.dart';

/// Reads/writes `users/{uid}/notifications/{id}` — a subcollection under
/// the signed-in student's own profile doc, not a top-level collection
/// filtered by a `uid` field. That shape means `isRead` is naturally
/// per-user (two students never share a document to race over) and the
/// security rule is the same owner-or-admin check already used for
/// `users/{uid}` itself (see firestore.rules).
///
/// Nothing in the student app writes here — notifications only arrive via
/// `AdminNotificationRepository.sendToAll`/`sendToUser`, which fans a copy
/// out into every targeted student's subcollection. See that class's doc
/// comment for why a fan-out write was chosen over a shared broadcast
/// document.
class FirestoreNotificationRepository implements NotificationRepository {
  FirestoreNotificationRepository({
    FirebaseFirestore? firestore,
    fb.FirebaseAuth? firebaseAuth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final fb.FirebaseAuth _firebaseAuth;

  static const _usersCollection = 'users';
  static const _notificationsSubcollection = 'notifications';

  CollectionReference<Map<String, dynamic>> get _collection {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) {
      throw StateError('No signed-in user to load notifications for.');
    }
    return _firestore
        .collection(_usersCollection)
        .doc(uid)
        .collection(_notificationsSubcollection);
  }

  @override
  Stream<List<NotificationItem>> watchNotifications() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Future<void> markAsRead(String id) async {
    await _collection.doc(id).update({'isRead': true});
  }

  @override
  Future<void> markAllAsRead() async {
    // Firestore caps a batch at 500 writes; a single student racking up
    // more than that many unread notifications is unrealistic, but the
    // chunking costs nothing to include and matches the same safeguard in
    // FirestoreAdminNotificationRepository's fan-out.
    final unread = await _collection.where('isRead', isEqualTo: false).get();
    const chunkSize = 450;
    for (var i = 0; i < unread.docs.length; i += chunkSize) {
      final batch = _firestore.batch();
      final end = (i + chunkSize < unread.docs.length)
          ? i + chunkSize
          : unread.docs.length;
      for (final doc in unread.docs.sublist(i, end)) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    }
  }

  NotificationItem _fromFirestore(String id, Map<String, dynamic> data) {
    return NotificationItem(
      id: id,
      title: data['title'] as String? ?? '',
      message: data['message'] as String? ?? '',
      type: NotificationType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => NotificationType.system,
      ),
      // A doc just written with FieldValue.serverTimestamp() reads back as
      // null for the brief moment before the server round-trips it — fall
      // back to "now" rather than crash the whole list over one in-flight
      // notification.
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] as bool? ?? false,
    );
  }
}
