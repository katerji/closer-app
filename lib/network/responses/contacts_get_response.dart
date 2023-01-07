import '../../models/user.dart';

class ContactsGetResponse {
  final List<User> contacts;
  final String? error;

  ContactsGetResponse({
    required this.contacts,
    this.error,
  });
}
