import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/shopping_item.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference for shopping items
  static const String _shoppingListCollection = 'shopping_list';

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in anonymously with a display name
  Future<UserCredential> signInAnonymously(String displayName) async {
    final userCredential = await _auth.signInAnonymously();
    await userCredential.user?.updateDisplayName(displayName);
    return userCredential;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get shopping items as a stream (real-time updates)
  // Optimized: Only fetches incomplete items and recently completed items
  Stream<List<ShoppingItem>> getShoppingItems() {
    final twentyFourHoursAgo = DateTime.now().subtract(const Duration(hours: 24));

    return _firestore
        .collection(_shoppingListCollection)
        .where('createdAt', isGreaterThan: Timestamp.fromDate(twentyFourHoursAgo.subtract(const Duration(days: 7)))) // Only fetch items from last 7 days
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      // Filter out completed items older than 24 hours (client-side for optimization)
      final now = DateTime.now();
      return snapshot.docs
          .map((doc) => ShoppingItem.fromFirestore(doc))
          .where((item) {
            if (!item.isDone) return true; // Keep all incomplete items
            if (item.completedAt == null) return true;
            final hoursSinceComplete = now.difference(item.completedAt!).inHours;
            return hoursSinceComplete < 24; // Keep completed items less than 24 hours old
          })
          .toList();
    });
  }

  // Clean up completed items older than 24 hours
  // Simplified: Fetch all completed items and filter client-side (avoids index requirement)
  Future<void> cleanupOldCompletedItems() async {
    final twentyFourHoursAgo = DateTime.now().subtract(const Duration(hours: 24));

    final snapshot = await _firestore
        .collection(_shoppingListCollection)
        .where('isDone', isEqualTo: true)
        .get();

    // Filter and delete old items
    final batch = _firestore.batch();
    int deleteCount = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final completedAt = data['completedAt'] as Timestamp?;

      if (completedAt != null) {
        final completedDate = completedAt.toDate();
        if (completedDate.isBefore(twentyFourHoursAgo)) {
          batch.delete(doc.reference);
          deleteCount++;
        }
      }
    }

    if (deleteCount > 0) {
      await batch.commit();
    }
  }

  // Add a new shopping item
  Future<void> addShoppingItem(String itemName) async {
    final user = currentUser;
    if (user == null) throw Exception('User not signed in');

    final item = ShoppingItem(
      id: '',
      name: itemName,
      isDone: false,
      addedBy: user.displayName ?? 'Unknown',
      createdAt: DateTime.now(),
    );

    await _firestore.collection(_shoppingListCollection).add(item.toFirestore());
  }

  // Toggle item completion status
  Future<void> toggleItemStatus(String itemId, bool currentStatus) async {
    final newStatus = !currentStatus;
    await _firestore.collection(_shoppingListCollection).doc(itemId).update({
      'isDone': newStatus,
      'completedAt': newStatus ? Timestamp.now() : null,
    });
  }

  // Delete a shopping item
  Future<void> deleteShoppingItem(String itemId) async {
    await _firestore.collection(_shoppingListCollection).doc(itemId).delete();
  }

  // Update shopping item name
  Future<void> updateShoppingItem(String itemId, String newName) async {
    await _firestore.collection(_shoppingListCollection).doc(itemId).update({
      'name': newName,
    });
  }
}
