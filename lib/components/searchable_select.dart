import 'package:flutter/material.dart';

import '/components/cupertino_ui/app_text_field.dart';
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';

class SearchableSelect extends StatefulWidget {
  const SearchableSelect({
    super.key,
    required this.label,
    required this.items,
    required this.onSelected,
    this.selectedValue,
    this.placeholder,
    this.errorText,
    this.required = false,
    this.disabled = false,
  });

  final String label;
  final List<DropdownMenuItem> items;
  final ValueChanged<dynamic> onSelected;
  final dynamic selectedValue;
  final String? placeholder;
  final String? errorText;
  final bool required;
  final bool disabled;

  @override
  State<SearchableSelect> createState() => _SearchableSelectState();
}

class _SearchableSelectState extends State<SearchableSelect> {
  final searchController = TextEditingController();
  bool open = false;
  String searchQuery = '';

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  String get _selectedLabel {
    for (final item in widget.items) {
      if (item.value == widget.selectedValue) return item.label;
    }
    return '';
  }

  List<DropdownMenuItem> get _filteredItems {
    if (searchQuery.isEmpty) return widget.items;
    return widget.items
        .where((item) =>
            item.label.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: widget.disabled ? null : () => setState(() => open = true),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.errorText != null
                    ? theme.error
                    : theme.border,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.label}${widget.required ? ' *' : ''}',
                        style: TextStyle(
                            fontSize: 12, color: theme.secondaryText),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _selectedLabel.isNotEmpty
                            ? _selectedLabel
                            : widget.placeholder ??
                                _l10n.ccSelect(widget.label.toLowerCase()),
                        style: TextStyle(
                          fontSize: 14,
                          color: _selectedLabel.isNotEmpty
                              ? theme.primaryText
                              : theme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.keyboard_arrow_down,
                    color: theme.secondaryText, size: 20),
              ],
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 4),
          Text(widget.errorText!,
              style: TextStyle(fontSize: 12, color: theme.error)),
        ],
        if (open) _buildModal(theme),
      ],
    );
  }

  Widget _buildModal(AppThemeData theme) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child:               AppTextField(
                controller: searchController,
                placeholder: _l10n.ccSearch,
                prefixIcon: Icons.search,
                radius: 10,
                onChanged: (v) => setState(() => searchQuery = v),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: _filteredItems.map((item) {
                  final selected = item.value == widget.selectedValue;
                  return ListTile(
                    selected: selected,
                    selectedTileColor:
                        theme.primary.withValues(alpha: 0.08),
                    title: Text(item.label),
                    trailing: selected
                        ? Icon(Icons.check, color: theme.primary, size: 18)
                        : null,
                    onTap: () {
                      widget.onSelected(item.value);
                      setState(() => open = false);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DropdownMenuItem {
  const DropdownMenuItem({
    required this.label,
    required this.value,
  });

  final String label;
  final dynamic value;
}
