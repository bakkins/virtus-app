import 'package:flutter/material.dart';

enum HomeSection { home, statistics, settings }

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar({
    super.key,
    required this.section,
    required this.onSectionChanged,
    this.onFinish,
    this.onHistory,
  });

  final HomeSection section;
  final ValueChanged<HomeSection> onSectionChanged;
  final VoidCallback? onFinish;
  final VoidCallback? onHistory;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(_titleFor(section)),
      actions: [
        if (section == HomeSection.home) ...[
          IconButton(
            key: const Key('finish-workout-button'),
            icon: const Icon(Icons.check),
            tooltip: 'Finish workout',
            onPressed: onFinish,
          ),
          IconButton(
            key: const Key('history-button'),
            icon: const Icon(Icons.history),
            tooltip: 'History',
            onPressed: onHistory,
          ),
        ],
        PopupMenuButton<HomeSection>(
          key: const Key('section-menu-button'),
          tooltip: 'Navigate',
          onSelected: onSectionChanged,
          itemBuilder: (context) => const [
            PopupMenuItem<HomeSection>(
              key: Key('section-home'),
              value: HomeSection.home,
              child: Text('Home'),
            ),
            PopupMenuItem<HomeSection>(
              key: Key('section-statistics'),
              value: HomeSection.statistics,
              child: Text('Statistics'),
            ),
            PopupMenuItem<HomeSection>(
              key: Key('section-settings'),
              value: HomeSection.settings,
              child: Text('Settings'),
            ),
          ],
        ),
      ],
    );
  }

  static String _titleFor(HomeSection section) => switch (section) {
    HomeSection.home => 'Workout',
    HomeSection.statistics => 'Statistics',
    HomeSection.settings => 'Settings',
  };

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
