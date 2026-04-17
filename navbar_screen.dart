import 'package:digifun/screens/challanges/tasks_screen.dart';
import 'package:digifun/screens/dashboard/dashboard_screen.dart';
import 'package:digifun/screens/leaderboard/leaderboard_screen.dart';
import 'package:digifun/screens/profile/profile_screen.dart';
import 'package:digifun/screens/quiz%20screen/quiz_dashboard.dart';
import 'package:digifun/screens/reward%20screen/reward_screen.dart';
import 'package:flutter/material.dart';
import 'package:digifun/utilites/colors.dart';

class NavbarScreen extends StatefulWidget {
  const NavbarScreen({super.key});

  @override
  State<NavbarScreen> createState() => _NavbarScreenState();
}

class _NavbarScreenState extends State<NavbarScreen> {
  int _selectedIndex = 0;
  String? currentUserId;
  bool hasNavigated = false;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const QuizDashboard(),
    const LeaderboardScreen(),
    const RewardScreen(),
    const ProfileScreen(),
    const TasksScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: 'Quiz',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Rewards',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tasks',
          ),
        ],
      ),
    );
  }
}
