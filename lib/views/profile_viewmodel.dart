class ProfileViewModel {
  final String uid;
  final String displayName;
  final String email;
  final String avatarUrl;

  ProfileViewModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.avatarUrl,
  });

  factory ProfileViewModel.fromMap(Map<String, dynamic> map) {
    return ProfileViewModel(
      uid: map['uid'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      avatarUrl: map['avatarUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'avatarUrl': avatarUrl,
    };
  }

  ProfileViewModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? avatarUrl,
  }) {
    return ProfileViewModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
