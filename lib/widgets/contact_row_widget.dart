import 'package:flutter/material.dart';

import '../models/user.dart';

class ContactRowWidget extends StatelessWidget {
  final User contact;

  const ContactRowWidget({required this.contact, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}
