import 'package:flutter/material.dart';

import '/services/gemini_models.dart';
import '/services/gemini_service.dart';

/// Smart search bar — converts natural language queries into structured
/// filters using Gemini AI. Mirrors `useSmartSearch` composable from Vue.
///
/// When Gemini AI is disabled, the widget is a simple search field that
/// passes the raw query through.
class SmartSearchBar extends StatefulWidget {
  const SmartSearchBar({
    super.key,
    this.categories = const [],
    this.onFilters,
    this.hintText = 'Search\u2026',
  });

  final List<DraftCandidate> categories;
  final ValueChanged<SmartSearchFilters>? onFilters;
  final String hintText;

  @override
  State<SmartSearchBar> createState() => _SmartSearchBarState();
}

class _SmartSearchBarState extends State<SmartSearchBar> {
  final _ctrl = TextEditingController();
  bool _loading = false;

  bool get _aiEnabled => GeminiService.instance.isEnabled;

  Future<void> _search() async {
    final query = _ctrl.text.trim();
    if (query.isEmpty) return;

    if (!_aiEnabled || widget.categories.isEmpty) {
      widget.onFilters?.call(SmartSearchFilters.empty.copyWith(
        cleanedQuery: query,
      ));
      return;
    }

    setState(() => _loading = true);

    final filters = await GeminiService.instance.smartSearch(
      query: query,
      categories: widget.categories,
    );

    if (mounted) {
      setState(() => _loading = false);
      if (filters != null) {
        widget.onFilters?.call(filters);
      } else {
        widget.onFilters?.call(SmartSearchFilters.empty.copyWith(
          cleanedQuery: query,
        ));
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: TextField(
              controller: _ctrl,
              decoration: InputDecoration(
                hintText: widget.hintText,
                prefixIcon: _aiEnabled
                    ? const Icon(Icons.auto_awesome)
                    : const Icon(Icons.search),
                suffixIcon: _loading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: _loading ? null : _search,
            icon: const Icon(Icons.search),
          ),
        ],
      );
}
