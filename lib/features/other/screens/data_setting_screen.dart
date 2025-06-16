import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/config/routes.dart';
import '../../../core/services/user_service.dart';
import '../../../shared/helper/toast.dart';
import '../widgets/general_setting_group.dart';

class DataSettingScreen extends StatelessWidget {
  const DataSettingScreen({super.key});

  Future<void> _resetData(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc muốn xóa tất cả dữ liệu về ban đầu? Không thể hoàn tác.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await UserService().resetData();
        AppToast.showSuccess(context, "Thành công");
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      } catch (error) {
        AppToast.showError(context, error.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Center(
          child: const Text(
            'Cài đặt dữ liệu',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
          ),
        ),
        actions: [const SizedBox(width: 50)],
      ),
      body: Column(
        children: [
          GeneralSettingGroup(
            title: "Dữ liệu",
            widgets: [
              InkWell(
                onTap: () => _resetData(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.delete, color: Colors.grey),
                      const SizedBox(width: 16),
                      Text("Xoá dữ liệu"),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Container(color: Colors.grey[300], height: 0.5),
        ],
      ),
    );
  }
}
