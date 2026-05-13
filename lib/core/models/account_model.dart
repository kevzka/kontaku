class AccountModel {
  final String username;
  final String uid;
  final String profilePath;
  final String phoneNumber;
  final String? email;

  const AccountModel({
    required this.username,
    required this.uid,
    required this.profilePath,
    required this.phoneNumber,
    this.email,
  });

  factory AccountModel.fromFirestoreMap(
    Map<String, dynamic> data, {
    required String fallbackUid,
  }) {
    return AccountModel(
      username: data['username'] as String? ?? 'Unknown',
      uid: data['uid'] as String? ?? fallbackUid,
      profilePath: data['profilePath'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      email: data['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'username': username,
      'uid': uid,
      'profilePath': profilePath,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }
}
