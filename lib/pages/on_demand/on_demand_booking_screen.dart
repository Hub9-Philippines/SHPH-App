import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '/api/models/category.dart';
import '/api/models/on_demand_job.dart';
import '/api/resources/services_api.dart';
import '/app_state.dart';
import '/services/logging_service.dart';
import '/services/on_demand_service.dart';
import '/theme/app_theme.dart';

/// Client screen to create and broadcast an on-demand job.
///
/// Mirrors the web `OnDemandBookingPage.vue` flow using the SHPH API.
class OnDemandBookingScreen extends StatefulWidget {
  const OnDemandBookingScreen({super.key});

  static const String routeName = 'OnDemandBooking';
  static const String routePath = '/on-demand/booking';

  @override
  State<OnDemandBookingScreen> createState() => _OnDemandBookingScreenState();
}

class _OnDemandBookingScreenState extends State<OnDemandBookingScreen> {
  final _descriptionController = TextEditingController();
  final _voucherController = TextEditingController();

  List<ShphCategory> _categories = [];
  ShphCategory? _selectedCategory;
  bool _loadingCategories = true;

  double _radiusKm = 4;
  double? _latitude;
  double? _longitude;

  bool _estimating = false;
  Map<String, dynamic>? _estimate;

  bool _submitting = false;
  ShphOnDemandJob? _createdJob;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadLocation();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _voucherController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final response = await ShphServicesApi.instance.listCategories();
      final onDemandCategories = response.results
          .where((c) => c.name.toLowerCase().contains('cleaning'))
          .toList();
      setState(() {
        _categories = onDemandCategories.isNotEmpty
            ? onDemandCategories
            : response.results;
        _loadingCategories = false;
      });
    } catch (e) {
      LoggingService.error('Failed to load categories: $e',
          tag: 'OnDemandBooking');
      setState(() => _loadingCategories = false);
    }
  }

  Future<void> _loadLocation() async {
    final appState = FFAppState();
    if (appState.selectedLatitude != null &&
        appState.selectedLongitude != null) {
      setState(() {
        _latitude = appState.selectedLatitude;
        _longitude = appState.selectedLongitude;
      });
      return;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (e) {
      LoggingService.error('Failed to get current location: $e',
          tag: 'OnDemandBooking');
    }
  }

  Future<void> _getEstimate() async {
    if (_selectedCategory == null || _latitude == null || _longitude == null) {
      return;
    }
    setState(() => _estimating = true);
    try {
      final estimate = await OnDemandService.instance.estimateFee(
        categoryId: _selectedCategory!.id,
        lat: _latitude!,
        lng: _longitude!,
        radiusKm: _radiusKm.round(),
      );
      setState(() => _estimate = estimate);
    } catch (e) {
      LoggingService.error('Estimate failed: $e', tag: 'OnDemandBooking');
      _showMessage('Could not get estimate. Please try again.');
    } finally {
      setState(() => _estimating = false);
    }
  }

  Future<void> _submitJob() async {
    if (_selectedCategory == null || _latitude == null || _longitude == null) {
      _showMessage('Please select a category and location.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final draft = ShphOnDemandJob(
        id: 0,
        category: _selectedCategory!.id,
        description: _descriptionController.text.trim(),
        clientLat: _latitude,
        clientLng: _longitude,
        radiusKm: _radiusKm.round(),
        voucherCode:
            _voucherController.text.trim().isEmpty
                ? null
                : _voucherController.text.trim(),
      );
      final job = await OnDemandService.instance.createJob(draft);
      if (job != null) {
        setState(() => _createdJob = job);
        _showMessage('Job posted! Providers nearby will see it.');
      } else {
        _showMessage('Failed to post job.');
      }
    } catch (e) {
      LoggingService.error('Job submission failed: $e', tag: 'OnDemandBooking');
      _showMessage('Failed to post job. Please try again.');
    } finally {
      setState(() => _submitting = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        elevation: 0,
        title: Text(
          'On-Demand Booking',
          style: GoogleFonts.poppins(
            color: theme.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.primaryText),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Request a service now',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Describe what you need and nearby providers will send bids.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: theme.secondaryText,
                ),
              ),
              const SizedBox(height: 24),
              _buildCategorySelector(theme),
              const SizedBox(height: 20),
              _buildDescriptionField(theme),
              const SizedBox(height: 20),
              _buildLocationSection(theme),
              const SizedBox(height: 20),
              _buildRadiusSlider(theme),
              const SizedBox(height: 20),
              _buildVoucherField(theme),
              const SizedBox(height: 24),
              _buildEstimateCard(theme),
              const SizedBox(height: 24),
              _buildActionButtons(theme),
              if (_createdJob != null) _buildCreatedJobCard(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector(AppThemeData theme) {
    if (_loadingCategories) {
      return const Center(child: CircularProgressIndicator());
    }
    return DropdownButtonFormField<ShphCategory>(
      value: _selectedCategory,
      hint: Text('Select a service category', style: GoogleFonts.poppins()),
      decoration: InputDecoration(
        filled: true,
        fillColor: theme.secondaryBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: _categories
          .map((c) => DropdownMenuItem(
                value: c,
                child: Text(c.name, style: GoogleFonts.poppins()),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
          _estimate = null;
        });
      },
    );
  }

  Widget _buildDescriptionField(AppThemeData theme) {
    return TextField(
      controller: _descriptionController,
      maxLines: 4,
      decoration: InputDecoration(
        filled: true,
        fillColor: theme.secondaryBackground,
        hintText: 'Describe the job (e.g. "Fix my leaking kitchen sink")',
        hintStyle: GoogleFonts.poppins(color: theme.secondaryText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildLocationSection(AppThemeData theme) {
    return Card(
      color: theme.secondaryBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: theme.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, color: theme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _latitude != null && _longitude != null
                        ? 'Lat: ${_latitude!.toStringAsFixed(4)}, Lng: ${_longitude!.toStringAsFixed(4)}'
                        : 'Location not available',
                    style: GoogleFonts.poppins(color: theme.secondaryText),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _loadLocation,
              icon: Icon(Icons.my_location, color: theme.primary),
              label: Text(
                'Refresh location',
                style: GoogleFonts.poppins(color: theme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadiusSlider(AppThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search radius: ${_radiusKm.round()} km',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: theme.primaryText,
          ),
        ),
        Slider(
          value: _radiusKm,
          min: 1,
          max: 50,
          divisions: 49,
          activeColor: theme.primary,
          onChanged: (value) {
            setState(() {
              _radiusKm = value;
              _estimate = null;
            });
          },
        ),
      ],
    );
  }

  Widget _buildVoucherField(AppThemeData theme) {
    return TextField(
      controller: _voucherController,
      decoration: InputDecoration(
        filled: true,
        fillColor: theme.secondaryBackground,
        hintText: 'Voucher code (optional)',
        hintStyle: GoogleFonts.poppins(color: theme.secondaryText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildEstimateCard(AppThemeData theme) {
    if (_estimating) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_estimate == null) return const SizedBox.shrink();

    final minFee = _estimate!['min_fee'];
    final maxFee = _estimate!['max_fee'];
    final note = _estimate!['note'] as String?;

    return Card(
      color: theme.secondaryBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estimated fee',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: theme.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              minFee != null && maxFee != null
                  ? '₱$minFee - ₱$maxFee'
                  : 'Estimate unavailable',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.primary,
              ),
            ),
            if (note != null && note.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                note,
                style: GoogleFonts.poppins(color: theme.secondaryText),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(AppThemeData theme) {
    final canEstimate =
        _selectedCategory != null && _latitude != null && _longitude != null;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canEstimate && !_estimating ? _getEstimate : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _estimating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : Text(
                    'Get estimate',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canEstimate && !_submitting ? _submitJob : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : Text(
                    'Post job',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreatedJobCard(AppThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Card(
        color: theme.secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Job posted',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: theme.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Status: ${_createdJob!.status.apiValue}',
                style: GoogleFonts.poppins(color: theme.secondaryText),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.push(
                      '/on-demand/client-jobs',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'View my jobs',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
