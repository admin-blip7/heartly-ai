import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/camera_screen.dart';
import '../screens/analysis_loading_screen.dart';
import '../screens/results_screen.dart';
import '../screens/challenge_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/camera',
        builder: (context, state) => const CameraScreen(),
      ),
      GoRoute(
        path: '/analysis',
        builder: (context, state) {
          final imagePath = state.extra as String?;
          return AnalysisLoadingScreen(imagePath: imagePath ?? '');
        },
      ),
      GoRoute(
        path: '/results',
        builder: (context, state) => const ResultsScreen(),
      ),
      GoRoute(
        path: '/challenge',
        builder: (context, state) => const ChallengeScreen(),
      ),
      GoRoute(
        path: '/challenge/:id',
        builder: (context, state) {
          final challengeId = state.pathParameters['id'];
          return ChallengeScreen(challengeId: challengeId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
}
