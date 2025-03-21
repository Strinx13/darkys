import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:proy/db_connection.dart';

class AppState extends ChangeNotifier {
  int? _userId;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;

  bool get isLoggedIn => _userId != null;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.connect();
      var results = await conn.query(
        'SELECT id, name, email, phone, avatar FROM ec_customers WHERE email = ?',
        [email],
      );

      if (results.isNotEmpty) {
        _userId = results.first['id'];
        _userData = {
          'name': results.first['name'],
          'email': results.first['email'],
          'phone': results.first['phone'],
          'avatar': results.first['avatar'],
        };
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error en login: $e');
      return false;
    } finally {
      await conn?.close();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _userId = null;
    _userData = null;
    notifyListeners();
  }

  Future<void> updateUserData() async {
    if (_userId == null) return;

    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.connect();
      var results = await conn.query(
        'SELECT name, email, phone, avatar FROM ec_customers WHERE id = ?',
        [_userId],
      );

      if (results.isNotEmpty) {
        _userData = {
          'name': results.first['name'],
          'email': results.first['email'],
          'phone': results.first['phone'],
          'avatar': results.first['avatar'],
        };
        notifyListeners();
      }
    } catch (e) {
      print('Error al actualizar datos del usuario: $e');
    } finally {
      await conn?.close();
    }
  }
}
