import 'package:flutter/material.dart';
import 'package:intel_money/core/state/related_user_state.dart';
import 'package:intel_money/features/related_user/widgets/related_user_item.dart';
import 'package:provider/provider.dart';

import 'create_related_user_screen.dart';

class RelatedUserScreen extends StatefulWidget {
  const RelatedUserScreen({super.key});

  @override
  State<RelatedUserScreen> createState() => _RelatedUserScreenState();
}

class _RelatedUserScreenState extends State<RelatedUserScreen> {
  void _showCreateWalletScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateRelatedUserScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Người vay/cho vay"),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'create_related_user',
            onPressed: () => _showCreateWalletScreen(),
            elevation: 4.0,
            shape: const CircleBorder(),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            child: const Icon(Icons.person_add),
          ),

          const SizedBox(height: 60),
        ],
      ),
      body: Consumer<RelatedUserState>(
        builder: (context, state, _) {
          final relatedUsers = state.relatedUsers;

          if (relatedUsers.isEmpty) {
            return Center(
              child: Text(
                "Chưa có đối tượng nào",
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 16,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                ...relatedUsers.map((item) {
                  return RelatedUserItem(relatedUser: item,);
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
