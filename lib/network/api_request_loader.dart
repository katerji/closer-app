class ApiRequestLoader {
  bool _isLoading = true;
  ApiRequestLoader();
  void setLoading(bool loading) => _isLoading = loading;
  void isLoading() => _isLoading;
}

