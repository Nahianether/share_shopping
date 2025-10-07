import 'package:flutter/material.dart';
import '../models/app_theme.dart';

enum SortFilter { dateTime, alphabetical, notDoneFirst, doneFirst }

class FilterMenu extends StatelessWidget {
  final SortFilter currentFilter;
  final AppTheme appTheme;
  final Function(SortFilter) onFilterChanged;

  const FilterMenu({
    super.key,
    required this.currentFilter,
    required this.appTheme,
    required this.onFilterChanged,
  });

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
  Widget build(BuildContext context) {
    return PopupMenuButton<SortFilter>(
      icon: const Icon(Icons.filter_list, color: Colors.white),
      tooltip: 'Sort by: ${_getFilterName(currentFilter)}',
      color: appTheme.surfaceColor,
      onSelected: onFilterChanged,
      itemBuilder: (context) => [
        _buildMenuItem(
          SortFilter.dateTime,
          Icons.access_time,
          'Date & Time',
        ),
        _buildMenuItem(
          SortFilter.alphabetical,
          Icons.sort_by_alpha,
          'A-Z',
        ),
        _buildMenuItem(
          SortFilter.notDoneFirst,
          Icons.radio_button_unchecked,
          'Not Done First',
        ),
        _buildMenuItem(
          SortFilter.doneFirst,
          Icons.check_circle,
          'Done First',
        ),
      ],
    );
  }

  PopupMenuItem<SortFilter> _buildMenuItem(
    SortFilter filter,
    IconData icon,
    String label,
  ) {
    final isSelected = currentFilter == filter;
    return PopupMenuItem(
      value: filter,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected ? appTheme.primaryColor : appTheme.textSecondaryColor,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? appTheme.primaryColor : appTheme.textColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
