/// Build-time configuration. Pass overrides via:
///   flutter run --dart-define=BASE_URL=https://your.host
///   flutter build apk --release --dart-define=BASE_URL=https://your.host
class Variables {
  Variables._();

  /// Backend base URL. Production default points at the live host; pass a
  /// `--dart-define=BASE_URL=...` to point at staging or a local LAN server.
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    // defaultValue: 'https://api.example.com',
    defaultValue: 'https://pos.absensiku.com',
    // defaultValue: 'http://192.168.1.103:8000',
  );

  /// Prefix for product images served by Laravel storage.
  static const String imageBaseUrl = '$baseUrl/storage/products/';
}
