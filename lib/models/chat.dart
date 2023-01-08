import 'message.dart';

class Chat {
  final int id;
  final String name;
  final String? description;
  final List<Message> messages;
  final DateTime createdOn;
  final DateTime updatedOn;

  const Chat({
    required this.id,
    required this.createdOn,
    required this.updatedOn,
    required this.messages,
    required this.name,
    this.description,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdOn: DateTime.parse(json['created_at']),
      updatedOn: DateTime.parse(json['updated_at']),
      messages: json['messages'].map<Message>(
        (message) => Message.fromJson(message),
      ).toList(),
    );
  }

  String getLatestMessage() {
    if (messages.isEmpty) {
      return "";
    }
    return messages[messages.length - 1].message;
  }
  bool isLatestMessageSentByUser(loggedInUserId) {
    if (messages.isEmpty) {
      return false;
    }
    return messages[messages.length - 1].senderId == loggedInUserId;
  }
}
