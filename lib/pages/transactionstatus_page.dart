import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Correct import for DateFormat

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
        stream: FirebaseFirestore.instance.collection('registrations').where('userId', isEqualTo: user!.uid).snapshots(),
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
              var formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(doc['timestamp'].toDate());

              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                margin: EdgeInsets.all(8.0),
                padding: EdgeInsets.all(16.0),
                child: IntrinsicHeight(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Locker: ${doc['lockerNumber']}'),
                            Text('Phone Number: ${doc['phoneNumber']}'),
                            Text('Tracking Number: ${doc['trackingNumber']}'),
                          ],
                        ),
                      ),
                      VerticalDivider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                      Expanded(
                        flex: 1,
                        child: Text('Date: $formattedDate', textAlign: TextAlign.right),
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
