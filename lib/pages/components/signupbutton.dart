import 'package:flutter/material.dart';

class SignUpButton extends StatelessWidget {
  final Function()? onTap;

  const SignUpButton({super.key, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.black, borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 25.0),
        padding: const EdgeInsets.all(25.0),
        child: const Center(
            child: Text(
          'Sign Up',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        )),
      ),
    );
  }
}
