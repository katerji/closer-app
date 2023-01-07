import 'package:y/network/responses/generic_response.dart';
import 'package:y/utility/invitation_actions_enum.dart';

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
    dynamic users = await Request.get(endpoint: Endpoints.getChats);
    if (users is RequestException) {
      return ContactsGetResponse(contacts: [], error: users.errorMessage);
    } else if (users.length == 0) {
      return ContactsGetResponse(contacts: [], error: users.errorMessage);
    } else {
      users = users.map((userJson) => User.fromJson(userJson));
      return ContactsGetResponse(contacts: users);
    }
  }

  Future<GenericResponse> sendInvitation(String phoneNumber) async {
    dynamic response = await Request.post(
        endpoint: Endpoints.sendInvitation,
        body: {"phone_number": phoneNumber});
    if (response is RequestException) {
      return GenericResponse(success: false, error: response.errorMessage);
    }
    return GenericResponse(success: true);
  }

  Future<InvitationsGetResponse> getAllInvitations() async {
    dynamic response = await Request.get(
      endpoint: Endpoints.getInvitations,
    );
    if (response is RequestException) {
      return InvitationsGetResponse(
          error: response.errorMessage,
          sentInvitations: [],
          receivedInvitations: []);
    }
    List<User> sentInvitations = response['sent_invitations']
        .map((invitation) => User.fromJson(invitation));
    List<User> receivedInvitations = response['received_invitations']
        .map((invitation) => User.fromJson(invitation));
    return InvitationsGetResponse(
        sentInvitations: sentInvitations,
        receivedInvitations: receivedInvitations);
  }

  Future<GenericResponse> updateInvitation(
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
      return GenericResponse(success: false, error: response.errorMessage);
    }
    return GenericResponse(success: true);
  }

  Future<GenericResponse> deleteSentInvitation(int userId) async {
    String endpoint = Endpoints.getDeleteSentInvitationEndpoint(userId);
    dynamic response = await Request.delete(endpoint: endpoint);
    if (response is RequestException) {
      return GenericResponse(success: false, error: response.errorMessage);
    }
    return GenericResponse(success: true);
  }
}
