class AccountModel {
  final String username;
  final String uid;
  final String imageProfile;
  final String phoneNumber;
  final String? email;

  const AccountModel({
    required this.username,
    required this.uid,
    required this.imageProfile,
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
      imageProfile: data['imageProfile'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      email: data['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'username': username,
      'uid': uid,
      'imageProfile': imageProfile,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }
}
