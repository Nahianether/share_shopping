import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/shopping_item.dart';
import '../models/app_theme.dart';

class ShoppingItemCard extends StatelessWidget {
  final ShoppingItem item;
  final AppTheme appTheme;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDismissed;

  const ShoppingItemCard({
    super.key,
    required this.item,
    required this.appTheme,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final timeAgo = timeago.format(item.createdAt);

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: appTheme.surfaceColor,
            title: Text('Delete Item', style: TextStyle(color: appTheme.textColor)),
            content: Text(
              'Are you sure you want to delete "${item.name}"?',
              style: TextStyle(color: appTheme.textSecondaryColor),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel', style: TextStyle(color: appTheme.textSecondaryColor)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) => onDismissed(),
      child: Card(
        color: appTheme.surfaceColor,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Checkbox
              Checkbox(
                value: item.isDone,
                onChanged: (_) => onToggle(),
                activeColor: appTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              // Item info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row with done badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration: item.isDone ? TextDecoration.lineThrough : null,
                              color: item.isDone ? appTheme.textSecondaryColor : appTheme.textColor,
                            ),
                          ),
                        ),
                        if (item.isDone) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.check_circle, color: appTheme.primaryColor, size: 16),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // User and time info
                    Row(
                      children: [
                        Icon(Icons.person, size: 12, color: appTheme.textSecondaryColor),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            item.addedBy,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11, color: appTheme.textSecondaryColor),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.access_time, size: 12, color: appTheme.textSecondaryColor),
                        const SizedBox(width: 4),
                        Text(
                          timeAgo,
                          style: TextStyle(fontSize: 12, color: appTheme.textSecondaryColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Menu button
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: appTheme.textSecondaryColor),
                color: appTheme.surfaceColor,
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20, color: appTheme.textColor),
                        const SizedBox(width: 8),
                        Text('Edit', style: TextStyle(color: appTheme.textColor)),
                      ],
                    ),
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
  }
}
