import 'package:flutter/material.dart';

class HomeSection extends StatelessWidget {
  final String title;
  final bool showSettings;
  final Widget child;

  const HomeSection({
    super.key,
    required this.title,
    this.showSettings = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
          ),
          const SizedBox(height: 16),

          child,
        ],
      ),
    );
  }
}
