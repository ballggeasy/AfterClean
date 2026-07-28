import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'providers/recipe_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const RecipeApp());
}

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..init()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'สูตรอาหาร',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const _AuthGate(),
          );
        },
      ),
    );
  }
}

/// ตรวจสอบ session ที่ค้างอยู่ตอนเปิดแอป แล้วพาไปหน้าที่เหมาะสม
///
/// นี่คือจุดเดียวที่คอย sync รายการ favorites ให้ตรงกับผู้ใช้ที่ล็อกอินอยู่:
/// ทุกครั้งที่ auth เปลี่ยน (ล็อกอิน, สมัครสมาชิก, guest, ล็อกเอาต์, auto-login ตอนเปิดแอป)
/// จะโหลด favorites ของ key นั้นใหม่ ป้องกันไม่ให้ favorites ของบัญชีหนึ่งไปติดกับอีกบัญชี
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  String? _lastSyncedKey = 'unset';

  void _syncFavoritesIfNeeded(AuthProvider auth) {
    String? key;
    if (auth.status == AuthStatus.loggedIn) {
      key = auth.currentUser?.email;
    } else if (auth.status == AuthStatus.guest) {
      key = 'guest';
    } else {
      // unknown หรือ loggedOut ยังไม่ต้อง sync
      return;
    }

    if (key == _lastSyncedKey) return;
    _lastSyncedKey = key;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<RecipeProvider>().loadFavoritesForUser(key);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    _syncFavoritesIfNeeded(auth);

    if (auth.status == AuthStatus.unknown) {
      return Scaffold(
        backgroundColor: AppTheme.bg(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (auth.status == AuthStatus.loggedIn || auth.status == AuthStatus.guest) {
      return const HomeScreen();
    }

    return const LoginScreen();
  }
}
