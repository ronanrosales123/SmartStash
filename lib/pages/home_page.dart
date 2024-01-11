import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'registration_page.dart'; // Import the RegistrationPage file

class HomePage extends StatelessWidget {
  HomePage({Key? key});

  final user = FirebaseAuth.instance.currentUser!;

  // Sign user out
  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  // Navigate to the registration page
  void navigateToRegistration(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistrationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SmartStash'),
        actions: [
          IconButton(onPressed: signOut, icon: Icon(Icons.logout)),
        ],
        backgroundColor: Colors.grey,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Your app logo or branding image here
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/your_logo.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 30),
            // Main menu options with wider buttons
            ElevatedButton(
              onPressed: () => navigateToRegistration(context), // Navigate to RegistrationPage
              style: ElevatedButton.styleFrom(
                primary: Colors.grey, // Change the background color
                onPrimary: Colors.white, // Change the text color
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12), // Adjust padding for width
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.assignment),
                  SizedBox(width: 8),
                  Text('Register Delivery'),
                ],
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Implement the action when 'Transaction Status' is tapped
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.grey, // Change the background color
                onPrimary: Colors.white, // Change the text color
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12), // Adjust padding for width
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.timeline),
                  SizedBox(width: 8),
                  Text('Transaction Status'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
