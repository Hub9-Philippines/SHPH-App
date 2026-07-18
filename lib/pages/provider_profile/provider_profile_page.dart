import 'package:flutter/material.dart';

import '/api/models/service_listing.dart';
import '/api/resources/provider_api.dart';
import '/theme/app_theme.dart';

/// Public provider profile view.
///
/// Mirrors `shph-app/src/views/provider/ProviderProfilePage.vue`. Backed by
/// `ShphProviderApi.getProfile()` + `getListings()`.
class ProviderProfilePage extends StatefulWidget {
  const ProviderProfilePage({super.key, required this.providerId});

  final int providerId;

  static String routeName = 'ProviderProfile';
  static String routePath = '/provider/profile/:providerId';

  @override
  State<ProviderProfilePage> createState() => _ProviderProfilePageState();
}

class _ProviderProfilePageState extends State<ProviderProfilePage> {
  Map<String, dynamic> _profile = const {};
  List<ShphServiceListing> _listings = const [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final profile =
          await ShphProviderApi.instance.getProfile(widget.providerId);
      final rawListings =
          await ShphProviderApi.instance.getListings(widget.providerId);
      final listings = rawListings.map(ShphServiceListing.fromJson).toList();
      if (mounted) {
        setState(() {
          _profile = profile;
          _listings = listings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load profile: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text(_profile['display_name']?.toString() ?? 'Provider',
            style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
        backgroundColor: theme.primaryBackground,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _ErrorView(message: _errorMessage!, onRetry: _loadData)
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                    children: [
                      _HeroCard(profile: _profile),
                      const SizedBox(height: 16),
                      Text('Services (${_listings.length})',
                          style: theme.titleMedium
                              .override(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      if (_listings.isEmpty)
                        _EmptyCard(label: 'No services listed')
                      else
                        ..._listings.map((l) => _ListingCard(listing: l)),
                    ],
                  ),
                ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.profile});
  final Map<String, dynamic> profile;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final photo = profile['photo_url'] as String?;
    final name = profile['display_name']?.toString() ?? 'Provider';
    final bio = profile['bio'] as String? ?? '';
    final kycVerified = profile['kyc_verified'] as bool? ?? false;
    final completed = profile['total_completed_bookings'] as int? ?? 0;
    final rating = _double(profile, 'avg_rating');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primary, theme.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                backgroundImage: photo != null && photo.isNotEmpty
                    ? NetworkImage(photo)
                    : null,
                child: photo == null || photo.isEmpty
                    ? const Icon(Icons.person, color: Colors.white, size: 32)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: theme.titleMedium.override(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        )),
                    if (kycVerified)
                      Row(
                        children: [
                          Icon(Icons.verified,
                              size: 14, color: Colors.greenAccent.shade100),
                          const SizedBox(width: 4),
                          Text('KYC Verified',
                              style: theme.bodySmall
                                  .override(color: Colors.white70)),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (bio.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(bio, style: theme.bodyMedium.override(color: Colors.white70)),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _StatPill(label: 'Rating', value: rating.toStringAsFixed(1)),
              const SizedBox(width: 12),
              _StatPill(label: 'Jobs', value: completed.toString()),
            ],
          ),
        ],
      ),
    );
  }

  double _double(Map<String, dynamic> m, String k) {
    final v = m[k];
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              )),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({required this.listing});
  final ShphServiceListing listing;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(listing.title,
                    style:
                        theme.bodyMedium.override(fontWeight: FontWeight.w700)),
                if (listing.categoryName != null)
                  Text(listing.categoryName!,
                      style:
                          theme.bodySmall.override(color: theme.secondaryText)),
              ],
            ),
          ),
          if (listing.basePrice != null)
            Text('PHP ${listing.basePrice!.toStringAsFixed(0)}',
                style: theme.bodyMedium.override(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          textAlign: TextAlign.center,
          style: theme.bodyMedium.override(color: theme.secondaryText)),
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
