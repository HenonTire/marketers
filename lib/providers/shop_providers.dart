import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marketers/models/shop_models.dart';
import 'package:marketers/providers/profile_providers.dart';
import 'package:marketers/repositories/shop_repository.dart';

final shopRepositoryProvider = Provider<BackendShopRepository>((ref) {
  return BackendShopRepository(ref.watch(apiClientProvider));
});

final shopProvider = FutureProvider<List<Shop>>((ref) {
  return ref.watch(shopRepositoryProvider).getShops();
});

final shopDetailProvider = FutureProvider.family<Shop, String>((ref, shopId) {
  return ref.watch(shopRepositoryProvider).getShopDetail(shopId);
});

// A simple StateProvider to hold the search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// A derived provider that filters shops based on the query
final filteredShopsProvider = Provider<AsyncValue<List<Shop>>>((ref) {
  final shopAsync = ref.watch(shopProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();

  return shopAsync.whenData((shops) {
    if (query.isEmpty) return shops;
    return shops.where((shop) {
      return shop.name.toLowerCase().contains(query) ||
             shop.description.toLowerCase().contains(query);
    }).toList();
  });
});
