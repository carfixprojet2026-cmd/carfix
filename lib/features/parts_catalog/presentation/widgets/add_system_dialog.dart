import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../data/models/part_category_model.dart';
import '../../data/services/parts_catalog_service.dart';

class AddSystemDialog extends StatefulWidget {
  final PartsCatalogService service;

  const AddSystemDialog({super.key, required this.service});

  @override
  State<AddSystemDialog> createState() => _AddSystemDialogState();
}

class _AddSystemDialogState extends State<AddSystemDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedIcon = 'disc_full';
  File? _selectedImage;
  bool _isSaving = false;
  String _statusMessage = '';

  final ImagePicker _picker = ImagePicker();

  final List<Map<String, dynamic>> _iconOptions = [
    {'name': 'disc_full', 'icon': Icons.album_outlined, 'label': 'Brakes'},
    {'name': 'air', 'icon': Icons.air, 'label': 'Intake'},
    {'name': 'settings_suggest', 'icon': Icons.settings_suggest, 'label': 'Engine'},
    {'name': 'swap_vert', 'icon': Icons.swap_vert, 'label': 'Suspension'},
    {'name': 'fact_check', 'icon': Icons.fact_check, 'label': 'Filters'},
    {'name': 'bolt', 'icon': Icons.bolt, 'label': 'Electrical'},
    {'name': 'build', 'icon': Icons.build, 'label': 'General'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
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

  void _showImagePickerSource() {
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
                leading: const Icon(Icons.photo_library, color: AppColors.primaryOrange),
                title: const Text('Pick from Gallery', style: TextStyle(color: AppColors.onSurface)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primaryOrange),
                title: const Text('Take a Photo', style: TextStyle(color: AppColors.onSurface)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              if (_selectedImage != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.error),
                  title: const Text('Remove Image', style: TextStyle(color: AppColors.error)),
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
      if (_selectedImage != null) {
        uploadedUrl = await CloudinaryService.uploadImage(
          _selectedImage!,
          folder: 'carfix_categories',
        );
      }

      setState(() => _statusMessage = 'Saving to Firebase...');

      final categoryId = name
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]'), '_')
          .replaceAll(RegExp(r'_+'), '_');

      final newCategory = PartCategoryModel(
        id: categoryId,
        name: name,
        description: _descriptionController.text.trim(),
        iconName: _selectedIcon,
        partsCount: 0,
        imageUrl: uploadedUrl,
        createdAt: DateTime.now(),
      );

      await widget.service.addCategory(newCategory);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving category: $e')),
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
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.folder_special,
                          color: AppColors.primaryOrange,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Register System / Category',
                        style: TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category Visual Image Upload
              const Text(
                'CATEGORY COVER IMAGE (CLOUDINARY)',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _isSaving ? null : _showImagePickerSource,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _selectedImage != null
                          ? AppColors.primaryOrange
                          : AppColors.borderSlate,
                      width: 1.5,
                    ),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(_selectedImage!, fit: BoxFit.cover),
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
                                  child: const Icon(Icons.edit, size: 14, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add_photo_alternate_outlined,
                                color: AppColors.primaryOrange, size: 30),
                            SizedBox(height: 6),
                            Text(
                              'Tap to upload category image',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // System / Category Name
              const Text(
                'SYSTEM / CATEGORY NAME',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'e.g. Transmission & Gearbox, Brakes & Braking',
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLowest,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              const Text(
                'DESCRIPTION / COMPONENT SCOPE',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _descriptionController,
                style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'e.g. Gears, clutches, flywheels and syncros',
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLowest,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Icon selector
              const Text(
                'SYSTEM ICON BADGE',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _iconOptions.map((opt) {
                  final isSelected = _selectedIcon == opt['name'];
                  return InkWell(
                    onTap: () => setState(() => _selectedIcon = opt['name'] as String),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryOrange.withValues(alpha: 0.2)
                            : AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryOrange : AppColors.borderSlate,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            opt['icon'] as IconData,
                            size: 16,
                            color: isSelected ? AppColors.primaryOrange : AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            opt['label'] as String,
                            style: TextStyle(
                              color: isSelected ? AppColors.primaryOrange : AppColors.onSurface,
                              fontSize: 11.5,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
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
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: const BorderSide(color: AppColors.borderSlate),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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
                                    _statusMessage,
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
                              'Register System',
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
