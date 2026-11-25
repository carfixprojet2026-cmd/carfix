import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../data/models/oil_brand_model.dart';
import '../../data/services/oils_catalog_service.dart';

class AddBrandDialog extends StatefulWidget {
  final OilsCatalogService service;

  const AddBrandDialog({super.key, required this.service});

  @override
  State<AddBrandDialog> createState() => _AddBrandDialogState();
}

class _AddBrandDialogState extends State<AddBrandDialog> {
  final _nameController = TextEditingController();
  final _manufacturerController = TextEditingController();
  String _selectedTier = 'OEM Partner';
  File? _selectedImage;
  bool _isSaving = false;
  String _statusMessage = '';

  final ImagePicker _picker = ImagePicker();

  final List<String> _tiers = [
    'OEM Partner',
    'OEM Certified',
    'Aftermarket High-Spec',
    'Motorsport High-Spec',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _manufacturerController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library,
                    color: AppColors.primaryOrange),
                title: const Text('Pick from Gallery',
                    style: TextStyle(color: AppColors.onSurface)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.camera_alt, color: AppColors.primaryOrange),
                title: const Text('Take a Photo',
                    style: TextStyle(color: AppColors.onSurface)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              if (_selectedImage != null)
                ListTile(
                  leading:
                      const Icon(Icons.delete_outline, color: AppColors.error),
                  title: const Text('Remove Image',
                      style: TextStyle(color: AppColors.error)),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    setState(() => _selectedImage = null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _isSaving = true;
      _statusMessage = 'Uploading to Cloudinary...';
    });

    try {
      String? uploadedUrl;

      // Upload selected image to user's Cloudinary account
      if (_selectedImage != null) {
        uploadedUrl = await CloudinaryService.uploadImage(
          _selectedImage!,
          folder: 'carfix_brands',
        );
      }

      setState(() => _statusMessage = 'Saving to Firebase...');

      final brandId = name.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
      final newBrand = OilBrandModel(
        id: brandId,
        name: name,
        manufacturer: _manufacturerController.text.trim().isEmpty
            ? name
            : _manufacturerController.text.trim(),
        tier: _selectedTier,
        oilCount: 0,
        logoUrl: uploadedUrl,
        createdAt: DateTime.now(),
      );

      await widget.service.addBrand(newBrand);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save brand: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _statusMessage = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.storefront_outlined,
                          color: AppColors.primaryOrange, size: 22),
                      const SizedBox(width: 8),
                      const Text(
                        'Register New Oil Brand',
                        style: TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close,
                        color: AppColors.textMuted, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Image Picker Section (Cloudinary)
              const Text(
                'BRAND LOGO / BADGE',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: InkWell(
                  onTap: _isSaving ? null : _showImageSourcePicker,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    height: 110,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedImage != null
                            ? AppColors.primaryOrange
                            : AppColors.borderSlate,
                        width: 1.5,
                      ),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  alignment: Alignment.bottomRight,
                                  padding: const EdgeInsets.all(8),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryOrange,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.edit,
                                        size: 14, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add_photo_alternate_outlined,
                                  color: AppColors.primaryOrange, size: 32),
                              SizedBox(height: 6),
                              Text(
                                'Tap to choose logo (Cloudinary)',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Brand Name
              const Text(
                'BRAND NAME',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                style:
                    const TextStyle(color: AppColors.onSurface, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'e.g. Pennzoil, TotalEnergies, Ravenol',
                  hintStyle:
                      const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLowest,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Manufacturer / Parent Org
              const Text(
                'MANUFACTURER / PARENT ORG',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _manufacturerController,
                style:
                    const TextStyle(color: AppColors.onSurface, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'e.g. Shell Global, Total Group',
                  hintStyle:
                      const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLowest,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Brand Tier
              const Text(
                'BRAND TIER / CERTIFICATION',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tiers.map((tier) {
                  final isSelected = _selectedTier == tier;
                  return InkWell(
                    onTap: () => setState(() => _selectedTier = tier),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryOrange.withValues(alpha: 0.2)
                            : AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryOrange
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        tier,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primaryOrange
                              : AppColors.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: const BorderSide(color: AppColors.borderSlate),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isSaving ? null : _handleSave,
                      child: _isSaving
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    _statusMessage.isNotEmpty
                                        ? _statusMessage
                                        : 'Saving...',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            )
                          : const Text(
                              'Save Brand',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
