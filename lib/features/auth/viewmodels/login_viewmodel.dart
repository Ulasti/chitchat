import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginViewModel extends ChangeNotifier {
  late IO.Socket _socket;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isChecked = false;
  String _savedUsername = '';

  IO.Socket get socket => _socket;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isChecked => _isChecked;
  String get savedUsername => _savedUsername;

  static const String baseUrl = 'http://192.168.1.162:3000';

  LoginViewModel() {
    _loadSavedData();
  }

  set isChecked(bool value) {
    _isChecked = value;
    notifyListeners();
  }

  void setChecked(bool value) {
    _isChecked = value;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    _isChecked = prefs.getBool('remember_me') ?? false;
    _savedUsername = prefs.getString('saved_username') ?? '';
    notifyListeners();
  }

  Future<void> _saveUserData(String username) async {
    final prefs = await SharedPreferences.getInstance();
    if (_isChecked) {
      await prefs.setBool('remember_me', true);
      await prefs.setString('saved_username', username);
      _savedUsername = username;
    } else {
      await prefs.remove('remember_me');
      await prefs.remove('saved_username');
      _savedUsername = '';
    }
  }

  Future<bool> checkSavedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final remembeMe = prefs.getBool('remember_me') ?? false;
    final savedUsername = prefs.getString('saved_username') ?? '';

    if (remembeMe && savedUsername.isNotEmpty) {
      _savedUsername = savedUsername;
      _isChecked = true;

      return await loginUser(savedUsername, autoLogin: true);
    }
    return false;
  }

  Future<bool> registerUser(String username) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 400) {
        // User already exists
        return true;
      } else {
        _setError('Registration failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _setError('Network error: $e');
      return false;
    }
  }

  Future<bool> connectSocket(String username) async {
    try {
      _socket = IO.io(baseUrl, <String, dynamic>{
        'transports': ['websocket'],
      });

      final completer = Completer<bool>();
      bool isCompleted = false;

      _socket.onConnect((_) {
        _socket.emit('login', username);
        if (!isCompleted) {
          isCompleted = true;
          completer.complete(true);
        }
      });

      _socket.onConnectError((error) {
        _setError('Failed to connect to chat server');
        if (!isCompleted) {
          isCompleted = true;
          completer.complete(false);
        }
      });

      // Timeout after 10 seconds
      Timer(Duration(seconds: 10), () {
        if (!isCompleted) {
          isCompleted = true;
          completer.complete(false);
        }
      });

      return completer.future;
    } catch (e) {
      _setError('Socket connection failed: $e');
      return false;
    }
  }

  Future<bool> loginUser(String username, {bool autoLogin = false}) async {
    if (!autoLogin) {
      _setLoading(true);
      _setError(null);
    }

    try {
      // Register user first (handles both new and existing users)
      final registered = await registerUser(username);
      if (!registered) return false;

      // Connect to socket
      final connected = await connectSocket(username);
      if (!connected) return false;

      // Save user data if checkbox is checked
      await _saveUserData(username);

      return true;
    } catch (e) {
      _setError('Login failed: $e');
      return false;
    } finally {
      if (!autoLogin) {
        _setLoading(false);
      }
    }
  }

  Future<void> clearSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('remember_me');
    await prefs.remove('saved_username');
    _isChecked = false;
    _savedUsername = '';

    if (_socket.connected) {
      _socket.disconnect();
    }

    notifyListeners();
  }

  @override
  void dispose() {
    if (_socket.connected) {
      _socket.disconnect();
    }
    super.dispose();
  }
}
