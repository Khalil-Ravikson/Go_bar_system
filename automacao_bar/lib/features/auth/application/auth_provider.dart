import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:automacao_bar/core/providers/repository_providers.dart';

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

class AuthNotifier extends Notifier<UserSession?> {
  @override
  UserSession? build() {
    // Starts unauthenticated (null) to force simple login on boot
    return null;
  }

  Future<bool> login(String name, String pin) async {
    final repo = ref.read(userRepositoryProvider);
    final users = await repo.getUsers();
    
    // Simple verification (find user by name and matching PIN)
    final match = users.where((u) => u.name.toLowerCase() == name.toLowerCase() && u.pinHash == pin);
    if (match.isNotEmpty) {
      final user = match.first;
      final role = UserRole.values.firstWhere(
        (e) => e.name == user.role,
        orElse: () => UserRole.waiter,
      );
      state = UserSession(
        name: user.name,
        role: role,
        token: 'session-${user.id}',
      );
      return true;
    }
    return false;
  }

  Future<bool> loginByPin(String pin) async {
    final repo = ref.read(userRepositoryProvider);
    final users = await repo.getUsers();
    final match = users.where((u) => u.pinHash == pin);
    if (match.isNotEmpty) {
      final user = match.first;
      final role = UserRole.values.firstWhere(
        (e) => e.name == user.role,
        orElse: () => UserRole.waiter,
      );
      state = UserSession(
        name: user.name,
        role: role,
        token: 'session-${user.id}',
      );
      return true;
    }
    return false;
  }

  void logout() {
    state = null;
  }

  void changeRole(UserRole newRole) {
    if (state == null) return;
    String newName = state!.name;
    if (newRole == UserRole.waiter) {
      newName = 'Pedro Silva (Garçom)';
    } else if (newRole == UserRole.chef) {
      newName = 'Chef André (Cozinha)';
    } else if (newRole == UserRole.caixa) {
      newName = 'Caixa Principal';
    } else {
      newName = 'João Oliveira (Admin)';
    }

    state = UserSession(
      name: newName,
      role: newRole,
      token: 'session-${newRole.name}',
    );
  }
}

final authProvider = NotifierProvider<AuthNotifier, UserSession?>(() {
  return AuthNotifier();
});



