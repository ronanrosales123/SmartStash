// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/components/SquareTile.dart';
import 'components/signupbutton.dart';

class SignUpPage extends StatelessWidget {
  @override
  void register() {}

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 214, 211, 211),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                height: 60,
              ),

              SquareTile(ImagePath: 'lib/images/lockerlogo.jpg'), //logo for app

              SizedBox(
                height: 60,
              ),

              //Input desired User Name
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: TextField(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'Enter Username',
                  ),
                ),
              ),

              SizedBox(
                height: 10,
              ),

              //Input Password
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: TextField(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'Input Password',
                  ),
                ),
              ),

              //Input Number
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: TextField(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'Input Number',
                  ),
                ),
              ),

              SizedBox(
                height: 30,
              ),

              SignUpButton(onTap: register),
            ]),
          ),
        ),
      ),
    );
  }
}
