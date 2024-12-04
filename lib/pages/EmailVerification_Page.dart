import 'package:SmartStash/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({Key? key}) : super(key: key);

  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  Timer? _timer;
  bool isVerified = false;

  @override
  void initState() {
    super.initState();
    _startEmailVerificationCheck();
  }

  // Function to periodically check if the email is verified
  void _startEmailVerificationCheck() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.reload();  // Reload user to get the latest email verification status
        if (user.emailVerified) {
          setState(() {
            isVerified = true;
          });
          timer.cancel(); // Stop checking once verified
          _showVerificationSuccessDialog();
        }
      }
    });
  }

  // Show dialog when email is verified
void _showVerificationSuccessDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Email Verified'),
        content: Text('Your email is now verified! You can now proceed.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();  // Close the dialog
              // Navigate to homepage after the dialog is dismissed
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),  // Use pushReplacement with HomePage widget
              );
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}


  @override
  void dispose() {
    _timer?.cancel();  // Stop the timer when the page is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: Text('Verify Your Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Check your email address and verify your email.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              if (!isVerified)
                CircularProgressIndicator()
              else
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _resendVerificationEmail();
                },
                child: Text('Resend Verification Email'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _resendVerificationEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification email resent. Check your email!'),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }
}
