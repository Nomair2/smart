import 'package:equatable/equatable.dart';

import '../../domain/entities/notification_item.dart';

enum NotificationsStatus { loading, loaded, error }

enum NotificationFilter { all, weather, routes, system }

class NotificationsState extends Equatable {
  const NotificationsState({
    this.status = NotificationsStatus.loading,
    this.items = const [],
    this.filter = NotificationFilter.all,
    this.errorMessage,
  });

  final NotificationsStatus status;
  final List<NotificationItem> items;
  final NotificationFilter filter;
  final String? errorMessage;

  int get unreadCount => items.where((n) => !n.isRead).length;

  List<NotificationItem> get filteredItems {
    if (filter == NotificationFilter.all) return items;
    final matchingTypes = switch (filter) {
      NotificationFilter.weather => const [NotificationType.weatherAlert],
      NotificationFilter.routes => const [NotificationType.routeUpdate],
      NotificationFilter.system => const [
          NotificationType.system,
          NotificationType.maintenance,
        ],
      NotificationFilter.all => NotificationType.values,
    };
    return items.where((n) => matchingTypes.contains(n.type)).toList();
  }

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationItem>? items,
    NotificationFilter? filter,
    String? errorMessage,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      items: items ?? this.items,
      filter: filter ?? this.filter,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, filter, errorMessage];
}
