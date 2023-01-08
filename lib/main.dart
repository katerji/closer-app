import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:y/providers/auth_provider.dart';
import 'package:y/providers/chat_provider.dart';
import 'package:y/providers/contact_provider.dart';
import 'package:y/screens/splash_screen.dart';

void main() => runApp(
      ChangeNotifierProvider(
        create: (context) => AuthProvider(),
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return MultiProvider(
              // key: ObjectKey(authProvider.appKey),
              providers: [
                ChangeNotifierProvider<ChatProvider>(
                  create: (_) => ChatProvider(),
                ),
                ChangeNotifierProvider<ContactProvider>(
                  create: (_) => ContactProvider(),
                ),
              ],
              child: const MyApp(),
            );
          },
        ),
      ),
    );

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
