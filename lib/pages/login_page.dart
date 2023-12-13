import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/components/SquareTile.dart';
import 'components/loginbutton.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signIn() async {
    // Circular loading bar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            CircularProgressIndicator(),
            Text("Signing in..."),
          ],
        ),
        duration: Duration(minutes: 5), // Adjust the duration as needed
      ),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Stop the circular loading bar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    } on FirebaseAuthException catch (e) {
      // Stop the circular loading bar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Wrong email
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Incorrect Email'),
          ),
        );
      }

      // Wrong password
      else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Incorrect Password'),
          ),
        );
      }
    }
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
                SizedBox(height: 60), //spacer
                SquareTile(ImagePath: 'lib/images/lockerlogo.jpg'),

                SizedBox(height: 60), //spacer

                Padding(
                  //UserName
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

                SizedBox(height: 10), //spacer

                Padding(
                  //Password
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
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
                    ),
                  ),
                ),

                SizedBox(height: 10), //spacer

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Forgot Password?'),
                    ],
                  ),
                ),

                SizedBox(height: 10), //spacer

                //Sign in Button
                SignInButton(
                  onTap: signIn,
                ),

                SizedBox(height: 30), //spacer

                //or Continue with text
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

                //Logos
                SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //google button
                    SquareTile(ImagePath: 'lib/images/apple.png'),

                    SizedBox(
                      width: 20,
                    ),

                    SquareTile(ImagePath: 'lib/images/googlelogo.png'),
                  ],
                ),

                SizedBox(height: 50),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Not a member? '),
                    Text(
                      'Register Now',
                      style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold),
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
