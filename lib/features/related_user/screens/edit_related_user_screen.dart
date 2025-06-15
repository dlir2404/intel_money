import 'package:flutter/material.dart';
import 'package:intel_money/core/models/related_user.dart';
import 'package:intel_money/shared/helper/toast.dart';

import '../../../shared/helper/validation.dart';
import '../controller/related_user_controller.dart';

class EditRelatedUserScreen extends StatefulWidget {
  final RelatedUser relatedUser;
  const EditRelatedUserScreen({super.key, required this.relatedUser});

  @override
  State<EditRelatedUserScreen> createState() =>
      _CreateRelatedUserScreenState();
}

class _CreateRelatedUserScreenState extends State<EditRelatedUserScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final RelatedUserController _relatedUserController = RelatedUserController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.relatedUser.name;
    _emailController.text = widget.relatedUser.email ?? '';
    _phoneController.text = widget.relatedUser.phone ?? '';
  }

  Future<void> _save() async {
    setState(() {
      _isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      await _relatedUserController.edit(
        old: widget.relatedUser,
        name: _nameController.text,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      );

      if (mounted) {
        AppToast.showSuccess(context, "Đã lưu");
        Navigator.of(context).pop();
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.relatedUser.name),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Tên",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      12.0,
                    ), // Adjust the radius as needed
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập tên";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      12.0,
                    ), // Adjust the radius as needed
                  ),
                ),
                validator: (value) => Validation.validateEmailOptional(value ?? ''),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: "Số điện thoại",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      12.0,
                    ), // Adjust the radius as needed
                  ),
                ),
                validator: (value) => Validation.validatePhoneOptional(value ?? '')
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: _isLoading ? null : _save,
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Lưu"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
