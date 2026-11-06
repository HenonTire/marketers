import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marketers/models/profile_models.dart';
import 'package:marketers/repositories/profile_repository.dart';
import 'package:marketers/service/api_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final profileRepositoryProvider = Provider<BackendProfileRepository>((ref) {
  return BackendProfileRepository(ref.watch(apiClientProvider));
});

final marketerProfileProvider = FutureProvider<MarketerProfile>((ref) async {
  return ref.watch(profileRepositoryProvider).fetchProfile();
});
