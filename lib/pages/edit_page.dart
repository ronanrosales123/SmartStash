
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditTransactionPage extends StatefulWidget {
  final String docId;
  final String initialPhoneNumber;
  final String initialTrackingNumber;

  const EditTransactionPage({
    Key? key,
    required this.docId,
    required this.initialPhoneNumber,
    required this.initialTrackingNumber,
  }) : super(key: key);

  
  @override
  _EditTransactionPageState createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends State<EditTransactionPage> {
  late TextEditingController _phoneNumberController;
  late TextEditingController _trackingNumberController;

    // Helper method to show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close error dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

    // Method to check the tracking number pattern
  bool isValidTrackingNumber(String trackingNumber) {
    // Example pattern: Alphanumeric, 10-20 characters long
    // Adjust this pattern according to the specific requirements of your tracking numbers
    String pattern = r'^(SPEPH\d{12}|PH(\d{12}[A-Za-z]|\d{13})|\d{12})$';
    return RegExp(pattern).hasMatch(trackingNumber);
  }

  

  @override
  void initState() {
    super.initState();
    _phoneNumberController = TextEditingController(text: widget.initialPhoneNumber);
    _trackingNumberController = TextEditingController(text: widget.initialTrackingNumber);
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _trackingNumberController.dispose();
    super.dispose();
  }

 void _updateTransaction() async {
  bool isUniqueTrackingNumber = await checkTrackingNumberUnique(
    _trackingNumberController.text,
    widget.docId, // Pass the current document ID
  );

  if (!isUniqueTrackingNumber) {
    _showErrorDialog('Tracking number already registered. Please use a unique tracking number.');
    return;
  }

  // Check tracking number format using pattern recognition
  if (!isValidTrackingNumber(_trackingNumberController.text)) {
    _showErrorDialog('Invalid tracking number.');
    return;
  }

  // Update the transaction in Firestore
  await FirebaseFirestore.instance.collection('registrations').doc(widget.docId).update({
    'phoneNumber': _phoneNumberController.text,
    'trackingNumber': _trackingNumberController.text,
  });

  // Navigate back to the previous screen
  Navigator.of(context).pop();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Transaction'),
        backgroundColor: Colors.grey[850],
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _updateTransaction,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _trackingNumberController,
              decoration: InputDecoration(labelText: 'Tracking Number'),
            ),
          ],
        ),
      ),
    );
  }
}

  // Function to check if the tracking number is unique
Future<bool> checkTrackingNumberUnique(String trackingNumber, String docId) async {
  try {
    // Query Firestore for documents with the same tracking number
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('registrations') // Replace with your collection name
        .where('trackingNumber', isEqualTo: trackingNumber)
        .get();

    // Filter out the current document using its docId
    bool isDuplicate = snapshot.docs.any((doc) => doc.id != docId);

    // If there are no duplicates, the tracking number is unique
    return !isDuplicate;
  } catch (e) {
    print('Error checking tracking number uniqueness: $e');
    return false; // Consider tracking number not unique if there's an error
  }
}


        // Method to check the tracking number pattern
    bool isValidTrackingNumber(String trackingNumber) {
      // Example pattern: Alphanumeric, 10-20 characters long
      // Adjust this pattern according to the specific requirements of your tracking numbers
      String pattern = r'^(SPEPH\d{12}|PH(\d{12}[A-Za-z]|\d{13})|\d{12})$';
      return RegExp(pattern).hasMatch(trackingNumber);
    }