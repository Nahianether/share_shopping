import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/firebase_providers.dart';
import '../models/shopping_item.dart';
import '../widgets/gradient_app_bar.dart';
import '../widgets/shopping_item_card.dart';
import '../widgets/add_item_modal.dart';
import '../widgets/filter_menu.dart';
import '../widgets/gradient_fab.dart';
import '../widgets/empty_state.dart';

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  SortFilter _currentFilter = SortFilter.dateTime;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(firebaseServiceProvider).cleanupOldCompletedItems();
    });
  }

  Future<void> _addItem(String itemName) async {
    try {
      final firebaseService = ref.read(firebaseServiceProvider);
      await firebaseService.addShoppingItem(itemName);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding item: $e')),
        );
      }
    }
  }

  Future<void> _toggleItem(ShoppingItem item) async {
    try {
      final firebaseService = ref.read(firebaseServiceProvider);
      await firebaseService.toggleItemStatus(item.id, item.isDone);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating item: $e')),
        );
      }
    }
  }

  Future<void> _deleteItem(String itemId, String itemName) async {
    try {
      final firebaseService = ref.read(firebaseServiceProvider);
      await firebaseService.deleteShoppingItem(itemId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item deleted'), duration: Duration(seconds: 2)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting item: $e')),
        );
      }
    }
  }

  Future<void> _editItem(String itemId, String currentName) async {
    String? result;
    final appTheme = ref.read(themeProvider);

    await showDialog<void>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: currentName);

        return AlertDialog(
          backgroundColor: appTheme.surfaceColor,
          title: Text('Edit Item', style: TextStyle(color: appTheme.textColor)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: TextStyle(color: appTheme.textColor),
            decoration: InputDecoration(
              hintText: 'Item name',
              hintStyle: TextStyle(color: appTheme.textSecondaryColor),
              border: const OutlineInputBorder(),
            ),
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
              child: Text('Cancel', style: TextStyle(color: appTheme.textSecondaryColor)),
            ),
            ElevatedButton(
              onPressed: () {
                result = controller.text;
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: appTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating item: $e')),
          );
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

  void _showAddItemModal() {
    final appTheme = ref.read(themeProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddItemModal(
        appTheme: appTheme,
        onAddItem: _addItem,
      ),
    );
  }

  Future<void> _refreshData() async {
    await ref.read(firebaseServiceProvider).cleanupOldCompletedItems();
    ref.invalidate(shoppingItemsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final shoppingItemsAsync = ref.watch(shoppingItemsProvider);
    final appTheme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: appTheme.backgroundColor,
      appBar: GradientAppBar(
        title: 'Shopping List',
        appTheme: appTheme,
        userName: userAsync.value?.displayName ?? 'User',
        onThemeToggle: () {
          ref.read(themeProvider.notifier).toggleTheme();
        },
        filterMenu: FilterMenu(
          currentFilter: _currentFilter,
          appTheme: appTheme,
          onFilterChanged: (filter) {
            setState(() {
              _currentFilter = filter;
            });
          },
        ),
      ),
      body: shoppingItemsAsync.when(
        data: (items) {
          final sortedItems = _sortItems(items);

          if (sortedItems.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 200,
                  child: EmptyState(appTheme: appTheme),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: sortedItems.length,
              itemBuilder: (context, index) {
                final item = sortedItems[index];
                return ShoppingItemCard(
                  item: item,
                  appTheme: appTheme,
                  onToggle: () => _toggleItem(item),
                  onEdit: () => _editItem(item.id, item.name),
                  onDelete: () => _deleteItem(item.id, item.name),
                  onDismissed: () => _deleteItem(item.id, item.name),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error: $error',
            style: TextStyle(color: appTheme.textColor),
          ),
        ),
      ),
      floatingActionButton: GradientFAB(
        appTheme: appTheme,
        onPressed: _showAddItemModal,
      ),
    );
  }
}
