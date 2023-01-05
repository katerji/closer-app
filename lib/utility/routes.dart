class Routes {
  static Route home = const Route(pagePath: '/', pageName: '/');
  static Route login = const Route(pagePath: 'login', pageName: '/login');
  static Route register =
      const Route(pagePath: 'register', pageName: '/register');
  static Route chats = const Route(pagePath: 'chats', pageName: '/chats');
}

class Route {
  final String pagePath;
  final String pageName;

  const Route({required this.pagePath, required this.pageName});
}
