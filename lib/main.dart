import 'package:flutter/material.dart';
import 'package:gym/theme.dart';
import 'package:gym/app_initializer.dart';
import 'routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AppInitializer(),
      routes: routes,
    );
  }
}