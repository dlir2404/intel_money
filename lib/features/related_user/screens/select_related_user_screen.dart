import 'package:flutter/material.dart';
import 'package:intel_money/core/models/related_user.dart';
import 'package:intel_money/core/state/related_user_state.dart';
import 'package:provider/provider.dart';

class SelectRelatedUserScreen extends StatefulWidget {
  final RelatedUser? selectedRelatedUser;
  final String title;

  const SelectRelatedUserScreen({
    super.key,
    this.selectedRelatedUser,
    required this.title,
  });

  @override
  State<SelectRelatedUserScreen> createState() =>
      _SelectRelatedUserScreenState();
}

class _SelectRelatedUserScreenState extends State<SelectRelatedUserScreen> {
  final TextEditingController _searchController = TextEditingController();

  void _selectNewTempRelatedUser(){
    RelatedUser temp = RelatedUser.newTemporaryUser(
      _searchController.text,
    );

    Navigator.pop(context, temp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.check), onPressed: () => _selectNewTempRelatedUser())],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 0,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Select or enter person's name",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (value) {
                  // Implement search functionality here
                },
              ),
            ),
          ),
          Expanded(
            // Wrap with Expanded to give ListView remaining space
            child: Consumer<RelatedUserState>(
              builder: (context, state, _) {
                final relatedUsers = state.relatedUsers;

                return RefreshIndicator(
                  onRefresh: () async {
                    // await RelatedUserService().getRelatedUsers();
                  },
                  child: ListView.builder(
                    itemCount: relatedUsers.length,
                    itemBuilder: (context, index) {
                      final relatedUser = relatedUsers[index];
                      return ListTile(
                        title: Text(relatedUser.name),
                        onTap: () {
                          Navigator.pop(context, relatedUser);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
