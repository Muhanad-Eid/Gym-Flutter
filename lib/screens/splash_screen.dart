import 'package:flutter/material.dart';
import 'package:gym/supabaseconfig.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Supabase is already initialized by AppInitializer
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      final session = SupabaseConfig.client.auth.currentSession;
      
      if (mounted) {
        if (session != null) {
          print('✅ User is logged in');
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          print('ℹ️ No session, going to sign in');
          Navigator.pushReplacementNamed(context, '/sign_in');
        }
      }
    } catch (e) {
      print('⚠️ Error checking auth: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/sign_in');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7C3AED), Color(0xFF9F7AEA)],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}