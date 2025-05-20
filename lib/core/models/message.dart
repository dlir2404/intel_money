import 'package:intel_money/core/models/transaction.dart';
import 'package:intel_money/core/state/transaction_state.dart';
import 'package:intel_money/shared/const/enum/message_role.dart';

class Message {
  final MessageRole role;
  final MessageBody body;

  Message({required this.role, required this.body});

  //only for agent
  factory Message.newAgentMessage({
    required String content,
    required List<Transaction> transactions,
  }) {
    return Message(
      role: MessageRole.agent,
      body: AgentMessageBody(content: content, transactions: transactions),
    );
  }

  static List<Message> mockMessages() {
    return [
      Message(
        role: MessageRole.user,
        body: MessageBody(content: "An sáng 10k"),
      ),
      Message(
        role: MessageRole.agent,
        body: AgentMessageBody(
          content: "Too much for a breakfast",
          transactions: [
            TransactionState().transactions.first,
            TransactionState().transactions[1],
          ],
        ),
      ),
    ];
  }
}

class MessageBody {
  final String content;

  MessageBody({required this.content});
}

class AgentMessageBody extends MessageBody {
  final List<Transaction> transactions;

  AgentMessageBody({required super.content, required this.transactions});
}
