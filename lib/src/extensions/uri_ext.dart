extension UriExt on Uri {
  bool isHttpBasedUrl() {
    final uri = this;
    return uri.isScheme('HTTP') || uri.isScheme('HTTPS');
  }

  bool isHttpsBasedUrl() {
    final uri = this;
    return uri.isScheme('HTTPS');
  }
}
