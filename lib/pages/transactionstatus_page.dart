import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math';

class TransactionStatusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Status'),
        backgroundColor: Colors.grey[850],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('registrations')
            .where('userId', isEqualTo: user!.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var formattedDate = DateFormat('yyyy-MM-dd – kk:mm')
                  .format(doc['timestamp'].toDate());
              var statusText = doc['status'] ? "In Locker" : "Not in Locker";
              var canClaim = doc['status'];

              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                margin: EdgeInsets.all(8.0),
                padding: EdgeInsets.all(16.0),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Locker: ${doc['lockerNumber']}'),
                            Text('Phone Number: ${doc['phoneNumber']}'),
                            Text('Tracking Number: ${doc['trackingNumber']}'),
                            Text('Status: $statusText'),
                          ],
                        ),
                      ),
                      VerticalDivider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text('Date: $formattedDate',
                                textAlign: TextAlign.right),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: canClaim
                                  ? () => claimPackage(context, doc.id,
                                      doc['lockerNumber']) // Pass lockerNumber as an argument
                                  : null,
                              child: Text('Claim'),
                              style: ElevatedButton.styleFrom(
                                primary: canClaim ? Colors.blue : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void claimPackage(BuildContext context, String docId, int lockerNumber) async {
    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false, // User must not dismiss the dialog by tapping outside of it
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text("Generating QR Code..."),
              ],
            ),
          ),
        );
      },
    );

    // Generate a unique claim token
    String claimToken = generateClaimToken();

    // Update the document with the claim token
    await FirebaseFirestore.instance.collection('registrations').doc(docId).update({
      'claimToken': claimToken,
    });

    // Dismiss the loading dialog
    Navigator.of(context).pop();

    // Display the QR code containing the claim token
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Claim QR Code'),
          content: SizedBox(
            width: 200,
            height: 200,
            child: QrImageView(
              data: claimToken, // Use the claimToken directly
              version: QrVersions.auto,
              size: 200.0,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String generateClaimToken() {
    const length = 10;
    final buffer = StringBuffer();
    final random = Random.secure();

    const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    for (int i = 0; i < length; i++) {
      buffer.write(chars[random.nextInt(chars.length)]);
    }
    
    return buffer.toString();
  }

}
