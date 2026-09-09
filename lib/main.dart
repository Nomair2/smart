import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartpath/features/auth/data/repositories/fake_auth_repository.dart';
import 'package:smartpath/features/auth/domain/repositories/auth_repository.dart';
import 'package:smartpath/features/auth/presentation/pages/login_page.dart';
import 'package:smartpath/features/auth/presentation/pages/register_page.dart';
import 'package:smartpath/features/auth/presentation/pages/welcome_page.dart';

void main() {
  runApp(
    RepositoryProvider<AuthRepository>(
      create: (_) => FakeAuthRepository(),
      child: const SmartPathApp(),
    ),
  );
}

class SmartPathApp extends StatelessWidget {
  const SmartPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Path',
      debugShowCheckedModeBanner: false,
      home: const RegisterPage(),
    );
  }
}
