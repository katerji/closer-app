import 'package:flutter/material.dart';
import 'package:y/services/contact_service.dart';
import '../models/user.dart';
import '../network/responses/invitations_get_response.dart';

class ContactProvider extends ChangeNotifier {
  List<User> _sentInvitations = [];
  List<User> _receivedInvitations = [];

  Future<void> getContacts() async {
    ContactService contactService = ContactService();

  }

  Future<void> getInvitations() async {
    ContactService contactService = ContactService();
    InvitationsGetResponse response = await contactService.getAllInvitations();
    if (response.error != null) {
      return;
    }
    _sentInvitations = response.sentInvitations;
    _receivedInvitations = response.receivedInvitations;
    notifyListeners();
  }

  List<User> sentInvitations() => _sentInvitations;
  List<User> receivedInvitations() => _receivedInvitations;
}