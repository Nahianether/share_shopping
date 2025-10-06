import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/shopping_item.dart';
import '../services/firebase_service.dart';

// Firebase service provider
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

// Current user provider
final currentUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Shopping items stream provider
final shoppingItemsProvider = StreamProvider<List<ShoppingItem>>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.getShoppingItems();
});
