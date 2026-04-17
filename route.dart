import 'package:digifun/routes/route_name.dart';
import 'package:digifun/screens/Auth/login/login_screen.dart';
import 'package:digifun/screens/Auth/signup/sign_up_screen.dart';
import 'package:digifun/screens/congrats/congrats_screen.dart';
import 'package:digifun/screens/dashboard/dashboard_screen.dart';
import 'package:digifun/screens/games/odd_one/odd_one.dart';
import 'package:digifun/screens/games/find_cards/find_card_game.dart';
import 'package:digifun/screens/games/swipe_arrow/swipe_arrow.dart';
import 'package:digifun/screens/games/match_color/match_the_color.dart';
import 'package:digifun/screens/games/math_challange/math_challenge.dart';
import 'package:digifun/screens/games/tap_circle/tap_the_circle.dart';
import 'package:digifun/screens/games/tic%20tac%20toe/game.dart';
import 'package:digifun/screens/leaderboard/leaderboard_screen.dart';
import 'package:digifun/screens/navbar_screen.dart';
import 'package:digifun/screens/profile/profile_screen.dart';
import 'package:digifun/screens/quiz%20screen/add_question.dart';
import 'package:digifun/screens/quiz%20screen/attemp_quiz_screen.dart';
import 'package:digifun/screens/quiz%20screen/generate_quiz.dart';
import 'package:digifun/screens/quiz%20screen/quiz_dashboard.dart';
import 'package:digifun/screens/reward%20screen/reward_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteName.dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        );

      case RouteName.signUp:
        return MaterialPageRoute(
          builder: (_) => const SignUpScreen(),
        );

      case RouteName.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case RouteName.navBarScreen:
        return MaterialPageRoute(
          builder: (_) => const NavbarScreen(),
        );

      case RouteName.quizDashboard:
        return MaterialPageRoute(
          builder: (_) => const QuizDashboard(),
        );

      case RouteName.rewardScreen:
        return MaterialPageRoute(
          builder: (_) => const RewardScreen(),
        );

      case RouteName.profileScreen:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        );

      case RouteName.tickTacToe:
        return MaterialPageRoute(
          builder: (_) => const TicTacToeScreen(),
        );

      case RouteName.findCard:
        return MaterialPageRoute(
          builder: (_) => const FindCardsGameScreen(),
        );

      case RouteName.tapCircle:
        return MaterialPageRoute(
          builder: (_) => const TapCircleGame(),
        );

      case RouteName.matchColor:
        return MaterialPageRoute(
          builder: (_) => const ColorMatchGame(),
        );

      case RouteName.addQuiz:
        final userId = FirebaseAuth.instance.currentUser?.uid ?? "";
        return MaterialPageRoute(
          builder: (_) => AddQuestionScreen(
            userId: userId,
          ),
        );

      case RouteName.quizAI:
        return MaterialPageRoute(
          builder: (_) => const GenerateQuizScreen(),
        );

      case RouteName.leaderboardScreen:
        return MaterialPageRoute(
          builder: (_) => const LeaderboardScreen(),
        );

      case RouteName.swipeDirection:
        return MaterialPageRoute(
          builder: (_) => const SwipeGameScreen(),
        );

      case RouteName.mathChallenge:
        return MaterialPageRoute(
          builder: (_) => const MathChallengeScreen(),
        );

      case RouteName.oddOneOut:
        return MaterialPageRoute(
          builder: (_) => const OddOneOutGame(),
        );

      case RouteName.attempQuiz:
        final arguments = (settings.arguments as String).split(',');
        return MaterialPageRoute(
          builder: (_) => AttempQuizScreen(
            quizId: arguments[0],
            quizTitle: arguments[1],
          ),
        );

      case RouteName.congratscreen:
        final arguments = (settings.arguments as String).split(',');
        final int correctAnswers = int.parse(arguments[0]);
        final int totalQuestions = int.parse(arguments[1]);
        final String quizId = arguments[2];

        return MaterialPageRoute(
          builder: (_) => CongratsScreen(
            correctAnswers: correctAnswers,
            totalQuestions: totalQuestions,
            quizId: quizId,
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Error: This page doesn\'t exist'),
            ),
          ),
        );
    }
  }
}
