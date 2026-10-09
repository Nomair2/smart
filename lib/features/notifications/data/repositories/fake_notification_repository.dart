// import 'dart:async';

// import '../../domain/entities/notification_item.dart';
// import '../../domain/repositories/notification_repository.dart';

// /// Seeds a small, plausible set of notifications on first listen and keeps
// /// them in memory — same `StreamController.broadcast` pattern as the rest
// /// of the fake/real repository pairs in this app (e.g. `ProfileRepository`'s
// /// `watchCurrentProfile`), so swapping in a real implementation later needs
// /// no change to the cubit that consumes it.
// class FakeNotificationRepository implements NotificationRepository {
//   FakeNotificationRepository() {
//     _controller = StreamController<List<NotificationItem>>.broadcast(
//       onListen: () => _controller.add(List.unmodifiable(_items)),
//     );
//   }

//   late final StreamController<List<NotificationItem>> _controller;

//   final List<NotificationItem> _items = () {
//     final now = DateTime.now();
//     return [
//       NotificationItem(
//         id: 'n1',
//         title: 'Heat warning',
//         message:
//             'Temperatures near Gate 1 are expected to exceed 42°C this '
//             'afternoon. Comfort-optimized routes are recommended.',
//         type: NotificationType.weatherAlert,
//         createdAt: now.subtract(const Duration(minutes: 25)),
//       ),
//       NotificationItem(
//         id: 'n2',
//         title: 'Path closed near Gate 2',
//         message:
//             'The shaded walkway between Gate 2 and the Library is closed '
//             'for maintenance. Routes through this area have been updated '
//             'automatically.',
//         type: NotificationType.routeUpdate,
//         createdAt: now.subtract(const Duration(hours: 3)),
//       ),
//       NotificationItem(
//         id: 'n3',
//         title: 'Season mode switched to Summer',
//         message:
//             'Based on the current date, your default season mode was '
//             'automatically set to Summer. You can change this anytime in '
//             'Profile settings.',
//         type: NotificationType.system,
//         createdAt: now.subtract(const Duration(days: 1, hours: 4)),
//         isRead: true,
//       ),
//     ];
//   }();

//   @override
//   Stream<List<NotificationItem>> watchNotifications() => _controller.stream;

//   @override
//   Future<void> markAsRead(String id) async {
//     final index = _items.indexWhere((n) => n.id == id);
//     if (index == -1) return;
//     _items[index] = _items[index].copyWith(isRead: true);
//     _controller.add(List.unmodifiable(_items));
//   }

//   @override
//   Future<void> markAllAsRead() async {
//     for (var i = 0; i < _items.length; i++) {
//       _items[i] = _items[i].copyWith(isRead: true);
//     }
//     _controller.add(List.unmodifiable(_items));
//   }
// }
