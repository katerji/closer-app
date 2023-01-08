import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:y/providers/contact_provider.dart';

import '../models/enums/invitation_type_enum.dart';
import '../widgets/invitation_widget.dart';

class InvitationsScreen extends StatefulWidget {
  const InvitationsScreen({Key? key}) : super(key: key);

  @override
  State<InvitationsScreen> createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends State<InvitationsScreen> {
  ContactProvider? _contactProvider;

  @override
  void didChangeDependencies() {
    _contactProvider ??= context.watch<ContactProvider>();
    _contactProvider!.fetchInvitations();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Invitations"),
      ),
      body: Column(
        children: [
          Container(
            height: 100,
            child: _contactProvider!.receivedInvitations().isNotEmpty
                ? ListView(
              children: _contactProvider!
                  .receivedInvitations()
                  .map<InvitationWidget>(
                    (user) => InvitationWidget(
                  user: user,
                  invitationType: InvitationType.received,
                ),
              )
                  .toList(),
            )
                : const SizedBox.shrink(),
          ),
          Text("Sent"),
          Container(
            height: 100,
            child: _contactProvider!.sentInvitations().isNotEmpty
                ? ListView(
              children: _contactProvider!
                  .sentInvitations()
                  .map<InvitationWidget>(
                    (user) => InvitationWidget(
                  user: user,
                  invitationType: InvitationType.sent,
                ),
              )
                  .toList(),
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
