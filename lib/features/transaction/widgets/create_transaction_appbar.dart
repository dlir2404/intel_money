import 'package:flutter/material.dart';

import '../../../shared/const/enum/category_type.dart';

class CreateTransactionAppbar extends StatefulWidget
    implements PreferredSizeWidget {
  final CategoryType selectedCategoryType;
  final Function(CategoryType categoryType) onCategoryTypeChanged;
  final bool isLoading;
  final Function() onSave;

  const CreateTransactionAppbar({
    super.key,
    required this.selectedCategoryType,
    required this.onCategoryTypeChanged,
    required this.isLoading,
    required this.onSave,
  });

  @override
  State<CreateTransactionAppbar> createState() =>
      _CreateTransactionAppbarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CreateTransactionAppbarState extends State<CreateTransactionAppbar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      title: Center(
        child: TextButton(
          style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            ),
            backgroundColor: MaterialStateProperty.all<Color>(
              Colors.white.withOpacity(0.1),
            ),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
                side: BorderSide(color: Colors.transparent),
              ),
            ),
          ),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return ListView(
                  children:
                      CategoryType.values.map((categoryType) {
                        return ListTile(
                          title: Text(categoryType.name),
                          onTap: () {
                            widget.onCategoryTypeChanged(categoryType);
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                );
              },
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.selectedCategoryType == CategoryType.expense
                    ? 'Expense'
                    : 'Income',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.white),
            ],
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.history),
        onPressed: () {
          //navigate to transaction history
        },
      ),
      actions: [
        widget.isLoading
            ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2.0,
              ),
            )
            : IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                widget.onSave();
              },
            ),
      ],
    );
  }
}
