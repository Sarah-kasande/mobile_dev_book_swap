import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = true; // Start with loading true
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser != null && firebaseUser.emailVerified) {
        // Only allow login with verified email
        _user = await _authService.getCurrentUserData();
        print('AuthProvider: User logged in - ${_user?.email}, verified: ${firebaseUser.emailVerified}');
      } else {
        _user = null;
        if (firebaseUser != null && !firebaseUser.emailVerified) {
          print('AuthProvider: User email not verified');
        } else {
          print('AuthProvider: User logged out');
        }
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> signUp(String email, String password, String displayName) async {
    try {
      _setLoading(true);
      _error = null;
      
      UserModel? user = await _authService.signUp(email, password, displayName);
      if (user != null) {
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _error = null;
      
      UserModel? user = await _authService.signIn(email, password);
      if (user != null) {
        _user = user;
        _setLoading(false);
        notifyListeners();
        return true;
      }
      _setLoading(false);
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}