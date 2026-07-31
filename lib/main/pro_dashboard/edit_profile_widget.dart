import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/auth/base_auth_user_provider.dart';
import '/components/screen_header.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/services/logging_service.dart';
import '/services/profiles_service.dart';
import '/theme/app_theme.dart';

class ProEditProfileWidget extends StatefulWidget {
  const ProEditProfileWidget({super.key});

  static const String routeName = 'ProEditProfile';
  static const String routePath = '/pro/edit-profile';

  @override
  State<ProEditProfileWidget> createState() => _ProEditProfileWidgetState();
}

class _ProEditProfileWidgetState extends State<ProEditProfileWidget> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;
  Map<String, dynamic>? profileData;
  File? _selectedImage;
  String? _currentPhotoUrl;

  // Service location
  double? _latitude;
  double? _longitude;
  String? _locationLabel;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    // Pre-fetch device location as default fallback
    getCurrentUserLocation(
      defaultLocation: const LatLng(14.5995, 120.9842),
    ).then((loc) {
      if (mounted && _latitude == null) {
        setState(() {
          _latitude = loc.latitude;
          _longitude = loc.longitude;
          _locationLabel = 'Current device location';
        });
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _displayNameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => isLoading = true);
    try {
      final profile = await ProfilesService.instance.getProfile();
      if (profile == null) {
        setState(() => isLoading = false);
        return;
      }

      final savedLat = (profile.data['latitude'] as num?)?.toDouble();
      final savedLng = (profile.data['longitude'] as num?)?.toDouble();

      setState(() {
        profileData = profile.data;
        _firstNameController.text = profile.firstName ?? '';
        _lastNameController.text = profile.lastName ?? '';
        _displayNameController.text = profile.displayName ?? '';
        _bioController.text = profile.bioDetails ?? '';
        _phoneController.text = profile.phoneNumber ?? '';
        _currentPhotoUrl = profile.photoUrl;
        if (savedLat != null && savedLng != null) {
          _latitude = savedLat;
          _longitude = savedLng;
          _locationLabel = profile.data['location_label'] as String? ??
              '${savedLat.toStringAsFixed(5)}, ${savedLng.toStringAsFixed(5)}';
        }
        isLoading = false;
      });
    } catch (e) {
      LoggingService.error('Error loading profile: $e', tag: 'EditProfile');
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  Future<void> _openPinLocation() async {
    LatLng? initialLatLng;
    if (_latitude != null && _longitude != null) {
      initialLatLng = LatLng(_latitude!, _longitude!);
    } else {
      try {
        final loc = await getCurrentUserLocation(
          defaultLocation: const LatLng(14.5995, 120.9842),
        );
        initialLatLng = loc;
      } catch (_) {
        initialLatLng = const LatLng(14.5995, 120.9842);
      }
    }

    if (!mounted) {
      return;
    }

    final result = await context.pushNamed<Map<String, dynamic>?>(
      PinLocationWidget.routeName,
      extra: initialLatLng,
    );
    if (!mounted) {
      return;
    }

    if (result != null) {
      setState(() {
        _latitude = (result['latitude'] as num?)?.toDouble();
        _longitude = (result['longitude'] as num?)?.toDouble();
        final resultAddress = result['address'] as String?;
        _locationLabel = (resultAddress != null && resultAddress.isNotEmpty)
            ? resultAddress
            : _locationLabel ?? 'Pinned location';
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      LoggingService.error('Error picking image: $e', tag: 'EditProfile');
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
  }

  Future<String?> _uploadPhoto(String userId) async {
    if (_selectedImage == null) {
      return _currentPhotoUrl;
    }
    try {
      final bytes = await _selectedImage!.readAsBytes();
      final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';
      return await ProfilesService.instance.uploadProfilePhoto(bytes, fileName);
    } catch (e) {
      LoggingService.error('Error uploading photo: $e', tag: 'EditProfile');
      throw Exception('Failed to upload photo: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isSaving = true);
    try {
      final userId = currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Upload photo if selected
      final photoUrl = await _uploadPhoto(userId);

      // Update profile via ProfilesService (REST-first, else Supabase)
      final updates = <String, dynamic>{
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'display_name': _displayNameController.text.trim(),
        'bio_details': _bioController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        if (photoUrl != null) 'photo_url': photoUrl,
        if (_latitude != null) 'latitude': _latitude,
        if (_longitude != null) 'longitude': _longitude,
        if (_locationLabel != null) 'location_label': _locationLabel,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await ProfilesService.instance.updateProfile(updates);

      LoggingService.info('Profile updated successfully', tag: 'EditProfile');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        context.pop();
      }
    } catch (e) {
      LoggingService.error('Error saving profile: $e', tag: 'EditProfile');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppTheme.of(context).primaryBackground,
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              ScreenHeader(title: 'Edit Profile'),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                        _buildProfileHero(context),
                        const SizedBox(height: 20),
                        _buildSectionCard(
                          context: context,
                          title: 'Identity',
                          subtitle:
                              'Keep your public-facing profile clear and trustworthy for clients.',
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: _displayNameController,
                                label: 'Display Name',
                                hint: 'How you want to be called',
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Display name is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _firstNameController,
                                      label: 'First Name',
                                      hint: 'Your first name',
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _lastNameController,
                                      label: 'Last Name',
                                      hint: 'Your last name',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _phoneController,
                                label: 'Phone Number',
                                hint: 'Your contact number',
                                keyboardType: TextInputType.phone,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSectionCard(
                          context: context,
                          title: 'About Your Service',
                          subtitle:
                              'Help customers understand your strengths and the kind of work you do.',
                          child: _buildTextField(
                            controller: _bioController,
                            label: 'Bio',
                            hint:
                                'Tell clients about yourself and your services...',
                            maxLines: 5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSectionCard(
                          context: context,
                          title: 'Service Location',
                          subtitle:
                              'Pin where you typically operate from so clients can find you faster.',
                          child: _buildLocationCard(context),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isSaving ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.of(context).primary,
                              foregroundColor: AppTheme.of(context).secondaryBackground,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: isSaving
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppTheme.of(context).secondaryBackground,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Save Changes',
                                    style: AppTheme.of(context)
                                        .titleSmall
                                        .override(
                                          color: AppTheme.of(context).secondaryBackground,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                          ),
                        ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      );

  Widget _buildProfileHero(BuildContext context) {
    final hasPhoto = _selectedImage != null || _currentPhotoUrl != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.of(context).primary,
                      AppTheme.of(context).primary.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  image: _selectedImage != null
                      ? DecorationImage(
                          fit: BoxFit.cover,
                          image: FileImage(_selectedImage!),
                        )
                      : _currentPhotoUrl != null
                          ? DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(_currentPhotoUrl!),
                            )
                          : null,
                ),
                child: !hasPhoto
                    ? Icon(
                        Icons.person_rounded,
                        color: AppTheme.of(context).secondaryBackground,
                        size: 52,
                      )
                    : null,
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _pickImage,
                    borderRadius: BorderRadius.circular(18),
                    child: Ink(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.of(context).primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.of(context).secondaryBackground, width: 2),
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: AppTheme.of(context).secondaryBackground,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Present your best provider profile',
            style: AppTheme.of(context).titleMedium.override(
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Update your identity, contact details, and service base in one place.',
            style: AppTheme.of(context).bodyMedium.override(
                  color: AppTheme.of(context).secondaryText,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _pickImage,
            child: Text(
              'Change Photo',
              style: AppTheme.of(context).bodyMedium.override(
                    color: AppTheme.of(context).primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Widget child,
  }) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTheme.of(context).titleMedium.override(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: AppTheme.of(context).bodySmall.override(
                    color: AppTheme.of(context).secondaryText,
                    lineHeight: 1.35,
                  ),
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      );

  Widget _buildLocationCard(BuildContext context) {
    final hasLocation = _latitude != null && _longitude != null;
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: hasLocation
                  ? AppTheme.of(context).primary.withValues(alpha: 0.28)
                  : AppTheme.of(context).primaryText.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: hasLocation
                      ? AppTheme.of(context).primary.withValues(alpha: 0.12)
                      : AppTheme.of(context).border,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  hasLocation ? Icons.location_on : Icons.location_off_outlined,
                  color: hasLocation
                      ? AppTheme.of(context).primary
                      : AppTheme.of(context).secondaryText,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasLocation
                          ? 'Pinned service area'
                          : 'No service area set',
                      style: AppTheme.of(context).bodySmall.override(
                            color: AppTheme.of(context).secondaryText,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _locationLabel ??
                          'Tap below to pin your service location',
                      style: AppTheme.of(context).bodyMedium.override(
                            fontWeight: FontWeight.w600,
                            color: hasLocation
                                ? AppTheme.of(context).primaryText
                                : AppTheme.of(context).secondaryText,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _openPinLocation,
            icon: Icon(
              Icons.map_outlined,
              size: 18,
              color: AppTheme.of(context).primary,
            ),
            label: Text(
              hasLocation ? 'Change location on map' : 'Pin location on map',
              style: AppTheme.of(context).bodyMedium.override(
                    color: AppTheme.of(context).primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppTheme.of(context).primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.of(context).bodyMedium.override(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTheme.of(context).bodyMedium.override(
                    color: AppTheme.of(context).secondaryText,
                  ),
              filled: true,
              fillColor: AppTheme.of(context).secondaryBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color:
                      AppTheme.of(context).primaryText.withValues(alpha: 0.08),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color:
                      AppTheme.of(context).primaryText.withValues(alpha: 0.08),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppTheme.of(context).primary,
                  width: 1.6,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppTheme.of(context).error,
                  width: 1.2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppTheme.of(context).error,
                  width: 1.4,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: AppTheme.of(context).bodyLarge,
          ),
        ],
      );
}
