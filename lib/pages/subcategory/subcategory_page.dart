import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/api/models/category.dart';
import '/api/models/paginated_response.dart';
import '/api/resources/services_api.dart';
import '/theme/app_theme.dart';

/// Browse subcategories within a parent category.
///
/// Mirrors `shph-app/src/views/services/SubcategoryPage.vue`. Backed by
/// `ShphServicesApi.listSubcategories()` →
/// GET `/api/services/categories/<parentId>/subcategories/`.
class SubcategoryPage extends StatefulWidget {
  const SubcategoryPage({
    super.key,
    required this.parentId,
    this.parentName,
  });

  final int parentId;
  final String? parentName;

  static String routeName = 'Subcategory';
  static String routePath = '/subcategory/:parentId';

  @override
  State<SubcategoryPage> createState() => _SubcategoryPageState();
}

class _SubcategoryPageState extends State<SubcategoryPage> {
  List<ShphCategory> _subcategories = const [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSubcategories();
  }

  Future<void> _loadSubcategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final PaginatedResponse<ShphCategory> response =
          await ShphServicesApi.instance.listSubcategories(widget.parentId);
      if (mounted) {
        setState(() {
          _subcategories = response.results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load subcategories: $e';
        });
      }
    }
  }

  Future<void> _open(ShphCategory sub) async {
    await context.push(
      '/category/${sub.id}?name=${Uri.encodeComponent(sub.name)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text(widget.parentName ?? 'Subcategories',
            style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
        backgroundColor: theme.primaryBackground,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _ErrorView(message: _errorMessage!, onRetry: _loadSubcategories)
              : _subcategories.isEmpty
                  ? _EmptyView()
                  : RefreshIndicator(
                      onRefresh: _loadSubcategories,
                      child: GridView.count(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.1,
                        children: _subcategories
                            .map((s) => _SubcategoryTile(
                                  category: s,
                                  onTap: () => _open(s),
                                ))
                            .toList(),
                      ),
                    ),
    );
  }
}

class _SubcategoryTile extends StatelessWidget {
  const _SubcategoryTile({required this.category, required this.onTap});
  final ShphCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Material(
      color: theme.primaryBackground,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.category, color: theme.primary, size: 32),
              const SizedBox(height: 10),
              Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.bodyMedium.override(fontWeight: FontWeight.w700),
              ),
              if (category.description != null &&
                  category.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  category.description!,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.bodySmall.override(color: theme.secondaryText),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.category_outlined, size: 64, color: theme.secondaryText),
            const SizedBox(height: 16),
            Text('No subcategories',
                style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.error),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: theme.bodyMedium.override(color: theme.secondaryText)),
            const SizedBox(height: 20),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
