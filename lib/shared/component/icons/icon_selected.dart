import 'package:flutter/material.dart';

class IconSelected extends StatelessWidget {
  const IconSelected({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
      child: const Icon(Icons.check, color: Colors.white),
    );
  }
}
