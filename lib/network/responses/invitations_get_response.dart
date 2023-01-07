import '../../models/user.dart';

class InvitationsGetResponse {
  final List<User> sentInvitations;
  final List<User> receivedInvitations;
  final String? error;

  InvitationsGetResponse({
    required this.sentInvitations,
    required this.receivedInvitations,
    this.error,
  });
}
