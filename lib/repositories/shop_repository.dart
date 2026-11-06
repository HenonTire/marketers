import 'package:marketers/config/mock_data_config.dart';
import 'package:marketers/mock_data/mock_shop_data.dart';
import 'package:marketers/models/shop_models.dart';
import 'package:marketers/service/api_client.dart';
import 'dart:ui';

/// Assumed REST contract until the backend shop app exposes its routes:
/// /marketer/shops/.
class BackendShopRepository {
  BackendShopRepository(this._client);

  final ApiClient _client;

  Future<List<Shop>> getShops({String? search}) async {
    try {
      final queryParameters = <String, dynamic>{'page_size': 100};
      if (search != null && search.trim().isNotEmpty) {
        queryParameters['search'] = search.trim();
      }
      final response = await _client.get('/marketer/shops/', queryParameters: queryParameters);
      return _items(response.data).map(ShopMapper.fromJson).toList();
    } catch (error) {
      if (!MockDataConfig.useMockDataOnFailure) rethrow;
      MockDataConfig.logFallback('shops', error);
      return MockShopData.shops();
    }
  }

  /// Assumed detail contract: GET /marketer/shops/{id}/ returns one shop,
  /// without the pagination envelope used by the listing endpoint.
  Future<Shop> getShopDetail(String shopId) async {
    try {
      final response = await _client.get('/marketer/shops/$shopId/');
      return ShopMapper.fromJson(_map(response.data));
    } catch (error) {
      if (!MockDataConfig.useMockDataOnFailure) rethrow;
      MockDataConfig.logFallback('shop detail', error);
      return MockShopData.shopById(shopId);
    }
  }

  static List<Map<String, dynamic>> _items(dynamic value) {
    if (value is List) return value.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
    if (value is! Map) throw const ApiFailure(ApiFailureKind.response, 'The shops response was invalid.');
    final body = Map<String, dynamic>.from(value);
    final items = body['results'] ?? body['shops'] ?? const [];
    if (items is! List) throw const ApiFailure(ApiFailureKind.response, 'The shops response was invalid.');
    return items.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
  }

  static Map<String, dynamic> _map(dynamic value) => value is Map
      ? Map<String, dynamic>.from(value)
      : throw const ApiFailure(ApiFailureKind.response, 'The shop response was invalid.');
}
class ShopMapper {
  static Shop fromJson(Map<String, dynamic> json) {
    final themeSettings = json['theme_settings'] is Map
        ? Map<String, dynamic>.from(json['theme_settings'] as Map)
        : const <String, dynamic>{};

    return Shop(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      badge: json['badge']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? json['imageUrl']?.toString() ?? themeSettings['logo']?.toString() ?? '',
      ordersCount: _int(json['orders_count'] ?? json['orders']),
      domain: json['domain']?.toString() ?? '',
      createdAt: _date(json['created_at']),
      theme: json['theme']?.toString(),
      themeSettings: ShopTheme(
        primaryColor: _color(themeSettings['primary_color'], ShopTheme.defaultPrimaryColor),
        secondaryColor: _color(themeSettings['secondary_color'], ShopTheme.defaultSecondaryColor),
        logo: _url(themeSettings['logo']),
        bannerImage: _url(themeSettings['banner_image']),
        fontFamily: _value(themeSettings['font_family']),
      ),
      rating: _double(json['rating']),
      category: _value(json['category']),
      isOnline: json['is_online'] == true,
      isOpen: json['is_open'] == true,
      products: json['products'] is List
          ? (json['products'] as List).whereType<Map>().map((p) => _productFromJson(Map<String, dynamic>.from(p))).toList()
          : const [],
    );
  }

  static ShopProduct _productFromJson(Map<String, dynamic> json) => ShopProduct(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        price: _double(json['price']),
        category: _value(json['category']),
        imageUrl: _url(json['image_url']),
      );

  static int _int(dynamic value) => value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;

  static double _double(dynamic value) => value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '') ?? 0.0;

  static DateTime? _date(dynamic value) => value == null ? null : DateTime.tryParse(value.toString())?.toLocal();

  static String? _value(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static String? _url(dynamic value) => _value(value);

  static Color _color(dynamic value, Color fallback) {
    final hex = _value(value)?.replaceFirst('#', '');
    if (hex == null || (hex.length != 6 && hex.length != 8)) return fallback;
    final parsed = int.tryParse(hex.length == 6 ? 'FF$hex' : hex, radix: 16);
    return parsed == null ? fallback : Color(parsed);
  }
}