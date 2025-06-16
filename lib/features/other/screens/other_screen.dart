import 'package:flutter/material.dart';
import 'package:intel_money/core/config/routes.dart';
import 'package:intel_money/shared/helper/toast.dart';
import 'package:provider/provider.dart';
import 'package:intel_money/core/state/app_state.dart';

import '../../../core/models/user.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/services/auth_service.dart';
import '../../category/screens/category_screen.dart';
import '../../related_user/screens/related_user_screen.dart';
import 'data_setting_screen.dart';
import 'general_setting_screen.dart';

class OtherScreen extends StatelessWidget {
  const OtherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.user;
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header with background
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryColor, primaryColor.withOpacity(0.7)],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: _buildUserProfile(context, user),
              ),

              const SizedBox(height: 20),

              // Section title for functions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Truy cập nhanh",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Function Grid Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildFunctionGrid(context),
              ),

              const SizedBox(height: 24),

              // Section title for settings
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Cài đặt & Hỗ trợ",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Settings List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildSettingsList(context),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context, User? user) {
    return Row(
      children: [
        // Avatar with border
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white.withOpacity(0.3),
            child:
                user?.picture != null
                    ? ClipOval(
                      child: Image.network(
                        user!.picture!,
                        fit: BoxFit.cover,
                        width: 72,
                        height: 72,
                      ),
                    )
                    : const Icon(Icons.person, size: 40, color: Colors.white),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.name ?? 'Guest User',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? 'Not signed in',
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              // Navigate to profile edit screen
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFunctionGrid(BuildContext context) {
    final items = [
      {
        'icon': Icons.category,
        'title': 'Danh mục thu/chi',
        'color': Colors.orange,
        'onTap': (BuildContext context) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CategoryScreen()),
          );
        },
      },
      {
        'icon': Icons.person,
        'title': 'Người vay/cho vay',
        'color': Colors.blue,
        'onTap': (BuildContext context) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const RelatedUserScreen(),
            ),
          );
        },
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildGridItem(context, items[index]);
      },
    );
  }

  Widget _buildGridItem(BuildContext context, dynamic item) {
    final icon = item['icon'] as IconData;
    final title = item['title'] as String;
    final color = item['color'] as Color;
    final onTap = item['onTap'] as Function?;

    return InkWell(
      onTap: () {
        AdService().showAdIfEligible();
        if (onTap != null) {
          onTap(context);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    final settingsItems = [
      {
        'icon': Icons.settings,
        'title': 'Cài đặt chung',
        'color': Colors.blue,
        'onTap': () {
          AdService().showAdIfEligible();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const GeneralSettingScreen(),
            ),
          );
        },
      },
      {
        'icon': Icons.storage,
        'title': 'Cài đặt dữ liệu',
        'color': Colors.green,
        'onTap': () {
          AdService().showAdIfEligible();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const DataSettingScreen(),
            ),
          );
        },
      },
      {
        'icon': Icons.logout,
        'title': 'Đăng xuất',
        'color': Colors.teal,
        'onTap': () {
          AuthService().logout();
          AppRoutes.navigateToLogin(context);
          AppToast.showSuccess(context, "Đăng xuất thành công");
        },
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(settingsItems.length, (index) {
          final item = settingsItems[index];
          final isLast = index == settingsItems.length - 1;

          return Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: item['color'] as Color,
                    size: 22,
                  ),
                ),
                title: Text(
                  item['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                trailing: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey[700],
                  ),
                ),
                onTap: () {
                  (item['onTap'] as Function).call();
                },
              ),
              if (!isLast) const Divider(height: 1, indent: 70),
            ],
          );
        }),
      ),
    );
  }
}
