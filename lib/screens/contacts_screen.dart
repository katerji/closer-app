import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:y/providers/contact_provider.dart';

import '../widgets/contacts_widget.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final TextEditingController _newContactPhoneNumber = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ElevatedButton(
        onPressed: _showAddContactDialog,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(20),
          backgroundColor: Colors.blue,
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      appBar: AppBar(
        title: const Text("Contacts"),
      ),
      body: const Center(
        child: ContactsWidget(),
      ),
    );
  }

  Future<void> _showAddContactDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add contact'),
          content: Center(
            child: TextField(
              controller: _newContactPhoneNumber,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Enter phone number',
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                context.read<ContactProvider>().sendInvitation(_newContactPhoneNumber.text);
                _newContactPhoneNumber.text = "";
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
