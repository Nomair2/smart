import 'package:MasarKKU/features/routing/data/noop_voice_guide_service.dart';
import 'package:MasarKKU/features/routing/data/repositories/fake_campus_repository.dart';
import 'package:MasarKKU/features/routing/domain/repositories/campus_repository.dart';
import 'package:MasarKKU/features/routing/domain/voice_guide_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/admin/presentation/pages/admin_home_placeholder_page.dart';
import 'features/auth/data/repositories/firebase_auth_repository.dart';
import 'features/auth/domain/entities/app_user_role.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/welcome_page.dart';
import 'features/home/data/repositories/fake_home_repository.dart';
import 'features/home/domain/repositories/home_repository.dart';
import 'features/profile/data/repositories/firestore_profile_repository.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/shell/presentation/pages/main_shell_page.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => FirebaseAuthRepository(),
        ),
        RepositoryProvider<ProfileRepository>(
          create: (_) => FirestoreProfileRepository(),
        ),
        // Weather (C1) and recent routes (C4/C7) aren't built yet — see the
        // doc comment on HomeRepository for what swapping this out later
        // needs.
        RepositoryProvider<HomeRepository>(create: (_) => FakeHomeRepository()),
        RepositoryProvider<CampusRepository>(
          create: (_) => FakeCampusRepository(),
        ),
        RepositoryProvider<VoiceGuideService>(
          create: (_) => NoopVoiceGuideService(),
        ),
      ],
      child: const SmartPathApp(),
    ),
  );
}

class SmartPathApp extends StatelessWidget {
  const SmartPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Masar KKU',
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
      routes: {
        '/welcome': (_) => const WelcomeScreen(),
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/forgot-password': (_) => const ForgotPasswordPage(),
        '/home': (_) => const MainShellPage(),
        '/admin-home': (_) => const AdminHomePlaceholderPage(),
      },
    );
  }
}

/// Skips straight to the right home screen if Firebase already has a
/// signed-in user (e.g. app was reopened after a previous login) instead of
/// always showing the welcome screen first — and routes admins to the admin
/// home rather than the student one.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<fb.User?>(
      stream: fb.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data == null) {
          return const WelcomeScreen();
        }
        return FutureBuilder<AppUserRole>(
          future: context.read<AuthRepository>().currentUserRole(),
          builder: (context, roleSnapshot) {
            if (!roleSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return roleSnapshot.data == AppUserRole.admin
                ? const AdminHomePlaceholderPage()
                : const MainShellPage();
          },
        );
      },
    );
  }
}
