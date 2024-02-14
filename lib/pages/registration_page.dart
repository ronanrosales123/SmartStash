import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  bool isLoading = false;

  void confirmRegistration() async {
    setState(() {
      isLoading = true; // Start loading
    });

    String phoneNumber = phoneNumberController.text;
    String trackingNumber = trackingNumberController.text;

    if (phoneNumber.isEmpty || trackingNumber.isEmpty || selectedLockerIndex == -1) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please fill in all the fields and select a locker.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      setState(() {
        isLoading = false; // Stop loading
      });
      return;
    }

    if (phoneNumber.length != 11 || !phoneNumber.startsWith('09')) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Wrong phone number format.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      setState(() {
        isLoading = false; // Stop loading
      });
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('registrations').add({
        'phoneNumber': phoneNumber,
        'trackingNumber': trackingNumber,
        'lockerNumber': selectedLockerIndex + 1,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('lockerstatus').doc('vacancy').update({
        'locker${selectedLockerIndex + 1}': true,
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Registration Successful.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pop(); // Go back to the homepage
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to register. Please try again.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }

    setState(() {
      isLoading = false; // Stop loading
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration'),
        backgroundColor: Colors.grey,
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
            SizedBox(height: 32),
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
            isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
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
            List<String> lockerNames = ['locker1', 'locker2', 'locker3', 'locker4', 'locker5', 'locker6'];
            List<bool> lockerStatus = lockerNames.map((name) => data[name] as bool? ?? false).toList();

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
              ),
              itemCount: lockerStatus.length,
              itemBuilder: (context, index) {
                bool isOccupied = lockerStatus[index];
                return InkWell(
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
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Locker ${index + 1} is occupied.'),
                        ),
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isOccupied ? Colors.red : Colors.green,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
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
