class ApiConfig {
  ApiConfig._();

  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://684e-196-191-240-182.ngrok-free.app',
  );

  static String get baseUrl {
    var url = _configuredBaseUrl.trim();

    // Remove trailing slash
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    return url;
  }
}
