import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  ForgetPasswordPageState createState() => ForgetPasswordPageState();
}

class ForgetPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  bool isLoading = false;

  void resetPassword() async {
    String email = emailController.text;

    if (email.isEmpty) {
      showError('Please enter your email address');
      return;
    }

    setState(() {
      isLoading = true; // Start loading
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showSuccess('Password reset email sent! Check your inbox.');
      Navigator.pop(context); // Go back to login page after sending email
    } on FirebaseAuthException catch (e) {
      showError(e.message ?? 'Something went wrong. Please try again.');
    } finally {
      setState(() {
        isLoading = false; // Stop loading
      });
    }
  }

  void showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        );
      },
    );
  }

  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 214, 211, 211),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 60), // Spacer
                Icon(Icons.lock_reset, size: 80),

                SizedBox(height: 60), // Spacer

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      hintText: 'Enter your email address',
                    ),
                  ),
                ),

                SizedBox(height: 10), // Spacer

                SizedBox(height: 20), // Spacer

                // Reset Password Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey[600],
                    onPrimary: Colors.white,
                  ),
                  onPressed: isLoading ? null : resetPassword,
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Send Reset Email'),
                ),

                SizedBox(height: 20), // Spacer

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Remember your password? '),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Go back to login page
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
