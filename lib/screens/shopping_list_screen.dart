import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../providers/firebase_providers.dart';
import '../models/shopping_item.dart';

enum SortFilter { dateTime, alphabetical, notDoneFirst, doneFirst }

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  final _itemController = TextEditingController();
  SortFilter _currentFilter = SortFilter.dateTime;

  @override
  void initState() {
    super.initState();
    // Run cleanup when app starts
    Future.microtask(() {
      ref.read(firebaseServiceProvider).cleanupOldCompletedItems();
    });
  }

  Future<void> _addItem() async {
    if (_itemController.text.trim().isEmpty) return;

    try {
      final firebaseService = ref.read(firebaseServiceProvider);
      await firebaseService.addShoppingItem(_itemController.text.trim());
      _itemController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding item: $e')));
      }
    }
  }

  Future<void> _showAddItemDialog() async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF9066), Color(0xFFFF6B35)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            ),
            child: Container(
              margin: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Title
                    const Text(
                      'Add Shopping Item',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFFF6B35)),
                    ),
                    const SizedBox(height: 8),
                    Text('What do you need to buy?', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    const SizedBox(height: 24),
                    // Input field
                    TextField(
                      controller: _itemController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'e.g., Milk, Bread, Eggs...',
                        prefixIcon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFFFF6B35)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) {
                        Navigator.of(context).pop();
                        _addItem();
                      },
                    ),
                    const SizedBox(height: 24),
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _itemController.clear();
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFFFF9066), Color(0xFFFF6B35)]),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _addItem();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_circle_outline, size: 20),
                                  SizedBox(width: 8),
                                  Text('Add Item', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _confirmDelete(String itemName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: Text('Are you sure you want to delete "$itemName"?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _deleteItem(String itemId, String itemName) async {
    final confirmed = await _confirmDelete(itemName);
    if (!confirmed) return;

    try {
      final firebaseService = ref.read(firebaseServiceProvider);
      await firebaseService.deleteShoppingItem(itemId);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Item deleted'), duration: Duration(seconds: 2)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting item: $e')));
      }
    }
  }

  Future<void> _editItem(String itemId, String currentName) async {
    String? result;

    await showDialog<void>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: currentName);

        return AlertDialog(
          title: const Text('Edit Item'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Item name', border: OutlineInputBorder()),
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (value) {
              result = value;
              Navigator.of(context).pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                result = null;
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                result = controller.text;
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != null && result!.trim().isNotEmpty && result != currentName) {
      try {
        final firebaseService = ref.read(firebaseServiceProvider);
        await firebaseService.updateShoppingItem(itemId, result!.trim());
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating item: $e')));
        }
      }
    }
  }

  List<ShoppingItem> _sortItems(List<ShoppingItem> items) {
    final sortedItems = List<ShoppingItem>.from(items);

    switch (_currentFilter) {
      case SortFilter.dateTime:
        sortedItems.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortFilter.alphabetical:
        sortedItems.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case SortFilter.notDoneFirst:
        sortedItems.sort((a, b) {
          if (a.isDone == b.isDone) {
            return a.createdAt.compareTo(b.createdAt);
          }
          return a.isDone ? 1 : -1;
        });
        break;
      case SortFilter.doneFirst:
        sortedItems.sort((a, b) {
          if (a.isDone == b.isDone) {
            return a.createdAt.compareTo(b.createdAt);
          }
          return a.isDone ? -1 : 1;
        });
        break;
    }

    return sortedItems;
  }

  String _getFilterName(SortFilter filter) {
    switch (filter) {
      case SortFilter.dateTime:
        return 'Date & Time';
      case SortFilter.alphabetical:
        return 'A-Z';
      case SortFilter.notDoneFirst:
        return 'Not Done First';
      case SortFilter.doneFirst:
        return 'Done First';
    }
  }

  @override
  void dispose() {
    _itemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final shoppingItemsAsync = ref.watch(shoppingItemsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Shopping List', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF9066), Color(0xFFFF6B35)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<SortFilter>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            tooltip: 'Sort by: ${_getFilterName(_currentFilter)}',
            onSelected: (filter) {
              setState(() {
                _currentFilter = filter;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: SortFilter.dateTime,
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 20,
                      color: _currentFilter == SortFilter.dateTime ? const Color(0xFFFF6B35) : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Date & Time',
                      style: TextStyle(
                        color: _currentFilter == SortFilter.dateTime ? const Color(0xFFFF6B35) : Colors.black,
                        fontWeight: _currentFilter == SortFilter.dateTime ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: SortFilter.alphabetical,
                child: Row(
                  children: [
                    Icon(
                      Icons.sort_by_alpha,
                      size: 20,
                      color: _currentFilter == SortFilter.alphabetical ? const Color(0xFFFF6B35) : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'A-Z',
                      style: TextStyle(
                        color: _currentFilter == SortFilter.alphabetical ? const Color(0xFFFF6B35) : Colors.black,
                        fontWeight: _currentFilter == SortFilter.alphabetical ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: SortFilter.notDoneFirst,
                child: Row(
                  children: [
                    Icon(
                      Icons.radio_button_unchecked,
                      size: 20,
                      color: _currentFilter == SortFilter.notDoneFirst ? const Color(0xFFFF6B35) : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Not Done First',
                      style: TextStyle(
                        color: _currentFilter == SortFilter.notDoneFirst ? const Color(0xFFFF6B35) : Colors.black,
                        fontWeight: _currentFilter == SortFilter.notDoneFirst ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: SortFilter.doneFirst,
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 20,
                      color: _currentFilter == SortFilter.doneFirst ? const Color(0xFFFF6B35) : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Done First',
                      style: TextStyle(
                        color: _currentFilter == SortFilter.doneFirst ? const Color(0xFFFF6B35) : Colors.black,
                        fontWeight: _currentFilter == SortFilter.doneFirst ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  userAsync.value?.displayName ?? 'User',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
      body: shoppingItemsAsync.when(
        data: (items) {
          // Apply sorting based on current filter
          final sortedItems = _sortItems(items);

          if (sortedItems.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                // Trigger cleanup and force refresh
                await ref.read(firebaseServiceProvider).cleanupOldCompletedItems();
                // Force provider to refresh
                ref.invalidate(shoppingItemsProvider);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('No items yet', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                        const SizedBox(height: 8),
                        Text('Tap + to add your first item', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Trigger cleanup and force refresh
              await ref.read(firebaseServiceProvider).cleanupOldCompletedItems();
              // Force provider to refresh
              ref.invalidate(shoppingItemsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: sortedItems.length,
              itemBuilder: (context, index) {
                final item = sortedItems[index];
                final timeAgo = timeago.format(item.createdAt);

                return Dismissible(
                  key: Key(item.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await _confirmDelete(item.name);
                  },
                  onDismissed: (direction) async {
                    await _deleteItem(item.id, item.name);
                  },
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(16)),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_forever, color: Colors.white, size: 32),
                        SizedBox(height: 4),
                        Text(
                          'Delete',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      gradient: item.isDone
                          ? LinearGradient(colors: [Colors.grey[300]!, Colors.grey[200]!])
                          : const LinearGradient(colors: [Colors.white, Colors.white]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          // Checkbox
                          Checkbox(
                            value: item.isDone,
                            onChanged: (_) {
                              final firebaseService = ref.read(firebaseServiceProvider);
                              firebaseService.toggleItemStatus(item.id, item.isDone);
                            },
                            activeColor: const Color(0xFF667eea),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          const SizedBox(width: 12),
                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title row with Done badge
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.name,
                                        style: TextStyle(
                                          decoration: item.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                                          color: item.isDone ? Colors.grey : Colors.black87,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (item.isDone) ...[
                                      const SizedBox(width: 8),
                                      Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 6),
                                // Info row
                                Row(
                                  children: [
                                    Icon(Icons.person_outline, size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(item.addedBy, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                    const SizedBox(width: 12),
                                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(timeAgo, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Menu button
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                            onSelected: (value) {
                              if (value == 'edit') {
                                _editItem(item.id, item.name);
                              } else if (value == 'delete') {
                                _deleteItem(item.id, item.name);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Edit')]),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 20, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFF9066), Color(0xFFFF6B35)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B35).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _showAddItemDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
