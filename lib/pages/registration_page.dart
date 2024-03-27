import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(MaterialApp(
    home: RegistrationPage(),
  ));
}

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController trackingNumberController = TextEditingController();
  int selectedLockerIndex = -1;
  bool isCOD = false; // Initial value for the COD toggle

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

void confirmRegistration() async {
  String phoneNumber = phoneNumberController.text;
  String trackingNumber = trackingNumberController.text;
  User? user = FirebaseAuth.instance.currentUser;

  // Check for empty fields and locker selection
  if (phoneNumber.isEmpty || trackingNumber.isEmpty || selectedLockerIndex == -1) {
    _showErrorDialog('Please fill in all the fields and select a locker.');
    return;
  }

  // Check phone number format
  if (phoneNumber.length != 11 || !phoneNumber.startsWith('09')) {
    _showErrorDialog('Wrong phone number format.');
    return;
  }

  // Confirmation dialog
  bool confirm = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm Registration'),
        content: Text('Are you sure the details are correct?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),
        ],
      );
    },
  ) ?? false;

  // If the user does not confirm, just return
  if (!confirm) return;

  // Show loading indicator after confirmation
  showLoadingIndicator(context, isLoading: true);

  try {
    // Perform registration
    await FirebaseFirestore.instance.collection('registrations').add({
      'userId': user!.uid,
      'phoneNumber': phoneNumber,
      'trackingNumber': trackingNumber,
      'lockerNumber': selectedLockerIndex + 1,
      'timestamp': FieldValue.serverTimestamp(),
      'status': false,
      'cod': isCOD,
    });

    await FirebaseFirestore.instance.collection('lockerstatus').doc('vacancy').update({
      'locker${selectedLockerIndex + 1}': true,
    });

    // Hide loading indicator before showing the success dialog
    showLoadingIndicator(context, isLoading: false);

    // Success dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Registration Successful.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close success dialog
                Navigator.of(context).pop(); // Go back to the previous screen
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  } catch (e) {
    // Hide loading indicator before showing the error dialog
    showLoadingIndicator(context, isLoading: false);
    _showErrorDialog('Failed to register. Please try again.');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration'),
        backgroundColor: Colors.grey[850],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen (main menu)
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: phoneNumberController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
                hintText: '09########',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: trackingNumberController,
              decoration: InputDecoration(
                labelText: 'Tracking Number',
                prefixIcon: Icon(Icons.assignment),
              ),
            ),
            SizedBox(height: 16),

            SwitchListTile(
              title: Text('Cash on Delivery'),
              value: isCOD,
              onChanged: (bool value) {
                setState(() {
                  isCOD = value;
                });
              },
              secondary: Icon(isCOD ? Icons.money : Icons.money_off),
            ),

            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.grey,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LockerSelectionPage(),
                  ),
                ).then((selectedLocker) {
                  if (selectedLocker != null) {
                    setState(() {
                      selectedLockerIndex = selectedLocker;
                    });
                  }
                });
              },
              child: Text('Select Locker'),
            ),
            SizedBox(height: 16),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.grey,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: selectedLockerIndex != -1 ? confirmRegistration : null,
              child: Text('Confirm Registration'),
            ),
          ],
        ),
      ),
    );
  }
}

class LockerSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Locker'),
        backgroundColor: Colors.grey,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('lockerstatus').doc('vacancy').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
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

          if (snapshot.hasData && snapshot.data!.exists) {
            Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
            List<String> lockerNames = ['locker1', 'locker2', 'locker3', 'locker4', 'locker5', 'locker6']; // Rearranged
            List<bool> lockerStatus = lockerNames.map((name) => data[name] as bool? ?? false).toList();

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two columns
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
              ),
              itemCount: lockerStatus.length,
              itemBuilder: (context, index) {
                bool isOccupied = lockerStatus[index];
                return Card(
                  elevation: 5, // Add shadow
                  color: isOccupied ? Colors.red[300] : Colors.green[300], // Subtle shades
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: InkWell(
                    onTap: () {
                            if (!isOccupied) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Locker Selected'),
                              content: Text('You selected Locker ${index + 1}.'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close the dialog
                                    Navigator.pop(context, index); // Pass selected locker index back to previous screen
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Locker Unavailable'),
                              content: Text('Locker ${index + 1} is occupied. Please choose a different locker.'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(), // Dismiss the dialog
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(10.0), // Match the border radius of the Card
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isOccupied ? Icons.lock : Icons.lock_open,
                            color: Colors.white,
                            size: 36.0,
                          ),
                          Text(
                            'Locker ${index + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Text('No lockers available'),
            );
          }
        },
      ),
    );
  }
}

// Method to control the loading indicator
void showLoadingIndicator(BuildContext context, {required bool isLoading}) {
  if (isLoading) {
    // Showing the loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  } else {
    // Dismissing the loading indicator if it's shown
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}

