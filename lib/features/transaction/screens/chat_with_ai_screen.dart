import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intel_money/core/services/ai_service.dart';
import 'package:intel_money/features/transaction/screens/edit_transaction_screen.dart';
import 'package:intel_money/shared/component/typos/currency_double_text.dart';

import '../../../core/models/message.dart';
import '../../../core/models/transaction.dart';
import '../../../shared/const/enum/message_role.dart';
import '../../../shared/const/enum/transaction_type.dart';
import '../../../shared/helper/app_time.dart';

class ChatWithAiScreen extends StatefulWidget {
  const ChatWithAiScreen({super.key});

  @override
  State<ChatWithAiScreen> createState() => _ChatWithAiScreenState();
}

class _ChatWithAiScreenState extends State<ChatWithAiScreen> {
  final List<Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    // Scroll to the bottom after a short delay to ensure the layout is complete
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildEmptyMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/empty_chat.svg',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 16),
          Text(
            "Bắt đầu tạo ghi chép nào",
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
          ),
          const SizedBox(height: 8),
          const Text(
            "VD: Mua quần áo 200k, cà phê 30k,...",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),

          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildUserMessage(Message message) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(message.body.content),
      ),
    );
  }

  Widget _buildTransaction(Transaction transaction, Message agentMessage) {
    return InkWell(
      onTap: () async {
        final returnData = await Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => EditTransactionScreen(transaction: transaction),
          ),
        );

        if (returnData != null && returnData['removedTransaction'] != null) {
          // Handle transaction removal
          setState(() {
            (agentMessage.body as AgentMessageBody).transactions.remove(
              transaction,
            );
          });
        } else if (returnData != null &&
            returnData['updatedTransaction'] != null) {
          // Handle transaction update
          final updatedTransaction =
              returnData['updatedTransaction'] as Transaction;
          setState(() {
            (agentMessage.body as AgentMessageBody).transactions.remove(
              transaction,
            );
            (agentMessage.body as AgentMessageBody).transactions.add(
              updatedTransaction,
            );
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: transaction.category!.icon.color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    transaction.category!.icon.icon,
                    color: transaction.category!.icon.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.category!.name,
                      style: const TextStyle(fontSize: 15),
                    ),
                    transaction.description != null
                        ? Text(
                          transaction.description!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        )
                        : const SizedBox.shrink(),

                    Text(
                      AppTime.format(time: transaction.transactionDate),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CurrencyDoubleText(
                      value: transaction.amount,
                      color:
                          transaction.type == TransactionType.expense
                              ? Colors.red
                              : Colors.green,
                      fontSize: 14,
                    ),
                    const SizedBox(height: 2),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: transaction.sourceWallet.icon.color
                                .withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            transaction.sourceWallet.icon.icon,
                            color: transaction.sourceWallet.icon.color,
                            size: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          transaction.sourceWallet.name,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                Icon(Icons.edit, color: Colors.grey, size: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentMessage(Message message) {
    final List<Transaction> transactions =
        message.body is AgentMessageBody
            ? (message.body as AgentMessageBody).transactions
            : [];

    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(message.body.content),
          ),
          const SizedBox(height: 4),

          for (var transaction in transactions)
            _buildTransaction(transaction, message),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    if (_messages.isEmpty) {
      return _buildEmptyMessage();
    }

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          const SizedBox(height: 16),
          for (var message in _messages)
            message.role == MessageRole.user
                ? _buildUserMessage(message)
                : _buildAgentMessage(message),
        ],
      ),
    );
  }

  void _addLoadingMessage() {
    setState(() {
      _messages.add(
        Message(
          role: MessageRole.agent,
          body: MessageBody(content: "Đợi chút..."),
        ),
      );
    });
    _scrollToBottom();
  }

  void _addErrorMessage() {
    setState(() {
      _messages.add(
        Message(
          role: MessageRole.agent,
          body: MessageBody(
            content:
                "Cannot detect transaction, please try format: Category + Amount + Time + ...",
          ),
        ),
      );
    });
    _scrollToBottom();
  }

  void _removeLoadingMessage() {
    setState(() {
      _messages.removeLast();
    });
  }

  void _handleSendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();

    setState(() {
      _messages.add(
        Message(role: MessageRole.user, body: MessageBody(content: text)),
      );
    });
    _scrollToBottom();

    _addLoadingMessage();
    _getResponseFromAgent(text);
  }

  Future<void> _getResponseFromAgent(String text) async {
    try {
      Message message = await AIService().registerTransactionFromChat(text);
      _removeLoadingMessage();

      setState(() {
        _messages.add(message);
      });
    } catch (e) {
      _removeLoadingMessage();
      // Handle error
      print(e);

      _addErrorMessage();
    } finally {
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trợ lý ghi chép"),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessages()),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 12.0,
            ),
            child: Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 0,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: 'Ăn sáng 30k, mua sắm 200k, ...',
                    hintStyle: TextStyle(color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.blue),
                      onPressed: () {
                        _handleSendMessage();
                      },
                    ),
                  ),
                  onSubmitted: (value) {
                    _handleSendMessage();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
