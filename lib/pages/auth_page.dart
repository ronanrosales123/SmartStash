import 'dart:async'; // Import this for Timer functionality
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:SmartStash/pages/login_or_registerpage.dart';
import 'home_page.dart';
import 'EmailVerification_Page.dart'; // Import your EmailVerificationPage

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  Timer? _logoutTimer;

  @override
  void initState() {
    super.initState();
    _startLogoutTimer();
  }

  @override
  void dispose() {
    _logoutTimer?.cancel(); // Cancel the timer if the widget is disposed
    super.dispose();
  }

  void _startLogoutTimer() {
    _logoutTimer?.cancel(); // Cancel any existing timer
    _logoutTimer = Timer(Duration(minutes: 5), () {
      FirebaseAuth.instance.signOut(); // Log out the user after 5 minutes
    });
  }

  // Method to reset the logout timer
  void _resetLogoutTimer() {
    _startLogoutTimer();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _resetLogoutTimer, // Reset timer on tap
      onPanUpdate: (_) => _resetLogoutTimer(), // Reset timer on drag
      child: Scaffold(
        body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // While waiting for the auth state to change, show a loading indicator
              return Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasData) {
              User? user = snapshot.data;

              if (user != null && user.emailVerified) {
                // If email is verified, go to home page
                return HomePage();
              } else if (user != null && !user.emailVerified) {
                // If email is not verified, go to Email Verification page
                return EmailVerificationPage();
              }
            } 
            // User not logged in, show login or register page
            return LoginOrRegisterPage();
          },
        ),
      ),
    );
  }
}
