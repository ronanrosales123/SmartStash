import 'package:SmartStash/pages/login_or_registerpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'registration_page.dart'; // Import the RegistrationPage file
import 'transactionstatus_page.dart'; 
import 'transactionhistory_page.dart'; // Import the TransactionStatusPage file
import 'login_page.dart'; // Import the LoginPage file

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final user = FirebaseAuth.instance.currentUser!;

  

  // Sign user out and navigate to LoginPage
  void signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate to LoginPage after signing out
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginOrRegisterPage()),
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Navigate to the registration page
  void navigateToRegistration(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistrationPage()),
    );
  }

  // Navigate to the transaction status page
  void navigateToTransactionStatus(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TransactionStatusPage()),
    );
  }

  // Navigate to the transaction history page
  void navigateToTransactionHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TransactionHistoryPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SmartStash'),
        actions: [
          IconButton(
            onPressed: () => signOut(context), // Pass context to signOut
            icon: Icon(Icons.logout),
          ),
        ],
        backgroundColor: Colors.grey[850], // Darker shade of grey for AppBar
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0), // Horizontal padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch, // Buttons stretch to full width
          children: <Widget>[
            // Your app logo or branding image here
            Image.asset(
              'lib/images/your_logo.png',
              width: 300, // Adjust size as needed
              height: 300,
            ),
            SizedBox(height: 48), // More space between the logo and buttons
            // Main menu options with full-width buttons
            ElevatedButton(
              onPressed: () => navigateToRegistration(context), // Navigate to RegistrationPage
              style: ElevatedButton.styleFrom(
                primary: Colors.grey[600], // Consistent grey color for buttons
                onPrimary: Colors.white, // Text color
                padding: EdgeInsets.symmetric(vertical: 16), // Taller buttons
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: TextStyle(fontSize: 18), // Larger text
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.assignment, size: 24), // Icon size increased for visibility
                  SizedBox(width: 10), // Space between icon and text
                  Text('Register Delivery'),
                ],
              ),
            ),
            SizedBox(height: 24), // Space between buttons
            ElevatedButton(
              onPressed: () => navigateToTransactionStatus(context), // Navigate to TransactionStatusPage
              style: ElevatedButton.styleFrom(
                primary: Colors.grey[600],
                onPrimary: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timeline, size: 24),
                  SizedBox(width: 10),
                  Text('Transaction Status'),
                ],
              ),
            ),
            SizedBox(height: 24), // Space between buttons
            ElevatedButton(
              onPressed: () => navigateToTransactionHistory(context), // Navigate to TransactionHistoryPage
              style: ElevatedButton.styleFrom(
                primary: Colors.grey[600],
                onPrimary: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timeline, size: 24),
                  SizedBox(width: 10),
                  Text('Transaction History'),
                ],
              ),
            ),
            // Add more buttons or content here if needed
          ],
        ),
      ),
    );
  }
}
