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
  late final List<RelatedUser> _relatedUser;
  List<RelatedUser> _filteredRelatedUser = [];

  @override
  void initState() {
    super.initState();
    final state = Provider.of<RelatedUserState>(context, listen: false);
    _relatedUser = state.relatedUsers;
    _filteredRelatedUser = _relatedUser;
  }

  void _selectNewTempRelatedUser() {
    RelatedUser temp = RelatedUser.newTemporaryUser(_searchController.text);

    Navigator.pop(context, temp);
  }

  Widget _buildSearchInput() {
    return Padding(
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
            setState(() {
              _filteredRelatedUser =
                  _relatedUser
                      .where(
                        (user) => user.name.toLowerCase().contains(
                          value.toLowerCase(),
                        ),
                      )
                      .toList();
            });
          },
        ),
      ),
    );
  }

  Widget _buildListRelatedUser() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        children: [
          ..._filteredRelatedUser.map((item) {
            return Column(
              children: [
                Container(
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
                  child: ListTile(
                    title: Text(item.name),
                    onTap: () {
                      Navigator.pop(context, item);
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => _selectNewTempRelatedUser(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchInput(),

          Expanded(
            child: _buildListRelatedUser(),
          ),
        ],
      ),
    );
  }
}
