import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'providers/firebase_providers.dart';
import 'screens/auth_screen.dart';
import 'screens/shopping_list_screen.dart';
import 'services/hive_database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Hive
  final hiveService = HiveDatabaseService();
  await hiveService.init();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final appTheme = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Shared Shopping List',
      debugShowCheckedModeBanner: false,
      theme: appTheme.themeData,
      themeMode: appTheme.isDark ? ThemeMode.dark : ThemeMode.light,
      home: userAsync.when(
        data: (user) {
          if (user != null) {
            return const ShoppingListScreen();
          }
          return const AuthScreen();
        },
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, stack) => Scaffold(
          body: Center(
            child: Text('Error: $error'),
          ),
        ),
      ),
    );
  }
}
