import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:y/providers/contact_provider.dart';

import '../models/user.dart';
import 'contact_row_widget.dart';

class ContactsWidget extends StatefulWidget {
  const ContactsWidget({Key? key}) : super(key: key);

  @override
  State<ContactsWidget> createState() => _ContactsWidgetState();
}

class _ContactsWidgetState extends State<ContactsWidget> {
  ContactProvider? _contactProvider;

  @override
  void didChangeDependencies() {
    _contactProvider ??= context.watch<ContactProvider>();
    _contactProvider!.fetchContacts();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: _contactProvider!
          .contacts()
          .map(
            (User user) => ContactRowWidget(
          contact: user,
        ),
      )
          .toList(),
    );
  }
}
