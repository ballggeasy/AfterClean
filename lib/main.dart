import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'providers/recipe_provider.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const RecipeApp());
}

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecipeProvider(),
      child: MaterialApp(
        title: 'สูตรอาหาร',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.themeData,
        home: const LoginScreen(),
      ),
    );
  }
}
