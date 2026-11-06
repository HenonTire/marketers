import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marketers/models/profile_models.dart';
import 'package:marketers/providers/profile_providers.dart';
import 'package:marketers/service/colors.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(marketerProfileProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: profileAsync.when(
            loading: _loadingUI,
            error: (e, _) => Center(child: Text('Error loading profile', style: TextStyle(color: AppColors.ivory))),
            data: _buildUI,
          ),
        ),
      ),
    );
  }

  Widget _loadingUI() => SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 20),
          _profileSkeleton(),
          const SizedBox(height: 20),
          _sectionHeader('Your stats'),
          SizedBox(height: 94, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: 3, itemBuilder: (_, __) => _statSkeleton())),
          const SizedBox(height: 20),
          _sectionHeader('Shop Settings'),
          _settingsSkeleton(),
        ]),
      );

  Widget _buildUI(MarketerProfile profile) {
    final stats = [(Icons.people, '${profile.clientsCount}', 'Clients'), (Icons.monetization_on, profile.earnings, 'Earnings'), (Icons.star_outline_rounded, profile.rating, 'Rating')];
    final settings = [(Icons.edit_outlined, 'Edit Profile', null), (Icons.account_balance_wallet_outlined, 'Payout Settings', null), (Icons.settings_outlined, 'Settings', null), (Icons.logout_rounded, 'Logout', Colors.redAccent)];
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 20),
        _profileHeader(profile),
        const SizedBox(height: 20),
        _sectionHeader('Your stats'),
        SizedBox(height: 94, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: stats.length, itemBuilder: (context, index) => _statCard(stats[index].$1, stats[index].$2, stats[index].$3))),
        const SizedBox(height: 20),
        _sectionHeader('Shop Settings'),
        ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: settings.length, itemBuilder: (context, index) => _settingsItem(settings[index].$1, settings[index].$2, color: settings[index].$3)),
      ]),
    );
  }

  Widget _profileHeader(MarketerProfile profile) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          CircleAvatar(radius: 28, backgroundColor: AppColors.surface, child: Icon(Icons.person, color: AppColors.ivory, size: 30)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(profile.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Text(profile.role, style: TextStyle(color: AppColors.ivory, fontSize: 13)),
          ])),
          IconButton(onPressed: () {}, icon: Icon(Icons.edit_outlined, color: AppColors.silverMist, size: 22)),
        ]),
      );

  Widget _sectionHeader(String title) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),
        Divider(color: AppColors.divider, thickness: 1, indent: 8, endIndent: 8, height: 30),
      ]);

  Widget _statCard(IconData icon, String value, String label) => Container(
        width: 130,
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: AppColors.silverMist, size: 22),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: AppColors.textDisabled, fontSize: 10)),
        ]),
      );

  Widget _settingsItem(IconData icon, String label, {Color? color}) => ListTile(
        leading: Icon(icon, color: color ?? AppColors.ivory, size: 22),
        title: Text(label, style: TextStyle(color: color ?? Colors.white, fontSize: 15)),
        trailing: Icon(Icons.chevron_right_rounded, color: color ?? AppColors.textSecondary, size: 24),
        onTap: () {},
        horizontalTitleGap: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      );

  Widget _profileSkeleton() => Container(height: 96, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)));
  Widget _statSkeleton() => Container(width: 130, margin: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)));
  Widget _settingsSkeleton() => Column(children: List.generate(3, (_) => Container(height: 58, margin: const EdgeInsets.only(bottom: 4), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)))));
}
