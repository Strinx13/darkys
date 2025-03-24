import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:proy/db_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  int? _userId;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  bool _rememberMe = false;

  bool get isLoggedIn => _userId != null;
  int? get userId => _userId;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  bool get rememberMe => _rememberMe;

  AppState() {
    _loadSavedSession();
  }

  Future<void> _loadSavedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUserId = prefs.getInt('userId');
      final savedEmail = prefs.getString('userEmail');
      final savedRememberMe = prefs.getBool('rememberMe') ?? false;

      if (savedUserId != null && savedEmail != null && savedRememberMe) {
        _userId = savedUserId;
        _rememberMe = savedRememberMe;
        await updateUserData();
        notifyListeners();
      }
    } catch (e) {
      print('Error cargando sesión guardada: $e');
    }
  }

  Future<void> _saveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe && _userId != null && _userData != null) {
        await prefs.setInt('userId', _userId!);
        await prefs.setString('userEmail', _userData!['email']);
        await prefs.setBool('rememberMe', true);
      } else {
        await prefs.remove('userId');
        await prefs.remove('userEmail');
        await prefs.setBool('rememberMe', false);
      }
    } catch (e) {
      print('Error guardando sesión: $e');
    }
  }

  Future<bool> login(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    _isLoading = true;
    _rememberMe = rememberMe;
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
        await _saveSession();
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
    _rememberMe = false;
    await _saveSession();
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
