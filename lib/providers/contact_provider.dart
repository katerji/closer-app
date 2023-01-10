import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:y/network/api_request_loader.dart';
import 'package:y/network/responses/contacts_get_response.dart';
import 'package:y/services/contact_service.dart';
import 'package:y/utility/constants.dart';
import '../models/enums/invitation_actions_enum.dart';
import '../models/user.dart';
import '../network/responses/generic_response.dart';
import '../network/responses/invitations_get_response.dart';

class ContactProvider extends ChangeNotifier {
  List<User> _sentInvitations = [];
  List<User> _receivedInvitations = [];
  Map<int, User> _contacts = {};
  ApiRequestLoader contactsGetRequestLoader = ApiRequestLoader();
  ApiRequestLoader invitationsGetRequestLoader = ApiRequestLoader();
  ApiRequestLoader sendInvitationRequestLoader = ApiRequestLoader();
  ContactService contactService = ContactService();
  final Map<int, ApiRequestLoader> invitationsAcceptRequestLoader = {};
  final Map<int, ApiRequestLoader> invitationsRejectRequestLoader = {};
  final Map<int, ApiRequestLoader> sentInvitationsDeleteRequestLoader = {};

  bool _didFetchContacts = false;
  bool _didFetchInvitations = false;

  Future<void> fetchContacts({bool forceFetch = false}) async {
    if (_didFetchContacts && !forceFetch) {
      return;
    }
    _didFetchContacts = true;
    contactsGetRequestLoader.setLoading(true);
    ContactsGetResponse response = await contactService.getAll();
    if (response.error != null) {
      notifyListeners();
      return;
    }
    response.contacts.forEach((contact) {
      if(_contacts[contact.userId] == null) {
        _contacts[contact.userId] = contact;
      }
    });
    contactsGetRequestLoader.setLoading(false);
    notifyListeners();
    _storeContacts();
  }

  Future<void> sendInvitation(String phoneNumber) async {
    sendInvitationRequestLoader.setLoading(true);
    InvitationsGetResponse response =
        await contactService.sendInvitation(phoneNumber);
    if (response.error != null) {
      notifyListeners();
      return;
    }
    _setInvitationsFromResponse(response);
    sendInvitationRequestLoader.setLoading(false);
    notifyListeners();
    return;
  }

  Future<void> updateInvitation(int userId, InvitationActions action) async {
    if (action == InvitationActions.accept) {
      invitationsAcceptRequestLoader[userId] = ApiRequestLoader();
      invitationsAcceptRequestLoader[userId]?.setLoading(true);
    } else {
      invitationsRejectRequestLoader[userId] = ApiRequestLoader();
      invitationsRejectRequestLoader[userId]?.setLoading(true);
    }
    InvitationsGetResponse response =
        await contactService.updateInvitation(userId, action);
    if (action == InvitationActions.accept) {
      invitationsAcceptRequestLoader[userId]?.setLoading(false);
    } else {
      invitationsRejectRequestLoader[userId]?.setLoading(false);
    }
    if (response.error != null) {
      notifyListeners();
      return;
    }
    _setInvitationsFromResponse(response);
    notifyListeners();
    return;
  }

  Future<void> deleteSentInvitation(int userId) async {
    sentInvitationsDeleteRequestLoader[userId] = ApiRequestLoader();
    sentInvitationsDeleteRequestLoader[userId]?.setLoading(true);
    InvitationsGetResponse response =
        await contactService.deleteSentInvitation(userId);
    if (response.error != null) {
      notifyListeners();
      return;
    }
    sentInvitationsDeleteRequestLoader[userId]?.setLoading(false);
    _setInvitationsFromResponse(response);
    notifyListeners();
    return;
  }

  Future<void> fetchInvitations({bool forceFetch = false}) async {
    if (_didFetchInvitations && !forceFetch) {
      return;
    }
    _didFetchInvitations = true;
    invitationsGetRequestLoader.setLoading(true);
    InvitationsGetResponse response = await contactService.getAllInvitations();
    if (response.error != null) {
      return;
    }
    _setInvitationsFromResponse(response);
    invitationsGetRequestLoader.setLoading(false);
    notifyListeners();
  }

  List<User> sentInvitations() => _sentInvitations;

  List<User> receivedInvitations() => _receivedInvitations;

  Map<int, User> contacts() => _contacts;

  void _setInvitationsFromResponse(InvitationsGetResponse invitations) {
    _sentInvitations = invitations.sentInvitations;
    _receivedInvitations = invitations.receivedInvitations;
  }

  void setContactsFromStorage() async {
    FlutterSecureStorage storage = FlutterSecureStorage();
    dynamic contacts =
        await storage.read(key: Constants.secureStorageContactsKey);
    Map<String, dynamic> contactsMap = jsonDecode(contacts);
    Map<int, User> contactsObject = {};
    contactsMap.forEach((key, value) {
      contactsObject[int.parse(key)] = User.fromJson(value);
    });
    _contacts = contactsObject;
    notifyListeners();
  }

  void _storeContacts() {
    Map<int, User> contactsObject = _contacts;
    Map<String, dynamic> contactsMap = {};
    contactsObject.forEach((key, value) {
      contactsMap[key.toString()] = value.toMap();
    });
    FlutterSecureStorage storage = FlutterSecureStorage();
    storage.write(
      key: Constants.secureStorageContactsKey,
      value: jsonEncode(contactsMap),
    );
  }
}
