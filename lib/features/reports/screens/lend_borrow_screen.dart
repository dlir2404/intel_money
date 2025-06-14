import 'package:flutter/material.dart';

import '../widgets/lend_tab.dart';

class LendBorrowScreen extends StatefulWidget {
  const LendBorrowScreen({super.key});

  @override
  State<LendBorrowScreen> createState() => _LendBorrowScreenState();
}

class _LendBorrowScreenState extends State<LendBorrowScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Theo dõi vay nợ"),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: const [Tab(text: 'Cho vay'), Tab(text: 'Còn nợ')],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                LendTab(),
                Center(child: Text("Danh sách còn nợ")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
