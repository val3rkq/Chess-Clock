import 'package:flutter/material.dart';

class MainButton extends StatelessWidget {
  const MainButton({
    super.key,
    required this.icon,
    required this.size,
  });

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.black,
      ),
      width: 100,
      height: 100,
      child: Icon(
        icon,
        color: Colors.white,
        size: size,
      ),
    );
  }
}