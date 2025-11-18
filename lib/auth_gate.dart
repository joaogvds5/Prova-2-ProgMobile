import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'telas/loginTela.dart';
import 'telas/homeTela.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const HomeTela();
        }

        return const LoginTela();
      },
    );
  }
}
