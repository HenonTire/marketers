class ReferralLink {
  const ReferralLink({required this.id, required this.code, required this.isActive});
  final String id;
  final String code;
  final bool isActive;

  String urlFor(String shopDomain) => 'https://$shopDomain/?ref=$code';
}

class ReferralLinkMapper {
  static ReferralLink fromJson(Map<String, dynamic> json) => ReferralLink(
        id: json['id']?.toString() ?? '',
        code: json['code']?.toString() ?? '',
        isActive: json['is_active'] == true,
      );
}