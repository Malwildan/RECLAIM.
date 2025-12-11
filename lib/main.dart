import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'data/models/models.dart';

/// Application entry point.
/// Initializes Supabase, Hive (local storage), and Riverpod (state management).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Initialize Hive for local caching
  await Hive.initFlutter();
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(JournalEntryAdapter());
  Hive.registerAdapter(RelapseEntryAdapter());

  // Open Hive boxes
  await Hive.openBox<UserProfile>('profiles');
  await Hive.openBox<JournalEntry>('journals');
  await Hive.openBox<RelapseEntry>('relapses');

  // Run app with Riverpod provider scope
  runApp(const ProviderScope(child: ReclaimApp()));
}
