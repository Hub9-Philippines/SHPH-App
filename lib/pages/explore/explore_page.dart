import 'package:flutter/material.dart';

import '/api/models/service_listing.dart';
import '/api/resources/services_api.dart';
import '/theme/app_theme.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  static String routeName = 'Explore';
  static String routePath = '/explore';

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  List<ShphServiceListing> _listings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final page = await ShphServicesApi.instance.listListings();
      if (mounted) {
        setState(() {
          _listings = page.results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load listings: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _loadListings,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!,
                            style: theme.bodyMedium
                                .override(color: theme.error)),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _loadListings,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _listings.isEmpty
                    ? ListView(
                        children: [
                          const SizedBox(height: 120),
                          Center(
                            child: Text('No services found nearby',
                                style: theme.bodyMedium
                                    .override(color: theme.secondaryText)),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _listings.length,
                        itemBuilder: (context, index) {
                          final listing = _listings[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.primaryBackground,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.alternate,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: theme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.home_repair_service,
                                      color: theme.primary),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(listing.title,
                                          style: theme.titleSmall.override(
                                              fontWeight:
                                                  FontWeight.w600)),
                                      if (listing.providerName != null &&
                                          listing.providerName!.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(listing.providerName!,
                                            style: theme.bodySmall.override(
                                                color:
                                                    theme.secondaryText)),
                                      ],
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.star,
                                              size: 14,
                                              color: Color(0xFFFFB300)),
                                          const SizedBox(width: 4),
                                          Text(listing.rating ?? 'N/A',
                                              style: theme.bodySmall.override(
                                                  color:
                                                      theme.secondaryText)),
                                          if (listing.basePrice != null) ...[
                                            const SizedBox(width: 12),
                                            Text(
                                                '₱${listing.basePrice!.toStringAsFixed(0)}',
                                                style: theme.bodySmall.override(
                                                    color: theme.primary,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
