import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseConfig {
  static const String _url =
      'https://hjrntlhdobaewwnenojz.supabase.co';
  static const String _anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhqcm50bGhkb2JhZXd3bmVub2p6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE2NDY0NTQsImV4cCI6MjA3NzIyMjQ1NH0.Uo8zMy_ChbOtJzfnmaKcooadg3rkhmsDztCCfnBQU3E'; // keep your real key here

  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: _url,
        anonKey: _anonKey,
      );

      if (kDebugMode) {
        print('✅ Supabase initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Supabase initialization error: $e');
      }
      rethrow;
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
}
