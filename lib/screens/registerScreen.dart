import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:y/providers/authProvider.dart';

// Define a custom Form widget.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() {
    return RegisterScreenState();
  }
}

class RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Register"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter your name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: phoneNumberController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter your phone number',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter your password',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Confirm password',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    AuthProvider auth = AuthProvider();
                    await auth.register(nameController.text, phoneNumberController.text, passwordController.text, confirmPasswordController.text);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Registered, log in to continue'),
                      ),
                    );
                    context.pop();
                  }
                },
                child: const Text('Register'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
