import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:SmartStash/pages/login_or_registerpage.dart';
import 'home_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          //user logged in
          if (snapshot.hasData) {
            return HomePage();
          }

          //user is not logged in
          else {
            return LoginOrRegisterPage();
          }
        },
      ),
    );
  }
}
