import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> signUp(String email, String password, String displayName) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      if (user != null) {
        await user.sendEmailVerification();
        
        UserModel userModel = UserModel(
          uid: user.uid,
          email: email,
          displayName: displayName,
          emailVerified: false,
          createdAt: DateTime.now(),
        );
        
        await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
        return userModel;
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw 'EMAIL_IN_USE: This email is already registered. Please sign in instead.';
        case 'weak-password':
          throw 'Password is too weak. Please use at least 6 characters.';
        case 'invalid-email':
          throw 'Please enter a valid email address.';
        default:
          throw 'Sign up failed: ${e.message}';
      }
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
    return null;
  }

  Future<UserModel?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      if (user != null) {
        if (!user.emailVerified) {
          throw 'Please verify your email before signing in';
        }
        
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return UserModel.fromMap(doc.data() as Map<String, dynamic>);
        }
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw 'USER_NOT_FOUND: No account found with this email. Please sign up first.';
        case 'wrong-password':
          throw 'WRONG_PASSWORD: Incorrect password. Please try again or reset your password.';
        case 'invalid-credential':
          throw 'INVALID_CREDENTIAL: Don\'t have an account? Sign up now or check your password if you already have one.';
        case 'invalid-email':
          throw 'Please enter a valid email address.';
        case 'user-disabled':
          throw 'This account has been disabled. Please contact support.';
        case 'too-many-requests':
          throw 'Too many failed attempts. Please try again later.';
        default:
          throw 'INVALID_CREDENTIAL: ${e.message}';
      }
    } catch (e) {
      if (e.toString().contains('verify your email')) {
        rethrow;
      }
      throw 'An unexpected error occurred. Please try again.';
    }
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendEmailVerification() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<UserModel?> getCurrentUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    }
    return null;
  }
}