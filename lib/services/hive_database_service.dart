import 'package:hive_flutter/hive_flutter.dart';
import '../models/shopping_item.dart';

class HiveDatabaseService {
  static const String _shoppingBoxName = 'shopping_items';
  static const String _themeBoxName = 'app_settings';

  Box<ShoppingItem>? _shoppingBox;
  Box? _settingsBox;

  // Initialize Hive and open boxes
  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ShoppingItemAdapter());
    }

    // Open boxes
    _shoppingBox = await Hive.openBox<ShoppingItem>(_shoppingBoxName);
    _settingsBox = await Hive.openBox(_themeBoxName);
  }

  // Shopping Items methods
  Future<void> cacheItems(List<ShoppingItem> items) async {
    if (_shoppingBox == null) await init();

    // Clear existing items
    await _shoppingBox!.clear();

    // Add new items
    for (final item in items) {
      await _shoppingBox!.put(item.id, item);
    }
  }

  List<ShoppingItem> getCachedItems() {
    if (_shoppingBox == null) return [];
    return _shoppingBox!.values.toList();
  }

  Future<void> clearShoppingCache() async {
    if (_shoppingBox == null) await init();
    await _shoppingBox!.clear();
  }

  // Theme settings methods
  Future<void> saveTheme(String theme) async {
    if (_settingsBox == null) await init();
    await _settingsBox!.put('theme', theme);
  }

  String? getTheme() {
    if (_settingsBox == null) return null;
    return _settingsBox!.get('theme') as String?;
  }

  // Close all boxes
  Future<void> close() async {
    await _shoppingBox?.close();
    await _settingsBox?.close();
  }

  // Clear all data
  Future<void> clearAll() async {
    await clearShoppingCache();
    await _settingsBox?.clear();
  }
}
