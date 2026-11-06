import 'package:marketers/models/profile_models.dart';
import 'package:marketers/config/mock_data_config.dart';
import 'package:marketers/mock_data/mock_profile_data.dart';
import 'package:marketers/service/api_client.dart';

class BackendProfileRepository {
  BackendProfileRepository(this._client);

  final ApiClient _client;

  /// Maps `/auth/user/me/` and `/marketer/dashboard/` into the unchanged UI model.
  Future<MarketerProfile> fetchProfile() async {
    try {
      final user = _asMap((await _client.get('/auth/user/me/')).data);
      Map<String, dynamic> dashboard = const {};
      try {
        dashboard = _asMap((await _client.get('/marketer/dashboard/')).data);
      } on ApiFailure catch (error) {
        if (!MockDataConfig.useMockDataOnFailure) rethrow;
        MockDataConfig.logFallback('profile dashboard', error);
      }

      final firstName = user['first_name']?.toString().trim() ?? '';
      final lastName = user['last_name']?.toString().trim() ?? '';
      final fullName = '$firstName $lastName'.trim();
      return MarketerProfile(
        name: fullName.isEmpty ? (user['company_name']?.toString() ?? user['email']?.toString() ?? '') : fullName,
        role: user['role']?.toString() ?? '',
        clientsCount: _asInt(dashboard['total_orders_influenced']),
        earnings: 'KES ${dashboard['total_earnings']?.toString() ?? '0.00'}',
        rating: user['score']?.toString() ?? '0',
      );
    } catch (error) {
      if (!MockDataConfig.useMockDataOnFailure) rethrow;
      MockDataConfig.logFallback('profile', error);
      return MockProfileData.profile;
    }
  }

  /// The editable fields exposed by the backend's UserSerializer.
  Future<MarketerProfile> updateProfile({String? firstName, String? lastName, String? phoneNumber, String? location, String? companyName}) async {
    try {
      await _client.patch('/auth/user/me/', data: {
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (location != null) 'location': location,
        if (companyName != null) 'company_name': companyName,
      });
      return fetchProfile();
    } catch (error) {
      if (!MockDataConfig.useMockDataOnFailure) rethrow;
      MockDataConfig.logFallback('profile update', error);
      return MockProfileData.profile;
    }
  }

  static Map<String, dynamic> _asMap(dynamic value) => value is Map
      ? Map<String, dynamic>.from(value)
      : throw const ApiFailure(ApiFailureKind.response, 'The profile response was invalid.');

  static int _asInt(dynamic value) => value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;
}
