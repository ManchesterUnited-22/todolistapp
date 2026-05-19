import 'viewmodel_base.dart';

class LoginViewModel extends ViewModel {
  final String uid;
  final String email;
  final String password;
  final String provider;

  LoginViewModel({
    required this.uid,
    required this.email,
    required this.password,
    required this.provider,
  });

  factory LoginViewModel.fromMap(Map<String, dynamic> map) {
    return LoginViewModel(
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      password: map['password'] as String? ?? '',
      provider: map['provider'] as String? ?? 'email_password',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'password': password,
      'provider': provider,
    };
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'uid': uid,
      'email': email,
      'password': password,
      'provider': provider,
      'loginAt': DateTime.now().toUtc().toIso8601String(),
    };
  }

  LoginViewModel copyWith({
    String? uid,
    String? email,
    String? password,
    String? provider,
  }) {
    return LoginViewModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      password: password ?? this.password,
      provider: provider ?? this.provider,
    );
  }
}
