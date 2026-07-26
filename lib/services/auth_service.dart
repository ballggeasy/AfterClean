import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

/// จัดการ authentication แบบ local ล้วน ๆ ด้วย SharedPreferences
/// ผู้ใช้ทั้งหมดถูกเก็บเป็น JSON map (email -> user json) ภายใต้ key เดียว
/// รหัสผ่านถูก hash ด้วย SHA-256 ก่อนเก็บเสมอ ไม่เก็บ plain text
///
/// หมายเหตุ: นี่คือระบบจำลองสำหรับใช้งานแบบ local/offline เท่านั้น
/// ไม่เหมาะกับ production จริงที่ต้องมี backend และการเข้ารหัสที่ปลอดภัยกว่านี้
class AuthService {
  static const _usersKey = 'auth_users';
  static const _sessionKey = 'auth_current_session_email';

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<Map<String, dynamic>> _readAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) return {};
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> _writeAllUsers(Map<String, dynamic> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  /// ผลลัพธ์: null ถ้าสำเร็จ, หรือ error message ถ้าไม่สำเร็จ
  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final users = await _readAllUsers();

    if (users.containsKey(normalizedEmail)) {
      return 'อีเมลนี้ถูกใช้งานแล้ว';
    }

    final user = AppUser(
      email: normalizedEmail,
      passwordHash: _hashPassword(password),
      name: name.trim(),
    );

    users[normalizedEmail] = user.toJson();
    await _writeAllUsers(users);
    await _setSession(normalizedEmail);
    return null;
  }

  /// ผลลัพธ์: null ถ้าสำเร็จ, หรือ error message ถ้าไม่สำเร็จ
  Future<String?> login({required String email, required String password}) async {
    final normalizedEmail = email.trim().toLowerCase();
    final users = await _readAllUsers();
    final userJson = users[normalizedEmail];

    if (userJson == null) {
      return 'ไม่พบบัญชีผู้ใช้นี้';
    }

    final user = AppUser.fromJson(userJson as Map<String, dynamic>);
    if (user.passwordHash != _hashPassword(password)) {
      return 'รหัสผ่านไม่ถูกต้อง';
    }

    await _setSession(normalizedEmail);
    return null;
  }

  Future<void> _setSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, email);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  /// เรียกตอนเปิดแอป เพื่อดูว่ามี session ค้างอยู่ไหม (auto-login)
  Future<AppUser?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_sessionKey);
    if (email == null) return null;
    final users = await _readAllUsers();
    final userJson = users[email];
    if (userJson == null) return null;
    return AppUser.fromJson(userJson as Map<String, dynamic>);
  }

  bool userExists(Map<String, dynamic> users, String email) =>
      users.containsKey(email.trim().toLowerCase());

  Future<bool> checkUserExists(String email) async {
    final users = await _readAllUsers();
    return userExists(users, email);
  }

  /// ใช้สำหรับหน้า "ลืมรหัสผ่าน" — จำลองการตั้งรหัสผ่านใหม่โดยตรง
  /// (ในระบบจริงต้องส่งอีเมลยืนยันตัวตนก่อน แต่แอปนี้ทำงานแบบ local ไม่มีเซิร์ฟเวอร์ส่งอีเมล)
  Future<String?> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final users = await _readAllUsers();
    final userJson = users[normalizedEmail];
    if (userJson == null) return 'ไม่พบบัญชีผู้ใช้นี้';

    final user = AppUser.fromJson(userJson as Map<String, dynamic>);
    final updated = user.copyWith(passwordHash: _hashPassword(newPassword));
    users[normalizedEmail] = updated.toJson();
    await _writeAllUsers(users);
    return null;
  }

  Future<String?> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final users = await _readAllUsers();
    final userJson = users[normalizedEmail];
    if (userJson == null) return 'ไม่พบบัญชีผู้ใช้นี้';

    final user = AppUser.fromJson(userJson as Map<String, dynamic>);
    if (user.passwordHash != _hashPassword(currentPassword)) {
      return 'รหัสผ่านปัจจุบันไม่ถูกต้อง';
    }

    final updated = user.copyWith(passwordHash: _hashPassword(newPassword));
    users[normalizedEmail] = updated.toJson();
    await _writeAllUsers(users);
    return null;
  }

  Future<AppUser> updateProfile({
    required String email,
    String? name,
    String? profileImagePath,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final users = await _readAllUsers();
    final userJson = users[normalizedEmail]!;
    final user = AppUser.fromJson(userJson as Map<String, dynamic>);
    final updated = user.copyWith(name: name, profileImagePath: profileImagePath);
    users[normalizedEmail] = updated.toJson();
    await _writeAllUsers(users);
    return updated;
  }

  Future<void> deleteAccount(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    final users = await _readAllUsers();
    users.remove(normalizedEmail);
    await _writeAllUsers(users);
    await logout();
  }
}