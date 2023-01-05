// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:y/screens/loginScreen.dart';
import 'package:y/screens/registerScreen.dart';
import 'package:y/utility/routes.dart';

void main() => runApp(const MyApp());

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: Routes.home.pagePath,
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: Routes.register.pagePath,
          builder: (BuildContext context, GoRouterState state) {
            return const RegisterScreen();
          },
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}
//
// /// The home screen
// class HomeScreen extends StatelessWidget {
//   /// Constructs a [HomeScreen]
//   const HomeScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Home Screen')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             ElevatedButton(
//               onPressed: () => context.go('/details'),
//               child: const Text('Go to the Details screen'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// /// The details screen
// class DetailsScreen extends StatelessWidget {
//   /// Constructs a [DetailsScreen]
//   const DetailsScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Details Screen')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <ElevatedButton>[
//             ElevatedButton(
//               onPressed: () => context.go('/'),
//               child: const Text('Go back to the Home screen'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }