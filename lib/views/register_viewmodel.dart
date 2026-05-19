import 'viewmodel_base.dart';

class RegisterViewModel extends ViewModel {
  final String uid;
  final String name;
  final String displayName;
  final String email;
  final String password;
  final String confirmPassword;

  RegisterViewModel({
    required this.uid,
    required this.name,
    this.displayName = '',
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  factory RegisterViewModel.fromMap(Map<String, dynamic> map) {
    return RegisterViewModel(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      password: map['password'] as String? ?? '',
      confirmPassword: map['confirmPassword'] as String? ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'displayName': displayName,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
    };
  }

  Map<String, dynamic> toFirestoreMap({required String uidValue}) {
    return {
      'uid': uidValue,
      'fullName': name,
      'displayName': displayName,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    };
  }

  RegisterViewModel copyWith({
    String? uid,
    String? name,
    String? displayName,
    String? email,
    String? password,
    String? confirmPassword,
  }) {
    return RegisterViewModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }
}
