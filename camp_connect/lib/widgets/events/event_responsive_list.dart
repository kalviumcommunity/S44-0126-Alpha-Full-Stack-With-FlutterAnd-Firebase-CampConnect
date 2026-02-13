import 'package:flutter/material.dart';

typedef EventItemBuilder =
    Widget Function(BuildContext context, Map<String, dynamic> event);

// ================= RESPONSIVE EVENT LIST =================

class EventResponsiveList extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  final EventItemBuilder itemBuilder;

  final bool shrinkWrap;
  final ScrollPhysics physics;

  const EventResponsiveList({
    super.key,
    required this.events,
    required this.itemBuilder,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 930;

    return isWide ? _buildGrid(context) : _buildList(context);
  }

  // ================= GRID =================

  Widget _buildGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: events.length,

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 2.8,
      ),

      itemBuilder: (c, i) => itemBuilder(c, events[i]),
    );
  }

  // ================= LIST =================

  Widget _buildList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: events.length,

      itemBuilder: (c, i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: itemBuilder(c, events[i]),
        );
      },
    );
  }
}
