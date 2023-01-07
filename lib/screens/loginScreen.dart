import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:y/providers/authProvider.dart';
import 'package:y/utility/routes.dart';

// Define a custom Form widget.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() {
    return LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  late final AuthProvider authProvider;
  @override
  void didChangeDependencies() {
    authProvider = context.watch<AuthProvider>();
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: phoneNumberController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter your phone number',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
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
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Logging in'),
                      ),
                    );
                  }
                  await authProvider.login(
                      phoneNumberController.text, passwordController.text);
                  if (!mounted) return;
                  print("done");
                  if (authProvider.isLoggedIn()) {
                    context.go('/');
                  }
                },
                child: const Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  context.go(Routes.register.pageName);
                },
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
