
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
