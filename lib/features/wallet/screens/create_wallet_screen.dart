import 'package:flutter/material.dart';
import 'package:intel_money/shared/component/input/main_input.dart';

class CreateWalletScreen extends StatefulWidget {
  const CreateWalletScreen({Key? key}) : super(key: key);

  @override
  State<CreateWalletScreen> createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends State<CreateWalletScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Wallet'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Wallet Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            MainInput(
              label: 'Initial Amount',
              hint: 'Enter initial amount',
              controller: _amountController,
              currency: '\$',
              onChanged: (value) {
                // Handle amount changes if needed
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _createWallet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Create Wallet', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createWallet() {
    // Validate inputs
    if (_nameController.text.isEmpty) {
      _showErrorMessage('Please enter a wallet name');
      return;
    }

    if (_amountController.text.isEmpty) {
      _showErrorMessage('Please enter an initial amount');
      return;
    }

    // Here you would typically:
    // 1. Process the wallet creation
    // 2. Save to database/storage
    // 3. Navigate back or to another screen

    // Example implementation:
    double initialAmount = double.tryParse(_amountController.text) ?? 0;

    // Print wallet details (for debugging)
    print('Creating wallet:');
    print('Name: ${_nameController.text}');
    print('Initial Amount: $initialAmount');
    print('Description: ${_descriptionController.text}');

    // Show success message and navigate back
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Wallet created successfully!')),
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context);
    });
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}