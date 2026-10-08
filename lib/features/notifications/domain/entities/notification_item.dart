import 'package:equatable/equatable.dart';

/// Matches requirement A11 (notifications — report section 3.7.10). Kept
/// deliberately small: a notification here is a read-only announcement the
/// system pushes to the student, not something they author, so there's no
/// "body" rich-text or attachments model to design around yet.
enum NotificationType { weatherAlert, routeUpdate, maintenance, system }

class NotificationItem extends Equatable {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      message: message,
      type: type,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [id, title, message, type, createdAt, isRead];
}
