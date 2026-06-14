import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserRole {
  admin,
  waiter,
  chef,
  caixa,
}

class UserSession {
  final String name;
  final UserRole role;
  final String token;

  const UserSession({
    required this.name,
    required this.role,
    required this.token,
  });

  UserSession copyWith({
    String? name,
    UserRole? role,
    String? token,
  }) {
    return UserSession(
      name: name ?? this.name,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }
}

class AuthNotifier extends Notifier<UserSession> {
  @override
  UserSession build() {
    // Default session: Administrator (João Oliveira)
    return const UserSession(
      name: 'João Oliveira',
      role: UserRole.admin,
      token: 'admin-session-token-123',
    );
  }

  void changeRole(UserRole newRole) {
    String newName = state.name;
    if (newRole == UserRole.waiter) {
      newName = 'Pedro Silva (Garçom)';
    } else if (newRole == UserRole.chef) {
      newName = 'Chef André (Cozinha)';
    } else {
      newName = 'João Oliveira (Admin)';
    }
    
    state = state.copyWith(
      role: newRole,
      name: newName,
    );
  }
}

final authProvider = NotifierProvider<AuthNotifier, UserSession>(() {
  return AuthNotifier();
});
