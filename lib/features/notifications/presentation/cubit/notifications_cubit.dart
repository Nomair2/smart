import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/notification_repository.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._repository) : super(const NotificationsState()) {
    _subscription = _repository.watchNotifications().listen(
      (items) => emit(state.copyWith(
        status: NotificationsStatus.loaded,
        items: items,
        errorMessage: null,
      )),
      onError: (error) => emit(state.copyWith(
        status: NotificationsStatus.error,
        errorMessage: error.toString(),
      )),
    );
  }

  final NotificationRepository _repository;
  StreamSubscription? _subscription;

  void filterChanged(NotificationFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  Future<void> markAsRead(String id) => _repository.markAsRead(id);

  Future<void> markAllAsRead() => _repository.markAllAsRead();

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
