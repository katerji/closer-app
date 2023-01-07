import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:y/providers/authProvider.dart';
import 'package:y/screens/chatsScreen.dart';
import 'package:y/screens/loginScreen.dart';
import 'package:y/screens/registerScreen.dart';
import 'package:y/utility/routes.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  AppState createState() {
    return AppState();
  }
}

class AppState extends State<App> {
  AuthProvider? authProvider ;

  @override
  void didChangeDependencies() {
    authProvider ??= context.watch<AuthProvider>();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: GoRouter(
        routes: <RouteBase>[
          GoRoute(
            path: Routes.chats.pagePath,
            builder: (BuildContext context, GoRouterState state) {
              return const ChatsScreen();
            },
            redirect: (context, state) {
              final loggedIn = authProvider?.isLoggedIn();
              final loggingIn = state.subloc == '/login';
              if (!loggedIn!) return loggingIn ? null : Routes.login.pageName;
              if (loggingIn) return '/';
              return null;
            },
            routes: <RouteBase>[
              GoRoute(
                path: Routes.login.pagePath,
                builder: (BuildContext context, GoRouterState state) {
                  return const LoginScreen();
                },
              ),
              GoRoute(
                path: Routes.register.pagePath,
                builder: (BuildContext context, GoRouterState state) {
                  return const RegisterScreen();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
