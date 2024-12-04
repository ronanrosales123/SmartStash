import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math';

import 'edit_page.dart';

class TransactionStatusPage extends StatefulWidget {
  @override
  State<TransactionStatusPage> createState() => _TransactionStatusPageState();
}

class _TransactionStatusPageState extends State<TransactionStatusPage> {
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
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var formattedDate = DateFormat('yyyy-MM-dd – kk:mm')
                  .format(doc['timestamp'].toDate());
              bool isLockerOccupied = doc['status'] ?? false;
              bool isCOD = doc['cod'] ?? false;
              bool isComplete = doc['completeFlag'] ?? false;
              int lockerNumber = doc['lockerNumber'];

              return InkWell(
                onLongPress: () {
                  showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(100, 200, 100, 100),
                    items: [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => EditTransactionPage(
                              docId: doc.id,
                              initialPhoneNumber: doc['phoneNumber'],
                              initialTrackingNumber: doc['trackingNumber'],
                            ),
                          ));
                        },
                      ),
                      PopupMenuItem(
                        value: 'cancel',
                        child: Text('Cancel'),
                        onTap: () async {
                          bool? confirmCancel = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Cancel Transaction'),
                                content: Text(
                                    'Do you really want to cancel this transaction?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('Yes'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                  ),
                                  TextButton(
                                    child: Text('No'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirmCancel == true) {
                            await FirebaseFirestore.instance
                                .collection('lockerstatus')
                                .doc('vacancy')
                                .update({
                              'locker$lockerNumber': false,
                            });

                            // Logic to delete the transaction
                            await FirebaseFirestore.instance
                                .collection('registrations')
                                .doc(doc.id)
                                .delete();
                          }
                        },
                      ),
                    ],
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  margin: EdgeInsets.all(8.0),
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (isComplete== false)
                        Text('Locker: $lockerNumber'),
                      Text('Phone Number: ${doc['phoneNumber']}'),
                      Text('Tracking Number: ${doc['trackingNumber']}'),
                      if (isComplete== false)
                        Text('Status: ${isLockerOccupied ? "In Locker" : "Not in Locker"}'),
                      if (isComplete==true)
                        Text('Status: Claimed'),
                      Text('COD: ${isCOD ? "Yes" : "No"}'),
                      Text('Date: $formattedDate'),
                      if ( (isComplete | isLockerOccupied) && doc['timeIn'] != null)
                        Text('Time Deposited: ${DateFormat('yyyy-MM-dd – kk:mm').format(doc['timeIn'].toDate())}'),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          if (isCOD && !isLockerOccupied && !isComplete)
                            ElevatedButton(
                              onPressed: () =>
                                  depositMoney(context, lockerNumber, doc.id),
                              child: Text('Deposit Money'),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.orange,
                              ),
                            ),
                          SizedBox(width: 8),
                          if (isLockerOccupied && !isComplete)
                            ElevatedButton(
                              onPressed: () =>
                                  claimPackage(context, doc.id, lockerNumber),
                              child: Text('Claim'),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.blue
                              ),
                            ),
                          SizedBox(width: 8),
                          if (isComplete && !isLockerOccupied)
                            ElevatedButton(
                              onPressed: () =>
                                  clear(context, doc.id, lockerNumber),
                              child: Text('Clear'),
                              style: ElevatedButton.styleFrom(
                                primary:Colors.blue,
                              ),
                            ),                         
                        ],
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
}

void claimPackage(BuildContext context, String docId, int lockerNumber) async {
  // Show a loading dialog
  showDialog(
    context: context,
    barrierDismissible:
        false, // User must not dismiss the dialog by tapping outside of it
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
  await FirebaseFirestore.instance
      .collection('registrations')
      .doc(docId)
      .update({
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
            data: claimToken,
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

void depositMoney(BuildContext context, int lockerNumber, String docId) async {
  // Show a loading dialog
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text("Generating Deposit Token..."),
            ],
          ),
        ),
      );
    },
  );

  // Generate a unique deposit token
  String depositToken = generateClaimToken();

  // Update the document with the deposit token
  await FirebaseFirestore.instance
      .collection('registrations')
      .doc(docId)
      .update({
    'depositToken': depositToken,
  });

  // Dismiss the loading dialog
  Navigator.of(context).pop();

  // Display the QR code containing the deposit token
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Deposit QR Code'),
        content: SizedBox(
          width: 200,
          height: 200,
          child: QrImageView(
            data: depositToken,
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

  const chars =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  for (int i = 0; i < length; i++) {
    buffer.write(chars[random.nextInt(chars.length)]);
  }

  return buffer.toString();
}

void clear(BuildContext context, String docId, int lockerNumber) async {
  
  DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
                  .collection('registrations')
                  .doc(docId)
                  .get();

              // Save the data to the 'logs' collection
              await FirebaseFirestore.instance
                  .collection('logs')
                  .add(docSnapshot.data() as Map<String, dynamic>);

              // Delete the transaction document after updating the vacancy
              await FirebaseFirestore.instance
                  .collection('registrations')
                  .doc(docId)
                  .delete();
}