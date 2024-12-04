import 'package:SmartStash/pages/forgetpassword_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:SmartStash/pages/components/SquareTile.dart';
import 'package:SmartStash/services/auth_service.dart';
import 'components/loginbutton.dart';
import 'forgetpassword_page.dart'; // Import the ForgotPasswordPage file
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;

  LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPasswordVisible = false;

  void signIn() async {
    // Circular loading bar
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Attempt to sign in
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      User? user = userCredential.user;

      // Check if the email is verified
      if (user != null && user.emailVerified) {
        // Stop the circular loading bar
        Navigator.pop(context);
        // Navigate to the home page or the next page in your app
        Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),  // Use pushReplacement with HomePage widget
              );
      } else {
        // Stop the circular loading bar
        Navigator.pop(context);
        // If the email is not verified, show an error message
        errorMessage('Please verify your email before logging in.');
      }
    } on FirebaseAuthException catch (e) {
      // Stop the circular loading bar
      Navigator.pop(context);
      errorMessage(e.code);
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await AuthService().signInWithGoogle();
      if (googleSignInAccount == null) return null;

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = authResult.user;

      // Check if the email is verified
      if (user != null && user.emailVerified) {
        return user;
      } else {
        errorMessage('Please verify your email before logging in with Google.');
        return null;
      }
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  void errorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        );
      },
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
                Icon(Icons.lock, size: 80),

                SizedBox(height: 60), // Spacer

                Padding(
                  // Email
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
                      hintText: 'Enter Email',
                    ),
                  ),
                ),

                SizedBox(height: 10), // Spacer

                Padding(
                  // Password
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      hintText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10), // Spacer

                // Make the "Forgot Password?" text clickable
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to ForgotPasswordPage when tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ForgotPasswordPage()),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Forgot Password?',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent), // Optional styling
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 10), // Spacer

                // Sign in Button
                SignInButton(
                  onTap: signIn,
                ),

                SizedBox(height: 30), // Spacer

                // Or Continue with text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(thickness: 0.5, color: Colors.grey[800]),
                      ),
                      Text('Or continue with'),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),

                // Logos
                SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google button
                    SquareTile(
                      onTap: () async {
                        // Call signInWithGoogle method
                        User? user = await signInWithGoogle();

                        // Handle the signed-in user as needed
                        if (user != null) {
                          print(
                              "Google Sign-In Successful: ${user.displayName}");
                          Navigator.pushReplacementNamed(context, '/homepage');
                        } else {
                          print("Google Sign-In Failed");
                        }
                      },
                      ImagePath: 'lib/images/googlelogo.png',
                    ),

                    SizedBox(width: 20),

                    SquareTile(
                      onTap: () async {
                        // Call signInWithApple method
                        // ...
                      },
                      ImagePath: 'lib/images/apple.png',
                    ),
                  ],
                ),

                SizedBox(height: 50),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Not a member? '),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        'Register Now',
                        style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold),
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
