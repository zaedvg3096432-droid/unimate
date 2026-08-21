import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/schedule_screen.dart';
import '../screens/tasks_screen.dart';
import '../screens/notes_screen.dart';
import '../screens/more_screen.dart';

class UnimateShell extends StatefulWidget { const UnimateShell({super.key}); @override State<UnimateShell> createState() => _UnimateShellState(); }
class _UnimateShellState extends State<UnimateShell> {
 int index = 0;
 final pages = const [DashboardScreen(), ScheduleScreen(), TasksScreen(), NotesScreen(), MoreScreen()];
 @override Widget build(BuildContext context) => Scaffold(body: IndexedStack(index: index, children: pages), bottomNavigationBar: NavigationBar(selectedIndex: index, onDestinationSelected: (i) => setState(() => index = i), destinations: const [NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Today'), NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Schedule'), NavigationDestination(icon: Icon(Icons.check_circle_outline), selectedIcon: Icon(Icons.check_circle), label: 'Tasks'), NavigationDestination(icon: Icon(Icons.sticky_note_2_outlined), selectedIcon: Icon(Icons.sticky_note_2), label: 'Notes'), NavigationDestination(icon: Icon(Icons.grid_view_rounded), selectedIcon: Icon(Icons.grid_view), label: 'More')]));
}

