class Routes {
  static Route chats = const Route(pagePath: '/', pageName: '/');
  static Route contacts = const Route(pagePath: 'contacts', pageName: '/contacts');
  static Route invitations = const Route(pagePath: 'invitations', pageName: '/invitations');
  static Route login = const Route(pagePath: 'login', pageName: '/login');
  static Route register =
      const Route(pagePath: 'register', pageName: '/register');

  static List<String> allowedRoutesWithoutAuthentication = [login.pageName, register.pageName];
}

class Route {
  final String pagePath;
  final String pageName;

  const Route({required this.pagePath, required this.pageName});
}
