// lib/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://ongbpearecemcdfundqq.supabase.co';
  static const String supabaseKey =
      'sb_publishable_QS-E-xy5WdhPCsfyyqXpCw_9u-RRF9j';

  static SupabaseClient get client => Supabase.instance.client;
  static User? get currentUser => client.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;

  // Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
  }

  // ─── Owner Login (Email + Password) ───────────
  static Future<AuthResponse> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // ─── Sign Up ───────────────────────────────────
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'role': 'owner'},
    );
  }

  // ─── Forgot Password (Reset Email) ────────────
  static Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'io.supabase.kiranaai://reset-callback/',
    );
  }

  // ─── OTP Login (Phone) ─────────────────────────
  static Future<void> sendPhoneOtp(String phone) async {
    await client.auth.signInWithOtp(phone: phone);
  }

  static Future<AuthResponse> verifyPhoneOtp({
    required String phone,
    required String otp,
  }) async {
    return await client.auth.verifyOTP(
      phone: phone,
      token: otp,
      type: OtpType.sms,
    );
  }

  // ─── Logout ────────────────────────────────────
  static Future<void> logout() async {
    await client.auth.signOut();
  }

  // ─── Auth State Stream ─────────────────────────
  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;
}
