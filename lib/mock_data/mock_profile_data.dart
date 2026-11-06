import 'package:marketers/models/profile_models.dart';

class MockProfileData {
  MockProfileData._();

  /// The existing MarketerProfile UI model does not include avatar, email,
  /// phone, or join date; those remain backend-ready but intentionally absent here.
  static const profile = MarketerProfile(
    name: 'Selamawit Desta',
    role: 'Marketing Partner',
    clientsCount: 28,
    earnings: 'KES 48,750',
    rating: '4.9',
  );
}
