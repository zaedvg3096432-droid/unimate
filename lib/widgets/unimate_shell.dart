import 'package:flutter/material.dart';
import '../core/app_strings.dart';
import '../screens/dashboard_screen.dart';
import '../screens/schedule_screen.dart';
import '../screens/tasks_screen.dart';
import '../screens/notes_screen.dart';
import '../screens/more_screen.dart';

class UnimateShell extends StatefulWidget {
  const UnimateShell({super.key});
  @override State<UnimateShell> createState() => _UnimateShellState();
}

class _UnimateShellState extends State<UnimateShell> {
  int index = 0;
  final pages = const [DashboardScreen(), ScheduleScreen(), TasksScreen(), NotesScreen(), MoreScreen()];

  @override
  Widget build(BuildContext context) {
    final labels = [context.t('today'), context.t('schedule'), context.t('tasks'), context.t('notes'), context.t('more')];
    const icons = [Icons.home_outlined, Icons.calendar_month_outlined, Icons.check_circle_outline, Icons.sticky_note_2_outlined, Icons.grid_view_rounded];
    const selected = [Icons.home, Icons.calendar_month, Icons.check_circle, Icons.sticky_note_2, Icons.grid_view];
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: [for (var i = 0; i < labels.length; i++) NavigationDestination(icon: Icon(icons[i]), selectedIcon: Icon(selected[i]), label: labels[i])],
      ),
    );
  }
}
