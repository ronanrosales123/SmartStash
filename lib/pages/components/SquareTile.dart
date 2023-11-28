import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {
  final String ImagePath;
  const SquareTile({super.key, required this.ImagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.asset(ImagePath),
    );
  }
}
