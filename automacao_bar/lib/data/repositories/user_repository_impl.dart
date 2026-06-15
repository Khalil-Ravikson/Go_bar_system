import 'package:drift/drift.dart';
import '../../core/database/app_database.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements IUserRepository {
  final AppDatabase _db;

  UserRepositoryImpl(this._db);

  @override
  Stream<List<User>> watchUsers() {
    return (_db.select(_db.users)..where((t) => t.isActive.equals(true))).watch();
  }

  @override
  Future<List<User>> getUsers() {
    return (_db.select(_db.users)..where((t) => t.isActive.equals(true))).get();
  }

  @override
  Future<User?> getUserById(String id) {
    return (_db.select(_db.users)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  @override
  Future<User?> getUserByPin(String pin) {
    return (_db.select(_db.users)..where((t) => t.pinHash.equals(pin))).getSingleOrNull();
  }

  @override
  Future<int> insertUser(User user) {
    return _db.into(_db.users).insert(user);
  }

  @override
  Future<bool> updateUser(User user) {
    return _db.update(_db.users).replace(user);
  }

  @override
  Future<int> deleteUser(String id) {
    return (_db.delete(_db.users)..where((t) => t.id.equals(id))).go();
  }
}
