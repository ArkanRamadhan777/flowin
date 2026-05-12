import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  User? get currentUser;
  Stream<AuthState> get authStateChanges;

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  });

  Future<void> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();
}
