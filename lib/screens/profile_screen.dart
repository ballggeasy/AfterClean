import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.accentRed : AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _pickImage() async {
    // หมายเหตุ: image_picker รองรับ Android/iOS/web โดยตรง
    // สำหรับ Windows desktop อาจต้องใช้แพ็กเกจ file_selector แทน
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    await context.read<AuthProvider>().updateProfile(profileImagePath: picked.path);
    if (!mounted) return;
    _showMessage('อัปเดตรูปโปรไฟล์แล้ว');
  }

  Future<void> _editName(String currentName) async {
    final controller = TextEditingController(text: currentName);
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('แก้ไขชื่อ'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('ยกเลิก')),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      await context.read<AuthProvider>().updateProfile(name: newName);
      if (!mounted) return;
      _showMessage('อัปเดตชื่อแล้ว');
    }
  }

  Future<void> _changePassword() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('เปลี่ยนรหัสผ่าน'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'รหัสผ่านปัจจุบัน'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'รหัสผ่านใหม่'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('ยกเลิก')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('บันทึก')),
        ],
      ),
    );

    if (confirmed != true) return;
    if (newController.text.length < 6) {
      _showMessage('รหัสผ่านใหม่ต้องมีอย่างน้อย 6 ตัวอักษร', isError: true);
      return;
    }

    final error = await context.read<AuthProvider>().changePassword(
          currentPassword: currentController.text,
          newPassword: newController.text,
        );

    if (!mounted) return;
    if (error != null) {
      _showMessage(error, isError: true);
    } else {
      _showMessage('เปลี่ยนรหัสผ่านสำเร็จ');
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ลบบัญชี'),
        content: const Text('การลบบัญชีไม่สามารถย้อนกลับได้ และข้อมูลทั้งหมดจะถูกลบทิ้ง คุณแน่ใจหรือไม่?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('ยกเลิก')),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('ลบบัญชี', style: TextStyle(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await context.read<AuthProvider>().deleteAccount();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = auth.currentUser;

    if (user == null) {
      // โหมด guest — ไม่มีบัญชีให้แสดง
      return Scaffold(
        appBar: AppBar(title: const Text('โปรไฟล์')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('👤', style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text('คุณกำลังใช้งานแบบผู้เยี่ยมชม', style: TextStyle(color: AppTheme.txtSecondary(context))),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                ),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.prim(context), foregroundColor: Colors.white),
                child: const Text('เข้าสู่ระบบ'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('โปรไฟล์')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppTheme.primLight(context),
                    backgroundImage: user.profileImagePath != null
                        ? FileImage(File(user.profileImagePath!))
                        : null,
                    child: user.profileImagePath == null
                        ? Icon(Icons.person, size: 48, color: AppTheme.prim(context))
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.prim(context),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.surf(context), width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              user.name,
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: AppTheme.txtPrimary(context)),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(user.email, style: TextStyle(fontSize: 13.5, color: AppTheme.txtSecondary(context))),
          ),
          const SizedBox(height: 32),
          _SectionCard(
            children: [
              _ProfileTile(
                icon: Icons.edit_outlined,
                label: 'แก้ไขชื่อ',
                onTap: () => _editName(user.name),
              ),
              _ProfileTile(
                icon: Icons.lock_reset_rounded,
                label: 'เปลี่ยนรหัสผ่าน',
                onTap: _changePassword,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            children: [
              SwitchListTile(
                secondary: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                  color: AppTheme.txtSecondary(context),
                ),
                title: Text('โหมดมืด', style: TextStyle(fontSize: 14.5, color: AppTheme.txtPrimary(context))),
                value: themeProvider.isDarkMode,
                activeColor: AppTheme.prim(context),
                onChanged: (value) => themeProvider.toggleTheme(value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            children: [
              _ProfileTile(
                icon: Icons.logout_rounded,
                label: 'ออกจากระบบ',
                onTap: _logout,
              ),
              _ProfileTile(
                icon: Icons.delete_outline_rounded,
                label: 'ลบบัญชี',
                labelColor: AppTheme.accentRed,
                onTap: _deleteAccount,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.div(context)),
      ),
      child: Column(children: children),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? labelColor;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: labelColor ?? AppTheme.txtSecondary(context)),
      title: Text(
        label,
        style: TextStyle(fontSize: 14.5, color: labelColor ?? AppTheme.txtPrimary(context)),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.txtSecondary(context)),
      onTap: onTap,
    );
  }
}