import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:y/models/user.dart';
import 'package:y/providers/contact_provider.dart';

import '../models/enums/invitation_actions_enum.dart';
import '../models/enums/invitation_type_enum.dart';

class InvitationWidget extends StatelessWidget {
  final User user;
  final InvitationType invitationType;

  const InvitationWidget({
    required this.user,
    required this.invitationType,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.name),
            Text(user.phoneNumber),
          ],
        ),
        Spacer(),
        IconButton(
          onPressed: () {
            context
                .read<ContactProvider>()
                .deleteSentInvitation(user.userId);
          },
          icon: Icon(
            Icons.delete,
            color: Colors.red,
          ),
        ),
        invitationType == InvitationType.received
            ? IconButton(
                onPressed: () {
                  context
                      .read<ContactProvider>()
                      .updateInvitation(user.userId, InvitationActions.accept);
                },
                icon: Icon(
                  Icons.check,
                  color: Colors.green,
                ),
              )
            : SizedBox.shrink(),
      ],
    );
  }
}
