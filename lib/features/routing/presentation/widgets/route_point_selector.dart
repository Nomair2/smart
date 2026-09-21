import 'package:flutter/material.dart';

import '../../domain/entities/campus_node.dart';

/// The "Starting Point / Destination" card — the two dropdowns plus the
/// green/red connector dots and the Swap Points button, matching Select
/// Route's layout as one visual unit.
class RoutePointSelector extends StatelessWidget {
  const RoutePointSelector({
    super.key,
    required this.nodes,
    required this.origin,
    required this.destination,
    required this.onOriginChanged,
    required this.onDestinationChanged,
    required this.onSwap,
  });

  final List<CampusNode> nodes;
  final CampusNode? origin;
  final CampusNode? destination;
  final ValueChanged<CampusNode> onOriginChanged;
  final ValueChanged<CampusNode> onDestinationChanged;
  final VoidCallback onSwap;

  static const Color primaryGreen = Color(0xFF1E5B3D);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Connector(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Field(
                        label: 'Starting Point',
                        hint: 'Choose starting point',
                        value: origin,
                        options: nodes,
                        onChanged: onOriginChanged,
                      ),
                      const SizedBox(height: 18),
                      _Field(
                        label: 'Destination',
                        hint: 'Choose destination',
                        value: destination,
                        options: nodes,
                        onChanged: onDestinationChanged,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: (origin == null && destination == null) ? null : onSwap,
              icon: const Icon(Icons.swap_vert_rounded, size: 18),
              label: const Text('Swap Points'),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryGreen,
                side: const BorderSide(color: Color(0xFFDDE5E1)),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      child: Column(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(color: Color(0xFF1E5B3D), shape: BoxShape.circle),
          ),
          Expanded(
            child: Container(width: 2, color: const Color(0xFFDDE5E1), margin: const EdgeInsets.symmetric(vertical: 4)),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(color: Color(0xFFE0574C), shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.hint,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final CampusNode? value;
  final List<CampusNode> options;
  final ValueChanged<CampusNode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: Colors.grey[500])),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<CampusNode>(
              value: value,
              isExpanded: true,
              hint: Text(hint, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              items: options
                  .map((node) => DropdownMenuItem(
                        value: node,
                        child: Text(node.name ?? node.code ?? node.id,
                            style: const TextStyle(color: Color(0xFF2F6FE0), fontWeight: FontWeight.w600, fontSize: 14)),
                      ))
                  .toList(),
              onChanged: (node) {
                if (node != null) onChanged(node);
              },
            ),
          ),
        ),
      ],
    );
  }
}
