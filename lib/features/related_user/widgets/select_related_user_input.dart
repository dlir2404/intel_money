import 'package:flutter/material.dart';

import '../../../core/models/related_user.dart';
import '../screens/select_related_user_screen.dart';

class SelectRelatedUserInput extends StatefulWidget {
  final String placeholder;
  final Function(RelatedUser?) onRelatedUserSelected;

  const SelectRelatedUserInput({
    super.key,
    required this.placeholder,
    required this.onRelatedUserSelected,
  });

  @override
  State<SelectRelatedUserInput> createState() => _SelectRelatedUserInputState();
}

class _SelectRelatedUserInputState extends State<SelectRelatedUserInput> {
  RelatedUser? _relatedUser;

  @override
  void initState() {
    super.initState();
    _relatedUser = null;
  }

  void _navigateToSelectRelatedUser() async {
    final selectedRelatedUser = await Navigator.push<RelatedUser>(
      context,
      MaterialPageRoute(
        builder:
            (context) => SelectRelatedUserScreen(
              selectedRelatedUser: _relatedUser,
              title: widget.placeholder,
            ),
      ),
    );

    setState(() {
      _relatedUser = selectedRelatedUser;
      widget.onRelatedUserSelected(_relatedUser);
    });
  }

  Widget _buildSelectedItem(RelatedUser relatedUser) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            relatedUser.name,
            style: TextStyle(color: Colors.black),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () {
              setState(() {
                _relatedUser = null;
                widget.onRelatedUserSelected(null);
              });
            },
            child: const Icon(
              Icons.clear,
              color: Colors.grey,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _navigateToSelectRelatedUser,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: Colors.grey, size: 24),
            ),
            const SizedBox(width: 10),

            _relatedUser != null
                ? _buildSelectedItem(_relatedUser!)
                : Text(
                  widget.placeholder,
                  style: TextStyle(color: Colors.grey),
                ),
            Expanded(child: const SizedBox()),

            Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
