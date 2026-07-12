import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '/api/models/category.dart';
import '/api/resources/services_api.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/logging_service.dart';
import '/services/service_listing_service.dart';
import '/theme/app_theme.dart';

class CreateServiceWidget extends StatefulWidget {
  const CreateServiceWidget({super.key});

  static const String routeName = 'CreateService';
  static const String routePath = '/pro/create-service';

  @override
  State<CreateServiceWidget> createState() => _CreateServiceWidgetState();
}

class _CreateServiceWidgetState extends State<CreateServiceWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _additionalInfoController = TextEditingController();

  String? _selectedCategory;
  int? _selectedCategoryId;
  int? _selectedSubcategoryId;
  bool isLoading = false;
  bool _isEditMode = false;
  int? _editId;
  List<File> _selectedImages = [];
  List<String> _existingImageUrls = [];
  List<Map<String, dynamic>> _imageUploadData = [];

  List<ShphCategory> _categories = [];
  List<Map<String, dynamic>> _subcategories = [];
  bool _categoriesLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final params = GoRouterState.of(context).uri.queryParameters;
      final editId = params['edit'];
      if (editId != null) {
        _editId = int.tryParse(editId);
        if (_editId != null) {
          _loadListingForEdit(_editId!);
        }
      }
    });
  }

  Future<void> _fetchCategories() async {
    try {
      final page = await ShphServicesApi.instance.listCategories();
      if (mounted) {
        setState(() {
          _categories = page.results;
          _categoriesLoading = false;
        });
      }
    } catch (e) {
      LoggingService.error('Error fetching categories: $e',
          tag: 'CreateService');
      if (mounted) {
        setState(() => _categoriesLoading = false);
      }
    }
  }

  Future<void> _fetchSubcategories(int categoryId) async {
    try {
      final subs =
          await ServiceListingService.instance.listSubcategories(categoryId);
      if (mounted) {
        setState(() => _subcategories = subs);
      }
    } catch (e) {
      LoggingService.error('Error fetching subcategories: $e',
          tag: 'CreateService');
    }
  }

  Future<void> _loadListingForEdit(int id) async {
    setState(() => isLoading = true);
    try {
      final listing =
          await ServiceListingService.instance.fetchServiceListingById(id);
      if (listing != null && mounted) {
        setState(() {
          _isEditMode = true;
          _nameController.text = listing.title;
          _descriptionController.text = listing.description ?? '';
          _priceController.text =
              listing.basePrice?.toStringAsFixed(0) ?? '';
          _selectedCategory = listing.categoryName;
          _selectedCategoryId = listing.category;
          _existingImageUrls = listing.allImages;
          isLoading = false;
        });
        if (listing.category != null) {
          _fetchSubcategories(listing.category!);
        }
      } else if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load service for editing')),
        );
      }
    } catch (e) {
      LoggingService.error('Error loading listing for edit: $e',
          tag: 'CreateService');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          for (final file in pickedFiles) {
            if (_selectedImages.length < 5) {
              _selectedImages.add(File(file.path));
            }
          }
        });
      }
    } catch (e) {
      LoggingService.error('Error picking images: $e', tag: 'CreateService');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting images: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _deleteExistingImage(int index) async {
    final url = _existingImageUrls[index];
    final id = _imageUploadData
        .where((d) => d['url'] == url)
        .firstOrNull?['id'] as int?;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete this image at this time')),
      );
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Image'),
        content: const Text('Remove this image from your service?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('Remove')),
        ],
      ),
    );
    if (confirm != true || !mounted || _editId == null) return;
    try {
      await ServiceListingService.instance.deleteListingImageById(_editId!, id);
      setState(() => _existingImageUrls.removeAt(index));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove image: $e')),
      );
    }
  }

  Future<void> _setAsThumbnail(int index) async {
    final url = _existingImageUrls[index];
    final id = _imageUploadData
        .where((d) => d['url'] == url)
        .firstOrNull?['id'] as int?;
    if (id == null || _editId == null) return;
    try {
      await ShphServicesApi.instance.setListingThumbnail(_editId!, id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thumbnail updated')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to set thumbnail: $e')),
      );
    }
  }

  Future<void> _submitService() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      if (_isEditMode && _editId != null) {
        // Upload new images via API
        for (final file in _selectedImages) {
          final bytes = await file.readAsBytes();
          final fileName = file.path.split('\\').last.split('/').last;
          final uploadData =
              await ServiceListingService.instance.uploadListingImage(
            _editId!,
            fileBytes: bytes,
            fileName: fileName,
          );
          if (uploadData['id'] != null) {
            _imageUploadData.add({
              'id': uploadData['id'] as int,
              'url': uploadData['image_url'] as String?,
            });
          }
        }

        // Update listing fields
        await ServiceListingService.instance.updateListing(
          id: _editId!,
          title: _nameController.text.trim(),
          category: _selectedCategoryId,
          description: _descriptionController.text.trim(),
          basePrice: double.tryParse(_priceController.text) ?? 0.0,
        );

        LoggingService.info('Service updated: $_editId', tag: 'CreateService');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Service updated successfully!')),
          );
          context.pop();
        }
      } else {
        // Create service via API
        final payload = {
          'title': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'category': _selectedCategoryId,
          'base_price': double.tryParse(_priceController.text) ?? 0.0,
          'duration_minutes': int.tryParse(_durationController.text) ?? 60,
          'additional_info': _additionalInfoController.text.trim(),
        };
        if (_selectedSubcategoryId != null) {
          payload['subcategory'] = _selectedSubcategoryId;
        }

        final listing =
            await ServiceListingService.instance.createServiceListing(payload);
        final listingId = listing['id'] as int;

        // Upload images via API
        for (final file in _selectedImages) {
          final bytes = await file.readAsBytes();
          final fileName = file.path.split('\\').last.split('/').last;
          final uploadData =
              await ServiceListingService.instance.uploadListingImage(
            listingId,
            fileBytes: bytes,
            fileName: fileName,
          );
          if (uploadData['id'] != null) {
            _imageUploadData.add({
              'id': uploadData['id'] as int,
              'url': uploadData['image_url'] as String?,
              'listing_id': listingId,
            });
            if (uploadData['image_url'] != null) {
              _existingImageUrls.add(uploadData['image_url'] as String);
            }
          }
        }

        LoggingService.info('Service created: $listingId',
            tag: 'CreateService');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Service created successfully!')),
          );
          context.pop();
        }
      }
    } catch (e) {
      LoggingService.error('Error saving service: $e', tag: 'CreateService');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving service: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Service' : 'Create Service',
          style: AppTheme.of(context).titleLarge.override(
                font: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
        ),
        backgroundColor: AppTheme.of(context).primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Images Section
              Text(
                'Service Images',
                style: AppTheme.of(context).titleMedium.override(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add up to 5 photos of your service (optional)',
                style: AppTheme.of(context).bodySmall.override(
                      color: AppTheme.of(context).secondaryText,
                    ),
              ),
              const SizedBox(height: 12),

              // Existing images (edit mode)
              if (_existingImageUrls.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _existingImageUrls.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) =>
                          _buildExistingImagePreview(index),
                    ),
                  ),
                ),
              // Image Grid
              if (_selectedImages.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length +
                        (_selectedImages.length + _existingImageUrls.length < 5 ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      if (index == _selectedImages.length) {
                        // Add button
                        return _buildAddImageButton();
                      }
                      return _buildImagePreview(index);
                    },
                  ),
                )
              else if (_existingImageUrls.length < 5)
                _buildAddImageButton(isFullWidth: true),

              const SizedBox(height: 24),

              // Service Name
              _buildTextField(
                controller: _nameController,
                label: 'Service Name *',
                hint: 'e.g., Deep House Cleaning, Pipe Repair, etc.',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Service name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              Text(
                'Category *',
                style: AppTheme.of(context).bodyMedium.override(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedCategory == null
                        ? AppTheme.of(context).error.withValues(alpha: 0.5)
                        : AppTheme.of(context)
                            .primaryText
                            .withValues(alpha: 0.1),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: _categoriesLoading
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : DropdownButton<ShphCategory>(
                          value: _categories
                              .where((c) => c.id == _selectedCategoryId)
                              .firstOrNull,
                          hint: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Select a category',
                              style: AppTheme.of(context).bodyMedium.override(
                                    color: AppTheme.of(context).secondaryText,
                                  ),
                            ),
                          ),
                          isExpanded: true,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          borderRadius: BorderRadius.circular(12),
                          items: _categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category.name),
                            );
                          }).toList(),
                          onChanged: (ShphCategory? value) {
                            if (value == null) return;
                            setState(() {
                              _selectedCategoryId = value.id;
                              _selectedCategory = value.name;
                              _selectedSubcategoryId = null;
                              _subcategories = [];
                            });
                            _fetchSubcategories(value.id);
                          },
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Subcategory Dropdown
              if (_subcategories.isNotEmpty) ...[
                Text(
                  'Subcategory',
                  style: AppTheme.of(context).bodyMedium.override(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.of(context)
                          .primaryText
                          .withValues(alpha: 0.1),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedSubcategoryId,
                      hint: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Select subcategory (optional)',
                          style: AppTheme.of(context).bodyMedium.override(
                                color: AppTheme.of(context).secondaryText,
                              ),
                        ),
                      ),
                      isExpanded: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      borderRadius: BorderRadius.circular(12),
                      items: _subcategories.map((sub) {
                        final subId = sub['id'] as int? ?? 0;
                        final subName = sub['name'] as String? ?? '';
                        return DropdownMenuItem(
                          value: subId,
                          child: Text(subName),
                        );
                      }).toList(),
                      onChanged: (int? value) {
                        setState(() {
                          _selectedSubcategoryId = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Description
              _buildTextField(
                controller: _descriptionController,
                label: 'Description *',
                hint:
                    'Describe what your service includes, your experience, etc.',
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Price and Duration Row
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _priceController,
                      label: 'Base Price (₱) *',
                      hint: '500',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _durationController,
                      label: 'Duration (mins) *',
                      hint: '60',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Additional Info
              _buildTextField(
                controller: _additionalInfoController,
                label: 'Additional Information',
                hint: 'Any special requirements, tools needed, etc. (optional)',
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitService,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.of(context).primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _isEditMode ? 'Save Changes' : 'Create Service',
                          style: AppTheme.of(context).titleSmall.override(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddImageButton({bool isFullWidth = false}) {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: isFullWidth ? double.infinity : 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.of(context).primary.withValues(alpha: 0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 32,
              color: AppTheme.of(context).primary,
            ),
            const SizedBox(height: 4),
            Text(
              'Add Photo',
              style: AppTheme.of(context).bodySmall.override(
                    color: AppTheme.of(context).primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(int index) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: FileImage(_selectedImages[index]),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExistingImagePreview(int index) {
    final url = _existingImageUrls[index];
    final hasId = _imageUploadData.any((d) => d['url'] == url);
    return GestureDetector(
      onLongPress: hasId
          ? () => _showImageMenu(index)
          : null,
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(url),
              ),
            ),
          ),
          if (hasId)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _deleteExistingImage(index),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          if (hasId && _isEditMode)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 10)),
              ),
            ),
        ],
      ),
    );
  }

  void _showImageMenu(int index) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.star_border),
              title: const Text('Set as Thumbnail'),
              onTap: () {
                Navigator.pop(ctx);
                _setAsThumbnail(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Remove Image', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _deleteExistingImage(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.of(context).bodyMedium.override(
                fontWeight: FontWeight.w600,
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
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.of(context).primaryText.withValues(alpha: 0.1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.of(context).primaryText.withValues(alpha: 0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.of(context).primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.of(context).error,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: AppTheme.of(context).bodyLarge,
        ),
      ],
    );
  }
}
