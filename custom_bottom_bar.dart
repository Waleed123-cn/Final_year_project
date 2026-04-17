// import 'package:digifun/components/utilites/image_resource.dart';
// import 'package:flutter/material.dart';

// Widget customBottomNavBar({
//   required int currentIndex,
//   required ValueChanged<int> onTap,
// }) {
//   return BottomNavigationBar(
//     currentIndex: currentIndex,
//     selectedLabelStyle: const TextStyle(
//       fontWeight: FontWeight.bold,
//       fontFamily: 'Raleway',
//     ),
//     unselectedLabelStyle: const TextStyle(
//       fontWeight: FontWeight.bold,
//       fontFamily: 'Raleway',
//     ),
//     onTap: onTap,
//     selectedItemColor: Colors.redAccent,
//     unselectedItemColor: Colors.grey,
//     showSelectedLabels: true,
//     showUnselectedLabels: true,
//     items: [
//       BottomNavigationBarItem(
//         icon: Image.asset(
//           ImageRes.gameLogo,
//           height: 30,
//           width: 30,
//         ),
//         label: 'Games',
//       ),
//       BottomNavigationBarItem(
//         icon: Image.asset(ImageRes.quizLogo, height: 30, width: 30),
//         label: 'Quizzes',
//       ),
//       BottomNavigationBarItem(
//         icon: Image.asset(ImageRes.rewardLogo, height: 30, width: 30),
//         label: 'Rewards',
//       ),
//       const BottomNavigationBarItem(
//         icon: Icon(Icons.person),
//         label: 'Profile',
//       ),
//       const BottomNavigationBarItem(
//         icon: Icon(Icons.settings),
//         label: 'Settings',
//       ),
//     ],
//   );
// }
