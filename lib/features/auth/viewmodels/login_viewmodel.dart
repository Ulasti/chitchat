import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';

class LoginViewModel extends ChangeNotifier {
  late IO.Socket _socket;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  IO.Socket get socket => _socket;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // API Base URL - could be moved to a config file
  static const String baseUrl = 'http://192.168.1.162:3000';

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<bool> registerUser(String username) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      if (response.statusCode == 200) {
        print('User registered successfully');
        return true;
      } else if (response.statusCode == 400) {
        print('Welcome back, $username!');
        return true; // User exists, but can still login
      } else {
        _setError('Unexpected error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _setError('Network error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> connectSocket(String username) async {
    try {
      _socket = IO.io(baseUrl, <String, dynamic>{
        'transports': ['websocket'],
      });

      // Return a future that completes when socket connects
      final completer = Completer<bool>();

      _socket.onConnect((_) {
        print('Socket connected');
        _socket.emit('login', username);
        completer.complete(true);
      });

      _socket.onConnectError((error) {
        print('Socket connection error: $error');
        _setError('Failed to connect to chat server');
        completer.complete(false);
      });

      _socket.on('user_list', (data) {
        print('User list: $data');
      });

      return completer.future;
    } catch (e) {
      _setError('Socket connection failed: $e');
      return false;
    }
  }

  Future<bool> loginUser(String username) async {
    // Register user first
    final registered = await registerUser(username);
    if (!registered) return false;

    // Then connect socket
    final connected = await connectSocket(username);
    return connected;
  }

  void clearError() {
    _setError(null);
  }

  @override
  void dispose() {
    if (_socket.connected) {
      _socket.disconnect();
    }
    super.dispose();
  }
}
