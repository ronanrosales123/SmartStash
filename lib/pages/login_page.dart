import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/components/SquareTile.dart';
import 'components/loginbutton.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void signIn() {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 214, 211, 211),
        body: SafeArea(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 70), //spacer
                Icon(
                  Icons.lock,
                  size: 100,
                ),

                SizedBox(height: 60), //spacer

                Padding(
                  //UserName
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextField(
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      fillColor: Colors.grey,
                      filled: true,
                      hintText: 'Enter Username',
                    ),
                  ),
                ),

                SizedBox(height: 10), //spacer

                Padding(
                  //Password
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      fillColor: Colors.grey,
                      filled: true,
                      hintText: 'Passwords',
                    ),
                  ),
                ),

                SizedBox(height: 20), //spacer

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Forgot Password?'),
                    ],
                  ),
                ),

                SizedBox(height: 20), //spacer

                SignInButton(
                  onTap: signIn,
                ),

                SizedBox(height: 20), //spacer

                SquareTile(ImagePath: 'lib/images/apple.png'),
              ],
            ),
          ),
        ));
  }
}
