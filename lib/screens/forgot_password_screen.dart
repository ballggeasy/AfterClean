import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _emailVerified = false;
  bool _isChecking = false;
  bool _isSaving = false;

  void _showMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.accentRed : AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _checkEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showMessage('กรุณากรอกอีเมลที่ถูกต้อง');
      return;
    }

    setState(() => _isChecking = true);
    final exists = await context.read<AuthProvider>().checkUserExists(email);
    if (!mounted) return;
    setState(() {
      _isChecking = false;
      _emailVerified = exists;
    });

    if (!exists) {
      _showMessage('ไม่พบบัญชีที่ใช้อีเมลนี้');
    }
  }

  Future<void> _resetPassword() async {
    if (_newPasswordController.text.length < 6) {
      _showMessage('รหัสผ่านใหม่ต้องมีอย่างน้อย 6 ตัวอักษร');
      return;
    }

    setState(() => _isSaving = true);
    final error = await context.read<AuthProvider>().resetPassword(
          email: _emailController.text.trim(),
          newPassword: _newPasswordController.text,
        );
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error != null) {
      _showMessage(error);
      return;
    }

    _showMessage('ตั้งรหัสผ่านใหม่สำเร็จ กรุณาเข้าสู่ระบบอีกครั้ง', isError: false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ลืมรหัสผ่าน')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ระบบนี้ทำงานแบบ local บนเครื่องเท่านั้น จึงไม่มีการส่งอีเมลยืนยันจริง '
                'กรอกอีเมลของบัญชีเพื่อรีเซ็ตรหัสผ่านได้โดยตรง',
                style: TextStyle(fontSize: 13, color: AppTheme.txtSecondary(context), height: 1.4),
              ),
              const SizedBox(height: 24),
              Text('อีเมล', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppTheme.txtPrimary(context))),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surf(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.div(context)),
                ),
                child: TextField(
                  controller: _emailController,
                  enabled: !_emailVerified,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(fontSize: 14.5, color: AppTheme.txtPrimary(context)),
                  decoration: InputDecoration(
                    hintText: 'example@email.com',
                    prefixIcon: Icon(Icons.mail_outline_rounded, size: 20, color: AppTheme.txtSecondary(context)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              if (!_emailVerified) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isChecking ? null : _checkEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.prim(context),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isChecking
                        ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                        : const Text('ตรวจสอบอีเมล', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 24),
                Text('รหัสผ่านใหม่', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppTheme.txtPrimary(context))),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surf(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.div(context)),
                  ),
                  child: TextField(
                    controller: _newPasswordController,
                    obscureText: true,
                    style: TextStyle(fontSize: 14.5, color: AppTheme.txtPrimary(context)),
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: Icon(Icons.lock_outline_rounded, size: 20, color: AppTheme.txtSecondary(context)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.prim(context),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                        : const Text('ตั้งรหัสผ่านใหม่', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}