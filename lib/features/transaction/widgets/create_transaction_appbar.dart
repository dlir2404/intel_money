import 'package:flutter/material.dart';
import 'package:intel_money/shared/const/enum/transaction_type.dart';

import '../../../core/config/routes.dart';
import '../../../shared/const/enum/category_type.dart';

class CreateTransactionAppbar extends StatefulWidget
    implements PreferredSizeWidget {
  final TransactionType selectedTransactionType;
  final Function(TransactionType transactionType) onTransactionTypeChanged;
  final bool isLoading;
  final Function() onSave;

  const   CreateTransactionAppbar({
    super.key,
    required this.selectedTransactionType,
    required this.onTransactionTypeChanged,
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
  void _showChooseTransactionTypeBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(top: 16.0), // Add top padding
          child: Wrap(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min, // Adjust height to fit children
                children:
                    TransactionType.values.map((transactionType) {
                      final isLast =
                          transactionType == TransactionType.values.last;
                      return Column(
                        children: [
                          ListTile(
                            title: Text(transactionType.name),
                            onTap: () {
                              widget.onTransactionTypeChanged(transactionType);
                              Navigator.pop(context);
                            },
                            leading: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: ShapeDecoration(
                                shape: const CircleBorder(),
                                color: transactionType.color,
                              ),
                              child: Icon(
                                transactionType.icon,
                                color: Colors.white,
                              ),
                            ),
                            trailing:
                                transactionType ==
                                        widget.selectedTransactionType
                                    ? const Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    )
                                    : null,
                          ),
                          !isLast ? const Divider() : const SizedBox(height: 8),
                          // Add divider only if not the last item
                        ],
                      );
                    }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

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
          onPressed: () => _showChooseTransactionTypeBottomSheet(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.selectedTransactionType.name,
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
          AppRoutes.navigateToTransactionHistory(context);
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
