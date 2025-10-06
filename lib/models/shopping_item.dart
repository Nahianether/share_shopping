import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingItem {
  final String id;
  final String name;
  final bool isDone;
  final String addedBy;
  final DateTime createdAt;
  final DateTime? completedAt;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.isDone,
    required this.addedBy,
    required this.createdAt,
    this.completedAt,
  });

  // Convert Firestore document to ShoppingItem
  factory ShoppingItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShoppingItem(
      id: doc.id,
      name: data['name'] ?? '',
      isDone: data['isDone'] ?? false,
      addedBy: data['addedBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Convert ShoppingItem to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'isDone': isDone,
      'addedBy': addedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  // Create a copy with updated fields
  ShoppingItem copyWith({
    String? id,
    String? name,
    bool? isDone,
    String? addedBy,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      isDone: isDone ?? this.isDone,
      addedBy: addedBy ?? this.addedBy,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
