import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _pinKey = 'user_pin';
  static const _passwordKey = 'user_password';
  final _storage = const FlutterSecureStorage();

  Future<void> savePin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
  }

  Future<void> savePassword(String password) async {
    await _storage.write(key: _passwordKey, value: password);
  }

  Future<String?> getPin() async {
    return await _storage.read(key: _pinKey);
  }

  Future<String?> getPassword() async {
    return await _storage.read(key: _passwordKey);
  }

  Future<void> clearAuthData() async {
    await _storage.deleteAll();
  }
}
