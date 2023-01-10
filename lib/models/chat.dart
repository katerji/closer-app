import 'message.dart';

class Chat {
  final String name;
  final List<Message> messages;
  int? id;
  String? description;
  DateTime? createdOn;
  DateTime? updatedOn;

  //only needed when creating a new chat
  int? recipientId;

  Chat({
    this.id,
    this.createdOn,
    this.updatedOn,
    required this.messages,
    required this.name,
    this.description,
    this.recipientId,
  });

  set setId(newId) => id = newId;

  set setDescription(String newDescription) => description = newDescription;

  set setCreatedOn(DateTime newCreatedOn) => createdOn = newCreatedOn;

  set setUpdatedOn(DateTime newUpdatedOn) => updatedOn = newUpdatedOn;

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdOn: DateTime.parse(json['created_at']),
      updatedOn: DateTime.parse(json['updated_at']),
      messages: json['messages']
          .map<Message>(
            (message) => Message.fromJson(message),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdOn.toString(),
      'updated_at': updatedOn.toString(),
      'messages': messages
          .map(
            (Message message) => message.toMap(),
          )
          .toList(),
    };
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
