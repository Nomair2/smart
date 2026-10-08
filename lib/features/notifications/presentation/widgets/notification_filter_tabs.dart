import 'package:flutter/material.dart';

import '../cubit/notifications_state.dart';

class NotificationFilterTabs extends StatelessWidget {
  const NotificationFilterTabs({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final NotificationFilter selected;
  final ValueChanged<NotificationFilter> onSelected;

  static const _primaryGreen = Color(0xFF1E5B3D);
  static const _labels = {
    NotificationFilter.all: 'All',
    NotificationFilter.weather: 'Weather',
    NotificationFilter.routes: 'Routes',
    NotificationFilter.system: 'System',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _labels.entries.map((entry) {
          final isSelected = entry.key == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(entry.value),
              selected: isSelected,
              onSelected: (_) => onSelected(entry.key),
              selectedColor: _primaryGreen,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey.shade300),
            ),
          );
        }).toList(),
      ),
    );
  }
}
