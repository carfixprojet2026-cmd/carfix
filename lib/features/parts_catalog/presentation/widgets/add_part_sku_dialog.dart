import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../data/models/part_category_model.dart';
import '../../data/models/spare_part_model.dart';
import '../../data/services/parts_catalog_service.dart';

class AddPartSkuDialog extends StatefulWidget {
  final PartsCatalogService service;
  final List<PartCategoryModel> availableCategories;
  final PartCategoryModel? initialCategory;

  const AddPartSkuDialog({
    super.key,
    required this.service,
    required this.availableCategories,
    this.initialCategory,
  });

  @override
  State<AddPartSkuDialog> createState() => _AddPartSkuDialogState();
}

class _AddPartSkuDialogState extends State<AddPartSkuDialog> {
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _oemController = TextEditingController();
  final _fitmentController = TextEditingController();
  final _positionController = TextEditingController(text: 'Front Axle Set');
  final _priceController = TextEditingController();
  final _shopsCountController = TextEditingController(text: '12');

  late PartCategoryModel? _selectedCategory;
  String _selectedSpecTag = 'Standard Spec';
  File? _selectedImage;
  bool _isSaving = false;
  String _statusMessage = '';

  final ImagePicker _picker = ImagePicker();

  final List<String> _specTags = [
    'Standard Spec',
    'High Temp Teflon',
    'Specialty Order',
    'High Thermal',
    'OEM Replacement',
    'Track & Street',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ??
        (widget.availableCategories.isNotEmpty ? widget.availableCategories.first : null);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _oemController.dispose();
    _fitmentController.dispose();
    _positionController.dispose();
    _priceController.dispose();
    _shopsCountController.dispose();
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
    final sku = _skuController.text.trim();
    if (name.isEmpty || sku.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter part name, SKU, and category')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _statusMessage = 'Uploading to Cloudinary...';
    });

    try {
      String? uploadedUrl;
      if (_selectedImage != null) {
        uploadedUrl = await CloudinaryService.uploadImage(
          _selectedImage!,
          folder: 'carfix_parts',
        );
      }

      setState(() => _statusMessage = 'Saving to Firebase...');

      final price = double.tryParse(_priceController.text.trim());
      final shops = int.tryParse(_shopsCountController.text.trim()) ?? 1;

      final newPart = SparePartModel(
        id: '',
        categoryId: _selectedCategory!.id,
        category: _selectedCategory!.name,
        partName: name,
        partNumber: sku,
        oemCrossRef: _oemController.text.trim(),
        fitment: _fitmentController.text.trim(),
        position: _positionController.text.trim().isNotEmpty
            ? _positionController.text.trim()
            : 'General Component',
        specTag: _selectedSpecTag,
        partnerShopsCount: shops,
        price: price,
        imageUrl: uploadedUrl,
        createdAt: DateTime.now(),
      );

      await widget.service.addPart(newPart);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error registering part: $e')),
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
                          Icons.post_add,
                          color: AppColors.primaryOrange,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Add Specific Part SKU',
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

              // Image Picker Section
              const Text(
                'PART PHOTO / DIAGRAM (CLOUDINARY)',
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
                  height: 100,
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
                                color: AppColors.primaryOrange, size: 28),
                            SizedBox(height: 6),
                            Text(
                              'Tap to upload part image',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Parent System / Category Dropdown
              const Text(
                'PARENT SYSTEM / CATEGORY',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<PartCategoryModel>(
                    value: _selectedCategory,
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceContainerHigh,
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
                    items: widget.availableCategories.map((cat) {
                      return DropdownMenuItem<PartCategoryModel>(
                        value: cat,
                        child: Text(
                          cat.name,
                          style: const TextStyle(color: AppColors.onSurface, fontSize: 13.5),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Part Component Name
              const Text(
                'PART COMPONENT NAME',
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
                  hintText: 'e.g. StopTech Sport Slotted Rotors',
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

              // Manufacturer SKU & OEM Cross Ref
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MANUFACTURER SKU',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _skuController,
                          style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'ST-ROT-992',
                            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
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
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'OEM CROSS REF',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _oemController,
                          style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: '992-351-405',
                            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
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
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Applicable Vehicle Fitment
              const Text(
                'APPLICABLE VEHICLE FITMENT',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _fitmentController,
                style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'e.g. Porsche 911 Carrera (992), BMW M3/M4 (G80/G82)',
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

              // Position & Spec Tag
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'POSITION / DETAIL',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _positionController,
                          style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Front Axle Set',
                            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
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
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SPECIFICATION TAG',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedSpecTag,
                              isExpanded: true,
                              dropdownColor: AppColors.surfaceContainerHigh,
                              icon: const Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
                              items: _specTags.map((tag) {
                                return DropdownMenuItem<String>(
                                  value: tag,
                                  child: Text(
                                    tag,
                                    style: const TextStyle(
                                        color: AppColors.onSurface, fontSize: 12.5),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedSpecTag = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                              'Register SKU',
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
