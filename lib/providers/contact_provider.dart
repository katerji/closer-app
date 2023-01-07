import 'package:flutter/material.dart';
import 'package:y/network/api_request_loader.dart';
import 'package:y/network/responses/contacts_get_response.dart';
import 'package:y/services/contact_service.dart';
import 'package:y/utility/invitation_actions_enum.dart';
import '../models/user.dart';
import '../network/responses/generic_response.dart';
import '../network/responses/invitations_get_response.dart';

class ContactProvider extends ChangeNotifier {
  List<User> _sentInvitations = [];
  List<User> _receivedInvitations = [];
  ApiRequestLoader contactsGetRequestLoader = ApiRequestLoader();
  ApiRequestLoader invitationsGetRequestLoader = ApiRequestLoader();
  ContactService contactService = ContactService();
  List<User> _contacts = [];

  Future<void> getContacts() async {
    contactsGetRequestLoader.setLoading(true);

    ContactsGetResponse response = await contactService.getAll();
    if (response.error != null) {
      notifyListeners();
      return;
    }
    _contacts = response.contacts;
    contactsGetRequestLoader.setLoading(false);
    notifyListeners();
  }

  Future<void> sendInvitation(String phoneNumber) async {
    GenericResponse response =
    await contactService.sendInvitation(phoneNumber);
    if (response.error != null) {
      notifyListeners();
      return;
    }
    notifyListeners();
    return;
  }

  Future<void> updateInvitation(int userId, InvitationActions action) async {
    GenericResponse response =
        await contactService.updateInvitation(userId, action);
    if (response.error != null) {
      notifyListeners();
      return;
    }
    notifyListeners();
    return;
  }

  Future<void> deleteSentInvitation(int userId) async {
    GenericResponse response =
        await contactService.deleteSentInvitation(userId);
    if (response.error != null) {
      notifyListeners();
      return;
    }
    notifyListeners();
    return;
  }

  Future<void> getInvitations() async {
    invitationsGetRequestLoader.setLoading(true);
    InvitationsGetResponse response = await contactService.getAllInvitations();
    if (response.error != null) {
      return;
    }
    _sentInvitations = response.sentInvitations;
    _receivedInvitations = response.receivedInvitations;
    invitationsGetRequestLoader.setLoading(false);
    notifyListeners();
  }

  List<User> sentInvitations() => _sentInvitations;

  List<User> receivedInvitations() => _receivedInvitations;

  List<User> contacts() => _contacts;
}
