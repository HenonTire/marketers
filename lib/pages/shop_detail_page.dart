import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marketers/models/shop_models.dart';
import 'package:marketers/providers/contract_providers.dart';
import 'package:marketers/providers/shop_providers.dart';
import 'package:marketers/service/colors.dart';

class ShopDetailPage extends ConsumerWidget {
  const ShopDetailPage({super.key, required this.shopId});

  final String shopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopAsync = ref.watch(shopDetailProvider(shopId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.ivory,
        elevation: 0,
        title: const Text('Shop details'),
      ),
      body: shopAsync.when(
        loading: () => const _ShopDetailSkeleton(),
        error: (error, _) => _ShopDetailError(
          onRetry: () => ref.invalidate(shopDetailProvider(shopId)),
        ),
        data: (shop) => RefreshIndicator(
          color: shop.themeSettings.primaryColor,
          onRefresh: () async => ref.invalidate(shopDetailProvider(shopId)),
          child: _ShopDetailContent(shop: shop),
        ),
      ),
    );
  }
}

class _ShopDetailContent extends StatelessWidget {
  const _ShopDetailContent({required this.shop});

  final Shop shop;

  @override
  Widget build(BuildContext context) {
    final theme = shop.themeSettings;
    final textStyle = TextStyle(fontFamily: theme.fontFamily);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShopHeader(shop: shop),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: DefaultTextStyle.merge(
              style: textStyle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          shop.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontFamily: theme.fontFamily,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusPill(isOpen: shop.isOpen, isOnline: shop.isOnline),
                    ],
                  ),
                  if (shop.domain.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _CopyableDomain(domain: shop.domain, fontFamily: theme.fontFamily),
                  ],
                  const SizedBox(height: 14),
                  _StatsRow(shop: shop, accentColor: theme.primaryColor),
                  const SizedBox(height: 20),
                  _ExpandableDescription(
                    text: shop.description.isEmpty ? 'No description has been added yet.' : shop.description,
                    fontFamily: theme.fontFamily,
                  ),
                  const SizedBox(height: 24),
                  Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: theme.secondaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Messaging this shop will be available soon.')),
            ),
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            label: Text('Message shop', style: TextStyle(fontFamily: theme.fontFamily)),
          ),
        ),
        const SizedBox(width: 10),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.primaryColor,
            side: BorderSide(color: theme.primaryColor.withOpacity(0.6)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          ),
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sharing this shop will be available soon.')),
          ),
          child: const Icon(Icons.ios_share_rounded, size: 20),
        ),
      ],
    ),
    const SizedBox(height: 16),
    Consumer(
      builder: (context, ref, _) {
        final contractAsync = ref.watch(activeContractForShopProvider(shop.id));
        return contractAsync.when(
          loading: () => const SizedBox(
            height: 48,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (_, __) => _NoContractButton(theme: theme, shop: shop),
          data: (contractId) => contractId == null
              ? _NoContractButton(theme: theme, shop: shop)
              : _ReferralLinkButton(
                  contractId: contractId,
                  scope: 'SHOP',
                  shopDomain: shop.domain,
                  theme: theme,
                ),
        );
      },
    ),
  ],
)
                  
                ],
                
              ),
            ),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Products (${shop.products.length})',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: theme.fontFamily),
            ),
          ),
          const SizedBox(height: 12),
          if (shop.products.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.inventory_2_outlined, color: Colors.white24, size: 36),
                  const SizedBox(height: 8),
                  Text('No products listed yet.', style: TextStyle(color: AppColors.textSecondary, fontFamily: theme.fontFamily)),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: shop.products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) => _ProductCard(
                product: shop.products[index],
                accentColor: theme.primaryColor,
                onTap: () => _showProductSheet(context, shop, shop.products[index], theme),
              ),
            ),
        ],
      ),
    );
  }

  void _showProductSheet(BuildContext context, Shop shop, ShopProduct product, ShopTheme theme) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.background,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (context) => _ProductDetailSheet(shop: shop, product: product, theme: theme),
  );
}
}

class _ShopHeader extends StatelessWidget {
  const _ShopHeader({required this.shop});

  final Shop shop;

  @override
  Widget build(BuildContext context) {
    final theme = shop.themeSettings;
    return SizedBox(
      height: 208,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: () => _openFullscreenImage(context, theme.bannerImage),
            child: SizedBox(
              height: 160,
              width: double.infinity,
              child: _NetworkImage(
                url: theme.bannerImage,
                fallbackColor: theme.primaryColor,
                fit: BoxFit.cover,
                icon: Icons.storefront_rounded,
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 0,
            child: GestureDetector(
              onTap: () => _openFullscreenImage(context, theme.logo),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: theme.secondaryColor,
                  child: ClipOval(
                    child: SizedBox(
                      width: 88,
                      height: 88,
                      child: _NetworkImage(
                        url: theme.logo,
                        fallbackColor: theme.primaryColor,
                        fit: BoxFit.cover,
                        icon: Icons.store_rounded,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openFullscreenImage(BuildContext context, String? url) {
    if (url == null || url.isEmpty) return;
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (context, _, __) => GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: InteractiveViewer(
                child: Image.network(url, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white54, size: 64)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CopyableDomain extends StatelessWidget {
  const _CopyableDomain({required this.domain, required this.fontFamily});

  final String domain;
  final String? fontFamily;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: domain));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"$domain" copied to clipboard'), duration: const Duration(seconds: 1)),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(domain, style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontFamily: fontFamily)),
          const SizedBox(width: 4),
          const Icon(Icons.copy_rounded, size: 13, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _ExpandableDescription extends StatefulWidget {
  const _ExpandableDescription({required this.text, required this.fontFamily});

  final String text;
  final String? fontFamily;

  @override
  State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<_ExpandableDescription> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(color: AppColors.textSecondary, height: 1.5, fontFamily: widget.fontFamily);
    return GestureDetector(
      onTap: widget.text.length > 120 ? () => setState(() => _expanded = !_expanded) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.text,
            style: style,
            maxLines: _expanded ? null : 3,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
          if (widget.text.length > 120)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _expanded ? 'Show less' : 'Show more',
                style: TextStyle(color: AppColors.textDisabled, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: widget.fontFamily),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.shop, required this.accentColor});

  final Shop shop;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    Widget stat(IconData icon, String label, {Color? color}) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color ?? AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color ?? AppColors.textSecondary, fontSize: 13, fontWeight: color != null ? FontWeight.w600 : FontWeight.normal)),
          ],
        );

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        stat(Icons.star_rounded, shop.rating.toStringAsFixed(1), color: Colors.amber),
        stat(Icons.shopping_bag_outlined, '${shop.ordersCount} orders'),
        if (shop.category != null) stat(Icons.category_outlined, shop.category!, color: accentColor),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.isOpen, required this.isOnline});

  final bool isOpen;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final open = isOpen && isOnline;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: (open ? Colors.green : Colors.grey).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: open ? Colors.green : Colors.grey, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            open ? 'Open' : 'Closed',
            style: TextStyle(color: open ? Colors.green : Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.accentColor, required this.onTap});

  final ShopProduct product;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.2,
              child: _NetworkImage(url: product.imageUrl, fallbackColor: accentColor, fit: BoxFit.cover, icon: Icons.image_outlined),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('ETB ${product.price.toStringAsFixed(0)}', style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _ProductDetailSheet extends ConsumerWidget {
  const _ProductDetailSheet({required this.shop, required this.product, required this.theme});

  final Shop shop;
  final ShopProduct product;
  final ShopTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractAsync = ref.watch(activeContractForShopProvider(shop.id));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: AppColors.textDisabled, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 1.6,
                child: _NetworkImage(url: product.imageUrl, fallbackColor: theme.primaryColor, fit: BoxFit.cover, icon: Icons.image_outlined),
              ),
            ),
            const SizedBox(height: 16),
            Text(product.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Row(
              children: [
                Text('ETB ${product.price.toStringAsFixed(0)}', style: TextStyle(color: theme.primaryColor, fontSize: 16, fontWeight: FontWeight.bold)),
                if (product.category != null) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                    child: Text(product.category!, style: TextStyle(color: theme.primaryColor, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),
            Text(
              product.description.isEmpty ? 'No description provided.' : product.description,
              style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 20),
            contractAsync.when(
              loading: () => const SizedBox(
                height: 48,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (_, __) => _NoContractButton(theme: theme, shop: shop),
              data: (contractId) => contractId == null
                  ? _NoContractButton(theme: theme, shop: shop)
                  : _ReferralLinkButton(
                      contractId: contractId,
                      scope: 'PRODUCT',
                      productId: product.id,
                      shopDomain: shop.domain,
                      theme: theme,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoContractButton extends StatelessWidget {
  const _NoContractButton({required this.theme, required this.shop});

  final ShopTheme theme;
  final Shop shop;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textDisabled,
          side: BorderSide(color: AppColors.textDisabled.withOpacity(0.4)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You need an active contract with this shop to get a referral link. Contract proposals are coming soon.')),
        ),
        icon: const Icon(Icons.lock_outline_rounded),
        label: const Text('Propose a contract first'),
      ),
    );
  }
}

class _ReferralLinkButton extends ConsumerWidget {
  const _ReferralLinkButton({
    required this.contractId,
    required this.scope,
    required this.shopDomain,
    required this.theme,
    this.productId,
  });

  final String contractId;
  final String scope;
  final String? productId;
  final String shopDomain;
  final ShopTheme theme;

  String get _key => '$contractId-$scope-${productId ?? ''}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(referralLinkProvider(_key));

    if (state.link != null) {
      final url = state.link!.urlFor(shopDomain);
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Expanded(
              child: Text(url, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13), overflow: TextOverflow.ellipsis),
            ),
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 20),
              color: theme.primaryColor,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: url));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Referral link copied'), duration: Duration(seconds: 1)),
                );
              },
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: theme.secondaryColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: state.isLoading
            ? null
            : () => ref.read(referralLinkProvider(_key).notifier).generate(
                  contractId: contractId,
                  scope: scope,
                  productId: productId,
                ),
        icon: state.isLoading
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.link_rounded),
        label: Text(state.isLoading ? 'Generating…' : 'Get referral link'),
      ),
    );
  }
}
class _NetworkImage extends StatelessWidget {
  const _NetworkImage({required this.url, required this.fallbackColor, required this.fit, required this.icon});

  final String? url;
  final Color fallbackColor;
  final BoxFit fit;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    Widget fallback() => ColoredBox(
          color: fallbackColor,
          child: Center(child: Icon(icon, color: Colors.white70, size: 32)),
        );
    if (url == null || url!.isEmpty) return fallback();
    return Image.network(
      url!,
      fit: fit,
      errorBuilder: (_, __, ___) => fallback(),
      loadingBuilder: (context, child, progress) => progress == null ? child : fallback(),
    );
  }
}

class _ShopDetailError extends StatelessWidget {
  const _ShopDetailError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storefront_outlined, color: Colors.white24, size: 52),
            const SizedBox(height: 12),
            const Text('Unable to load this shop.', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      );
}

class _ShopDetailSkeleton extends StatefulWidget {
  const _ShopDetailSkeleton();

  @override
  State<_ShopDetailSkeleton> createState() => _ShopDetailSkeletonState();
}

class _ShopDetailSkeletonState extends State<_ShopDetailSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          final color = Colors.white.withOpacity(.06 + _controller.value * .08);
          Widget block({double? width, required double height, BorderRadius? radius}) => Container(
                width: width,
                height: height,
                decoration: BoxDecoration(color: color, borderRadius: radius ?? BorderRadius.circular(8)),
              );
          return Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                block(height: 160, width: double.infinity, radius: BorderRadius.zero),
                Transform.translate(offset: const Offset(20, -44), child: block(width: 88, height: 88, radius: BorderRadius.circular(44))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    block(width: 180, height: 26),
                    const SizedBox(height: 10),
                    block(width: 100, height: 13),
                    const SizedBox(height: 24),
                    block(width: double.infinity, height: 14),
                    const SizedBox(height: 8),
                    block(width: 240, height: 14),
                    const SizedBox(height: 30),
                    block(width: double.infinity, height: 48, radius: BorderRadius.circular(24)),
                  ]),
                ),
              ],
            ),
          );
        },
      );
}