import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math';
import 'edit_page.dart';

class TransactionHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              confirmDeleteLogs(
                  context); // Call the delete confirmation function
            },
            icon: Icon(Icons.more_vert),
          ),
        ],
        title: Text('Transaction History'),
        backgroundColor: Colors.grey[850],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('logs')
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
              int lockerNumber = doc['lockerNumber'];

              return InkWell(
                onLongPress: () {
                  showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(100, 200, 100, 100),
                    items: [
                      PopupMenuItem(
                        value: 'Delete',
                        child: Text('Delete'),
                        onTap: () async {
                          bool? confirmCancel = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Delete'),
                                content: Text(
                                    'Do you really want to delete this transaction?'),
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
                            // Logic to delete the transaction
                            await FirebaseFirestore.instance
                                .collection('logs')
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
                      Text('Locker: $lockerNumber'),
                      Text('Phone Number: ${doc['phoneNumber']}'),
                      Text('Tracking Number: ${doc['trackingNumber']}'),
                      Text(
                          'Status: ${isLockerOccupied ? "Completed" : "Cancelled"}'),
                      Text('COD: ${isCOD ? "Yes" : "No"}'),
                      Text('Date: $formattedDate'),
                      if(isLockerOccupied==true)
                        Text('Time Deposited: ${DateFormat('yyyy-MM-dd – kk:mm').format(doc['timeIn'].toDate())}'),
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

Future<void> deleteLogs() async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    // Get the userId
    String userId = user.uid;

    // Query the logs collection for documents that match the userId
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('logs')
        .where('userId', isEqualTo: userId)
        .get();

    // Iterate through each document and delete it
    for (var doc in querySnapshot.docs) {
      await FirebaseFirestore.instance.collection('logs').doc(doc.id).delete();
    }
  }
}

void confirmDeleteLogs(BuildContext context) async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    // Get the userId
    String userId = user.uid;

    // Query the logs collection for documents that match the userId
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('logs')
        .where('userId', isEqualTo: userId)
        .get();

    if (querySnapshot.docs.isEmpty) {
      // Show a dialog if no logs are found
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('No Logs Found'),
            content: Text('There are no logs to delete.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
    } else {
      // If logs are found, show confirmation dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Deletion'),
            content: Text(
                'Are you sure you want to delete all? This action cannot be undone.'),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
              TextButton(
                child: Text('Delete'),
                onPressed: () async {
                  await deleteLogs(); // Call the delete function
                  Navigator.of(context)
                      .pop(); // Close the dialog after deletion
                },
              ),
            ],
          );
        },
      );
    }
  }
}
