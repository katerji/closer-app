import '../models/enums/invitation_actions_enum.dart';
import '../models/user.dart';
import '../network/endpoints.dart';
import '../network/request.dart';
import '../network/responses/contacts_get_response.dart';
import '../network/responses/invitations_get_response.dart';

class ContactService {
  static final ContactService _contactService = ContactService._internal();

  factory ContactService() {
    return _contactService;
  }

  ContactService._internal();

  Future<ContactsGetResponse> getAll() async {
    dynamic response = await Request.get(endpoint: Endpoints.getContacts);
    if (response is RequestException) {
      return ContactsGetResponse(contacts: [], error: response.errorMessage);
    }
    List<User> users = response.map<User>((user) => User.fromJson(user)).toList();
    return ContactsGetResponse(contacts: users);
  }

  Future<InvitationsGetResponse> sendInvitation(String phoneNumber) async {
    dynamic response = await Request.post(
        endpoint: Endpoints.sendInvitation,
        body: {"phone_number": phoneNumber});
    if (response is RequestException) {
      return InvitationsGetResponse(
          sentInvitations: [],
          receivedInvitations: [],
          error: response.errorMessage);
    }
    List<User> sentInvitations = response['sent_invitations']
        .map<User>((user) => User.fromJson(user))
        .toList();
    List<User> receivedInvitations = response['received_invitations']
        .map<User>((user) => User.fromJson(user))
        .toList();
    return InvitationsGetResponse(
      sentInvitations: sentInvitations,
      receivedInvitations: receivedInvitations,
    );
  }

  Future<InvitationsGetResponse> getAllInvitations() async {
    dynamic response = await Request.get(
      endpoint: Endpoints.getInvitations,
    );
    if (response is RequestException) {
      return InvitationsGetResponse(
        error: response.errorMessage,
        sentInvitations: [],
        receivedInvitations: [],
      );
    }
    List<User> sentInvitations = response['sent_invitations']
        .map<User>((user) => User.fromJson(user))
        .toList();
    List<User> receivedInvitations = response['received_invitations']
        .map<User>((user) => User.fromJson(user))
        .toList();
    return InvitationsGetResponse(
      sentInvitations: sentInvitations,
      receivedInvitations: receivedInvitations,
    );
  }

  Future<InvitationsGetResponse> updateInvitation(
      int userId, InvitationActions action) async {
    late dynamic response;
    if (action == InvitationActions.accept) {
      response = await Request.post(
        endpoint: Endpoints.getAcceptOrRejectInvitationEndpoint(userId),
      );
    } else {
      response = await Request.delete(
        endpoint: Endpoints.getAcceptOrRejectInvitationEndpoint(userId),
      );
    }
    if (response is RequestException) {
      return InvitationsGetResponse(
          sentInvitations: [],
          receivedInvitations: [],
          error: response.errorMessage);
    }
    List<User> sentInvitations = response['sent_invitations']
        .map<User>((user) => User.fromJson(user))
        .toList();
    List<User> receivedInvitations = response['received_invitations']
        .map<User>((user) => User.fromJson(user))
        .toList();
    return InvitationsGetResponse(
      sentInvitations: sentInvitations,
      receivedInvitations: receivedInvitations,
    );
  }

  Future<InvitationsGetResponse> deleteSentInvitation(int userId) async {
    String endpoint = Endpoints.getDeleteSentInvitationEndpoint(userId);
    dynamic response = await Request.delete(endpoint: endpoint);
    if (response is RequestException) {
      return InvitationsGetResponse(
          sentInvitations: [],
          receivedInvitations: [],
          error: response.errorMessage);
    }
    List<User> sentInvitations = response['sent_invitations']
        .map<User>((user) => User.fromJson(user))
        .toList();
    List<User> receivedInvitations = response['received_invitations']
        .map<User>((user) => User.fromJson(user))
        .toList();
    return InvitationsGetResponse(
      sentInvitations: sentInvitations,
      receivedInvitations: receivedInvitations,
    );
  }
}
