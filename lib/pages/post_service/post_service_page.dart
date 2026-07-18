import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '/api/models/category.dart';
import '/api/models/service_listing.dart';
import '/api/resources/services_api.dart';
import '/theme/app_theme.dart';

/// Create or edit a service listing.
///
/// Mirrors `shph-app/src/views/provider/PostServicePage.vue`. Backed by
/// `ShphServicesApi.createListing()` / `updateListing()` / `uploadListingImage()`.
class PostServicePage extends StatefulWidget {
  const PostServicePage({super.key, this.listingId});

  final int? listingId;

  static String routeName = 'PostService';
  static String routePath = '/provider/post-service';

  @override
  State<PostServicePage> createState() => _PostServicePageState();
}

class _PostServicePageState extends State<PostServicePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  List<ShphCategory> _categories = const [];
  ShphCategory? _selectedCategory;
  bool _isAvailable = true;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isUploading = false;
  String? _errorMessage;
  String? _thumbnailUrl;
  File? _pickedImage;

  bool get _isEdit => widget.listingId != null;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    try {
      final catResp = await ShphServicesApi.instance.listCategories();
      ShphServiceListing? existing;
      if (_isEdit) {
        existing = await ShphServicesApi.instance.getListing(widget.listingId!);
      }
      if (mounted) {
        setState(() {
          _categories = catResp.results;
          if (existing != null) {
            final existingCategory = existing.category;
            _titleCtrl.text = existing.title;
            _descriptionCtrl.text = existing.description ?? '';
            if (existing.basePrice != null) {
              _priceCtrl.text = existing.basePrice!.toStringAsFixed(2);
            }
            _selectedCategory = _categories
                .where((c) => c.id == existingCategory)
                .cast<ShphCategory?>()
                .firstWhere((c) => c != null, orElse: () => null);
            _isAvailable = existing.isAvailable == 'true';
            _thumbnailUrl = existing.thumbnail;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load: $e';
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() {
      _pickedImage = File(picked.path);
      _isUploading = true;
    });
    try {
      if (_isEdit && widget.listingId != null) {
        final resp = await ShphServicesApi.instance
            .uploadListingImage(widget.listingId!, _pickedImage!);
        if (mounted) {
          setState(() {
            _thumbnailUrl = resp['image'] as String? ?? resp['url'] as String?;
            _isUploading = false;
          });
        }
      } else {
        // For new listings, the image is uploaded after create.
        setState(() => _isUploading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image upload failed: $e')),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      setState(() => _errorMessage = 'Please select a category');
      return;
    }
    final price = double.tryParse(_priceCtrl.text);
    if (price == null || price <= 0) {
      setState(() => _errorMessage = 'Price must be greater than 0');
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    final payload = <String, dynamic>{
      'title': _titleCtrl.text.trim(),
      'description': _descriptionCtrl.text.trim(),
      'category': _selectedCategory!.id,
      'base_price': price,
      'is_available': _isAvailable,
    };
    try {
      if (_isEdit && widget.listingId != null) {
        await ShphServicesApi.instance
            .updateListing(widget.listingId!, payload);
        if (_pickedImage != null) {
          await ShphServicesApi.instance
              .uploadListingImage(widget.listingId!, _pickedImage!);
        }
      } else {
        final created = await ShphServicesApi.instance.createListing(payload);
        if (_pickedImage != null) {
          await ShphServicesApi.instance
              .uploadListingImage(created.id, _pickedImage!);
        }
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = 'Failed to save: $e';
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
        title: Text(_isEdit ? 'Edit Service' : 'Post Service',
            style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
        backgroundColor: theme.primaryBackground,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                children: [
                  _ThumbnailPicker(
                    imageUrl: _thumbnailUrl,
                    pickedFile: _pickedImage,
                    isUploading: _isUploading,
                    onTap: _pickImage,
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel(theme: theme, text: 'Title'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Home cleaning service',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel(theme: theme, text: 'Category'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<ShphCategory>(
                    initialValue: _selectedCategory,
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                    items: _categories
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.name),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v),
                    hint: const Text('Select a category'),
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel(theme: theme, text: 'Description'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _descriptionCtrl,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Describe what you offer, scope, inclusions',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel(theme: theme, text: 'Base price (PHP)'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      prefixText: 'PHP ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title:
                        Text('Available for booking', style: theme.bodyMedium),
                    value: _isAvailable,
                    onChanged: (v) => setState(() => _isAvailable = v),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(_errorMessage!,
                        style: theme.bodyMedium.override(color: theme.error)),
                  ],
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: Text(_isSubmitting
                        ? 'Saving…'
                        : _isEdit
                            ? 'Save Changes'
                            : 'Post Service'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.theme, required this.text});
  final AppThemeData theme;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: theme.bodyMedium.override(fontWeight: FontWeight.w700));
  }
}

class _ThumbnailPicker extends StatelessWidget {
  const _ThumbnailPicker({
    required this.imageUrl,
    required this.pickedFile,
    required this.isUploading,
    required this.onTap,
  });

  final String? imageUrl;
  final File? pickedFile;
  final bool isUploading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final showFile = pickedFile != null;
    final showUrl = !showFile && imageUrl != null && imageUrl!.isNotEmpty;
    return InkWell(
      onTap: isUploading ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: theme.primaryBackground,
          borderRadius: BorderRadius.circular(14),
          image: showFile
              ? DecorationImage(
                  image: FileImage(pickedFile!), fit: BoxFit.cover)
              : showUrl
                  ? DecorationImage(
                      image: NetworkImage(imageUrl!), fit: BoxFit.cover)
                  : null,
        ),
        child: (showFile || showUrl)
            ? (isUploading
                ? Container(
                    color: Colors.black38,
                    child: const Center(
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    ),
                  )
                : Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.black54,
                        child: const Icon(Icons.edit,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ))
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined,
                        size: 40, color: theme.secondaryText),
                    const SizedBox(height: 6),
                    Text('Add thumbnail',
                        style: theme.bodyMedium
                            .override(color: theme.secondaryText)),
                  ],
                ),
              ),
      ),
    );
  }
}
