// lib/repositories/contract_repository.dart
import 'package:marketers/models/referral_models.dart';
import 'package:marketers/service/api_client.dart';

class BackendContractRepository {
  BackendContractRepository(this._client);

  final ApiClient _client;

  Future<String?> activeContractIdForShop(String shopId) async {
    try {
      final response = await _client.get('/marketer/contracts/', queryParameters: {'page_size': 100});
      final body = _map(response.data);
      final items = body['results'] ?? const [];
      for (final raw in items) {
        if (raw is! Map) continue;
        final map = Map<String, dynamic>.from(raw);
        final status = map['status']?.toString().toUpperCase();
        final shop = map['shop'] is Map ? Map<String, dynamic>.from(map['shop'] as Map) : null;
        if (status == 'ACTIVE' && shop?['id']?.toString() == shopId) {
          return map['id']?.toString();
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
  Future<ReferralLink> createReferralLink({
    required String contractId,
    required String scope, // 'SHOP' or 'PRODUCT'
    String? productId,
  }) async {
    final response = await _client.post('/marketer/referral-links/', data: {
      'contract_id': contractId,
      'scope': scope,
      if (productId != null) 'product_id': productId,
    });
    return ReferralLinkMapper.fromJson(_map(response.data));
  }
  static Map<String, dynamic> _map(dynamic value) => value is Map
      ? Map<String, dynamic>.from(value)
      : throw const ApiFailure(ApiFailureKind.response, 'The contracts response was invalid.');
}

