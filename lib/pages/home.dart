import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marketers/models/shop_models.dart';
import 'package:marketers/pages/login.dart';
import 'package:marketers/pages/message.dart';
import 'package:marketers/providers/shop_providers.dart';
import 'package:marketers/service/auth_session_store.dart';
import 'package:marketers/service/colors.dart';
import 'package:marketers/service/shop_card.dart';
import 'package:marketers/service/shop_loading_card.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  // ─────────────────────────── LOGOUT ───────────────────────────

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Log out?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'You will need to sign in again to use your account.',
          style: TextStyle(color: AppColors.textDisabled),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Log out',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await AuthSessionStore.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Login()),
      (route) => false,
    );
  }

  // ─────────────────────────── BUILD ───────────────────────────

  @override
  Widget build(BuildContext context) {
    final shopAsync = ref.watch(filteredShopsProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.background,
        drawer: _buildDrawer(),
        body: Stack(
          children: [
            _buildBackground(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: shopAsync.when(
                  loading: _loadingUI,
                  error: (e, _) => _errorUI(),
                  data: _buildUI,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.surface.withValues(alpha: 0.45),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -110,
              right: -80,
              child: IgnorePointer(
                child: Container(
                  height: 280,
                  width: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.pearl.withValues(alpha: 0.13),
                        AppColors.pearl.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────── DRAWER ───────────────────────────

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.pearl.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.background,
                      border: Border.all(
                        color: AppColors.pearl.withValues(alpha: 0.7),
                        width: 1.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.pearl.withValues(alpha: 0.25),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.textPrimary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Marketer Name',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              'View profile',
                              style: TextStyle(
                                color: AppColors.textDisabled,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 16,
                              color: AppColors.textDisabled,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // ── Menu Items ──
            _drawerItem(Icons.dashboard_rounded, 'Dashboard', () {
              Navigator.pop(context);
            }, selected: true),
            _drawerItem(Icons.people_alt_rounded, 'My Clients', () {
              Navigator.pop(context);
            }),
            _drawerItem(Icons.monetization_on_rounded, 'My Earnings', () {
              Navigator.pop(context);
            }),
            _drawerItem(Icons.bar_chart_rounded, 'My Stats', () {
              Navigator.pop(context);
            }),
            _drawerItem(Icons.settings_outlined, 'Settings', () {
              Navigator.pop(context);
            }),

            const Spacer(),

            Divider(color: AppColors.divider, indent: 20, endIndent: 20),

            // ── Logout ──
            _drawerItem(Icons.logout_rounded, 'Log out', () {
              Navigator.pop(context);
              _confirmLogout();
            }, color: Colors.redAccent),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color? color,
    bool selected = false,
  }) {
    final fg = color ?? (selected ? AppColors.textPrimary : AppColors.ivory);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(icon, color: fg, size: 22),
        title: Text(
          label,
          style: TextStyle(
            color: color ?? AppColors.textPrimary,
            fontSize: 15,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        onTap: onTap,
        selected: selected,
        selectedTileColor: AppColors.pearl.withValues(alpha: 0.12),
        horizontalTitleGap: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  // ─────────────────────────── LOADING UI ───────────────────────────

  Widget _loadingUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        _topBar(),
        const SizedBox(height: 18),
        _searchBar(),
        const SizedBox(height: 22),
        _sectionHeader('Best Shops'),
        SizedBox(
          height: 165,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (_, __) => const ShopSkeletonCard(),
          ),
        ),
        const SizedBox(height: 20),
        _sectionHeader('All Shops'),
        Expanded(
          child: GridView.builder(
            itemCount: 6,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (_, __) => const ShopSkeletonCard(),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────── ERROR UI ───────────────────────────

  Widget _errorUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 76,
              width: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.redAccent.withValues(alpha: 0.1),
                border: Border.all(
                  color: Colors.redAccent.withValues(alpha: 0.35),
                ),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: Colors.redAccent,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "Couldn't load shops",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Check your connection and try again later.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textDisabled, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────── MAIN UI ───────────────────────────

  Widget _buildUI(List<Shop> shops) {
    final query = ref.watch(searchQueryProvider);

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 14),
          _topBar(),
          const SizedBox(height: 18),
          _searchBar(),
          const SizedBox(height: 24),

          // Hide "Best Shops" while searching
          if (query.isEmpty) ...[
            _sectionHeader('Best Shops', count: shops.length),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: shops.length,
                itemBuilder: (context, index) {
                  return ShopCard(shop: shops[index], width: 155);
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          _sectionHeader(
            query.isEmpty ? 'All Shops' : 'Results for "$query"',
            count: shops.length,
          ),

          if (shops.isEmpty)
            _emptyState(query)
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 110),
              itemCount: shops.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                return ShopCard(shop: shops[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, {int? count}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.pearl,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.pearl.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _emptyState(String query) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Center(
        child: Column(
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.6),
                ),
              ),
              child: Icon(
                Icons.search_off_rounded,
                color: AppColors.textDisabled,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              query.isEmpty ? 'No shops yet' : 'No shops found',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              query.isEmpty
                  ? 'New shops will show up here.'
                  : 'Nothing matches "$query". Try a different word.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textDisabled, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────── TOP BAR ───────────────────────────

  Widget _topBar() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting,
                style: TextStyle(color: AppColors.textDisabled, fontSize: 13),
              ),
              const SizedBox(height: 2),
              const Text(
                'Hello marketer!',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        _roundIconButton(
          icon: Icons.chat_bubble_outline_rounded,
          tooltip: 'Messages',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MessagePage()),
            );
          },
        ),
        const SizedBox(width: 10),
        _roundIconButton(
          icon: Icons.grid_view_rounded,
          tooltip: 'Menu',
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ],
    );
  }

  Widget _roundIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.surface,
        shape: CircleBorder(
          side: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            height: 44,
            width: 44,
            child: Icon(icon, color: AppColors.textPrimary, size: 21),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────── SEARCH BAR ───────────────────────────

  Widget _searchBar() {
    final focused = _searchFocus.hasFocus;
    final hasText = _searchController.text.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: focused
              ? AppColors.pearl
              : AppColors.border.withValues(alpha: 0.5),
          width: focused ? 1.5 : 1,
        ),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: AppColors.pearl.withValues(alpha: 0.18),
                  blurRadius: 18,
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        textInputAction: TextInputAction.search,
        cursorColor: AppColors.pearl,
        onChanged: (value) {
          ref.read(searchQueryProvider.notifier).state = value;
          setState(() {});
        },
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Search shops...',
          hintStyle: TextStyle(color: AppColors.textDisabled, fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.textDisabled),
          suffixIcon: hasText
              ? IconButton(
                  tooltip: 'Clear',
                  icon: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: AppColors.textDisabled,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(searchQueryProvider.notifier).state = '';
                    setState(() {});
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
