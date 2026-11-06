import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marketers/providers/profile_providers.dart';
import 'package:marketers/repositories/contract_repository.dart';
import 'package:marketers/models/referral_models.dart';
/// the shared ApiClient/provider your app already uses.
final contractRepositoryProvider = Provider<BackendContractRepository>((ref) {
  return BackendContractRepository(ref.watch(apiClientProvider));
});

/// Checks whether the marketer has an active contract touching [shopId].
/// Returns the contract id, or null if none exists.
final activeContractForShopProvider =
    FutureProvider.family<String?, String>((ref, shopId) async {
  final repo = ref.watch(contractRepositoryProvider);
  return repo.activeContractIdForShop(shopId);
});

/// Holds the in-flight/created referral link for one bottom-sheet session.
/// family key = a composite of contractId+scope+productId so each
/// shop/product gets its own independent state.
class ReferralLinkState {
  const ReferralLinkState({this.link, this.isLoading = false, this.error});
  final ReferralLink? link;
  final bool isLoading;
  final String? error;

  ReferralLinkState copyWith({ReferralLink? link, bool? isLoading, String? error}) =>
      ReferralLinkState(
        link: link ?? this.link,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class ReferralLinkNotifier extends StateNotifier<ReferralLinkState> {
  ReferralLinkNotifier(this._repo) : super(const ReferralLinkState());

  final BackendContractRepository _repo;

  Future<void> generate({
    required String contractId,
    required String scope,
    String? productId,
  }) async {
    if (state.isLoading || state.link != null) return; // no double-fire
    state = state.copyWith(isLoading: true, error: null);
    try {
      final link = await _repo.createReferralLink(
        contractId: contractId,
        scope: scope,
        productId: productId,
      );
      state = state.copyWith(link: link, isLoading: false);
    } catch (e) {
      state = ReferralLinkState(isLoading: false, error: e.toString());
    }
  }
}

final referralLinkProvider = StateNotifierProvider.family<ReferralLinkNotifier, ReferralLinkState, String>(
  (ref, key) => ReferralLinkNotifier(ref.watch(contractRepositoryProvider)),
);
