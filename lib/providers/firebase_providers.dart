import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/shopping_item.dart';
import '../models/app_theme.dart';
import '../services/firebase_service.dart';
import '../services/theme_service.dart';
import '../services/hive_database_service.dart';

// Services providers
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

final hiveDatabaseServiceProvider = Provider<HiveDatabaseService>((ref) {
  return HiveDatabaseService();
});

final themeServiceProvider = Provider<ThemeService>((ref) {
  final hiveService = ref.watch(hiveDatabaseServiceProvider);
  return ThemeService(hiveService);
});

// Theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, AppTheme>((ref) {
  return ThemeNotifier(ref.read(themeServiceProvider));
});

class ThemeNotifier extends StateNotifier<AppTheme> {
  final ThemeService _themeService;

  ThemeNotifier(this._themeService) : super(AppTheme(type: ThemeType.light)) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    state = await _themeService.getTheme();
  }

  Future<void> toggleTheme() async {
    final newTheme = AppTheme(
      type: state.isDark ? ThemeType.light : ThemeType.dark,
    );
    await _themeService.saveTheme(newTheme);
    state = newTheme;
  }
}

// Current user provider
final currentUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Shopping items stream provider with local caching
final shoppingItemsProvider = StreamProvider<List<ShoppingItem>>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  final hiveDb = ref.watch(hiveDatabaseServiceProvider);

  return firebaseService.getShoppingItems().asyncMap((items) async {
    // Cache items locally
    await hiveDb.cacheItems(items);
    return items;
  });
});

// Cached items provider (for offline access)
final cachedItemsProvider = Provider<List<ShoppingItem>>((ref) {
  final hiveDb = ref.watch(hiveDatabaseServiceProvider);
  return hiveDb.getCachedItems();
});
