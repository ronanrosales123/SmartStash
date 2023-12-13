import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/components/SquareTile.dart';

class HomePage extends StatelessWidget {
HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

//sign user out
  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [IconButton(onPressed: signOut, icon: Icon(Icons.logout))],
        backgroundColor: Colors.grey,
      ),
      body: Center(child: Text("Logged In")),
    );
  }
}
