import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final _service = AuthService();

  User? _user;
  User? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthController() {
    _service.authStateChanges.listen((newUser) {
      _user = newUser;
      notifyListeners();
    });
  }

  Future<String?> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _service.signInWithGoogle();
      _isLoading = false;
      notifyListeners();
      if (user == null) return "Login cancelado pelo usuário";
      return null; // Sucesso
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return "Falha ao logar: ${e.toString()}";
    }
  }

  Future<void> logout() async {
    await _service.signOut();
  }
}
