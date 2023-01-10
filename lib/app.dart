import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:y/providers/auth_provider.dart';
import 'package:y/screens/chat_screen.dart';
import 'package:y/screens/chats_screen.dart';
import 'package:y/screens/contacts_screen.dart';
import 'package:y/screens/invitations_screen.dart';
import 'package:y/screens/login_screen.dart';
import 'package:y/screens/register_screen.dart';
import 'package:y/screens/splash_screen.dart';
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
        redirect: (context, state) {
          final loggedIn = authProvider?.isLoggedIn();
          if (!loggedIn!) {
            String currentPage = state.location;
            if (Routes.allowedRoutesWithoutAuthentication.contains(currentPage)) {
              return null;
            }
            return Routes.login.pageName;
          }
          return null;
        },
        routes: <RouteBase>[
          GoRoute(
            path: Routes.chats.pagePath,
            builder: (BuildContext context, GoRouterState state) {
              return const ChatsScreen();
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
              GoRoute(
                path: Routes.contacts.pagePath,
                builder: (BuildContext context, GoRouterState state) {
                  return const ContactsScreen();
                },
              ),
              GoRoute(
                path: Routes.invitations.pagePath,
                builder: (BuildContext context, GoRouterState state) {
                  return const InvitationsScreen();
                },
              ),
              GoRoute(
                path: Routes.chat.pagePath,
                builder: (BuildContext context, GoRouterState state) {
                  return const ChatScreen();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
