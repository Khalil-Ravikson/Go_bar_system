import 'package:automacao_bar/core/database/app_database.dart';

abstract class IUserRepository {
  Stream<List<User>> watchUsers();
  Future<List<User>> getUsers();
  Future<User?> getUserById(String id);
  Future<User?> getUserByPin(String pin);
  Future<int> insertUser(User user);
  Future<bool> updateUser(User user);
  Future<int> deleteUser(String id);
}
