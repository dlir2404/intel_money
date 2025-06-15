import 'package:flutter/material.dart';
import 'package:intel_money/core/services/wallet_service.dart';
import 'package:intel_money/core/state/app_state.dart';
import 'package:intel_money/features/wallet/controller/wallet_controller.dart';
import 'package:intel_money/shared/component/input/main_input.dart';
import 'package:intel_money/shared/helper/toast.dart';
import 'package:provider/provider.dart';

import '../../../core/models/app_icon.dart';
import '../../../core/models/wallet.dart';
import '../../../core/services/ad_service.dart';
import '../../../shared/component/input/form_input.dart';
import '../../../shared/const/icons/wallet_icon.dart';

class EditWalletScreen extends StatefulWidget {
  final Wallet wallet;
  const EditWalletScreen({super.key, required this.wallet});

  @override
  State<EditWalletScreen> createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends State<EditWalletScreen> {
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  double initialAmount = 0;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  AppIcon _selectedIcon = WalletIcon.defaultIcon(); // Default icon

  final WalletController _walletController = WalletController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.wallet.name;
    _descriptionController.text = widget.wallet.description ?? '';
    _selectedIcon = widget.wallet.icon;

    // Set initial amount to the wallet's base balance
    initialAmount = widget.wallet.baseBalance;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      isLoading = true;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await _walletController.updateWallet(
        widget.wallet,
        _nameController.text,
        _descriptionController.text,
        _selectedIcon.name,
        initialAmount,
      );
      if (mounted) {
        AdService().showAdIfEligible();

        AppToast.showSuccess(context, "Đã lưu");
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        AppToast.showError(context, error.toString());
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildIconSelector() {
    final icons = WalletIcon.icons;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn biểu tượng ví',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 70,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children:
                icons.map((icon) {
                  final bool isSelected = _selectedIcon == icon;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = icon;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 15),
                      width: 60,
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? icon.color.withOpacity(0.5)
                                : icon.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color:
                              isSelected
                                  ? icon.color.withOpacity(0.8)
                                  : icon.color.withOpacity(0.1),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        icon.icon,
                        color:
                            isSelected
                                ? icon.color
                                : icon.color.withOpacity(0.6),
                        size: 28,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            widget.wallet.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Chỉnh sửa ví',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Chọn biểu tượng, đặt tên và số dư ban đầu cho ví của bạn.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
                const SizedBox(height: 30),

                // Icon selection
                _buildIconSelector(),
                const SizedBox(height: 25),

                const Text(
                  'Tên ví',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 10),
                FormInput(
                  controller: _nameController,
                  placeholder: 'Nhập tên ví của bạn',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tên không được để trống';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Initial amount
                MainInput(
                  initialValue: initialAmount,
                  label: 'Số dư ban đầu',
                  onChanged: (value) {
                    setState(() {
                      initialAmount = value;
                    });
                  },
                ),
                const SizedBox(height: 20),

                FormInput(
                  label: 'Mô tả (tuỳ chọn)',
                  controller: _descriptionController,
                  maxLines: 3,
                  prefixIcon: const Icon(Icons.description),
                ),

                const SizedBox(height: 40),

                // Create button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child:
                        isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'Lưu',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
