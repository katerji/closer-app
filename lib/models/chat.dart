class Chat {
  final int id;
  final String? name;
  final String? description;
  final DateTime createdOn;
  final DateTime updatedOn;

  const Chat({
    required this.id,
    required this.createdOn,
    required this.updatedOn,
    this.name,
    this.description,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdOn: DateTime.parse(json['created_at']),
      updatedOn: DateTime.parse(json['updated_at']),
    );
  }
}
