import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/notification_repository.dart';
import '../cubit/notifications_cubit.dart';
import '../cubit/notifications_state.dart';
import '../widgets/notification_card.dart';
import '../widgets/notification_filter_tabs.dart';

const _primaryGreen = Color(0xFF1E5B3D);
const _primaryGreenLight = Color(0xFF2F7A55);

/// Requirement A11. Same shape as `ProfilePage`: wraps itself in a
/// `BlocProvider` that reads the repository `main.dart` already hangs off
/// `MaterialApp` (`RepositoryProvider<NotificationRepository>`), so this
/// page is a self-contained drop-in wherever it's placed — currently a tab
/// in `MainShellPage`.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          NotificationsCubit(context.read<NotificationRepository>()),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: SafeArea(
        child: Column(
          children: [
            BlocBuilder<NotificationsCubit, NotificationsState>(
              builder: (context, state) => _Header(unreadCount: state.unreadCount),
            ),
            const SizedBox(height: 14),
            BlocBuilder<NotificationsCubit, NotificationsState>(
              builder: (context, state) => NotificationFilterTabs(
                selected: state.filter,
                onSelected: context.read<NotificationsCubit>().filterChanged,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<NotificationsCubit, NotificationsState>(
                builder: (context, state) {
                  if (state.status == NotificationsStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.status == NotificationsStatus.error) {
                    return Center(
                      child: Text(
                        'Could not load notifications.\n${state.errorMessage ?? ''}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    );
                  }
                  final items = state.filteredItems;
                  if (items.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.notifications_none_rounded,
                                size: 40, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text('No notifications here',
                                style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return NotificationCard(
                        notification: item,
                        onTap: () => context
                            .read<NotificationsCubit>()
                            .markAsRead(item.id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryGreen, _primaryGreenLight],
        ),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.notifications_rounded,
                    color: Colors.white, size: 22),
              ),
              if (unreadCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0574C),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  unreadCount == 0
                      ? 'You\'re all caught up'
                      : '$unreadCount unread',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.85), fontSize: 12.5),
                ),
              ],
            ),
          ),
          if (unreadCount > 0)
            TextButton(
              onPressed: () =>
                  context.read<NotificationsCubit>().markAllAsRead(),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.15),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Mark all read',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}
