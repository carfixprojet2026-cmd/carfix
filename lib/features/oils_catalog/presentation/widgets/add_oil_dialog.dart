import 'package:material_ui/material_ui.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/oil_brand_model.dart';
import '../../data/models/oil_formula_model.dart';
import '../../data/services/oils_catalog_service.dart';

class AddOilDialog extends StatefulWidget {
  final OilsCatalogService service;
  final List<OilBrandModel> availableBrands;
  final OilBrandModel? initialBrand;

  const AddOilDialog({
    super.key,
    required this.service,
    required this.availableBrands,
    this.initialBrand,
  });

  @override
  State<AddOilDialog> createState() => _AddOilDialogState();
}

class _AddOilDialogState extends State<AddOilDialog> {
  late OilBrandModel? _selectedBrand;
  final _viscosityController = TextEditingController(text: '5W-30');
  final _titleController = TextEditingController();
  final _oemSpecsController = TextEditingController();
  String _selectedComposition = 'Full Synthetic';
  String _selectedCategoryTag = 'Euro Spec';
  bool _isSaving = false;

  final List<String> _compositions = [
    'Full Synthetic',
    'Synthetic Blend',
    'Conventional Mineral',
    'Racing Ester',
  ];

  final List<String> _categoryTags = [
    'Euro Spec',
    'Clean Diesel',
    'Standard',
    'Ultra-Low Vis',
    'Motorsport',
    'Euro OEM',
  ];

  @override
  void initState() {
    super.initState();
    _selectedBrand = widget.initialBrand ??
        (widget.availableBrands.isNotEmpty
            ? widget.availableBrands.first
            : null);
  }

  @override
  void dispose() {
    _viscosityController.dispose();
    _titleController.dispose();
    _oemSpecsController.dispose();
    super.dispose();
  }

  Future<void> _handlePublish() async {
    if (_selectedBrand == null) return;
    final title = _titleController.text.trim();
    final viscosity = _viscosityController.text.trim();
    if (title.isEmpty || viscosity.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final newFormula = OilFormulaModel(
        id: '',
        brandId: _selectedBrand!.id,
        brandName: _selectedBrand!.name,
        viscosity: viscosity,
        title: title,
        composition: _selectedComposition,
        oemSpecs: _oemSpecsController.text.trim(),
        categoryTag: _selectedCategoryTag,
        activeGaragesCount: 1,
        createdAt: DateTime.now(),
      );

      await widget.service.addOilFormula(newFormula);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to publish oil: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
                      const Icon(Icons.oil_barrel_outlined,
                          color: AppColors.primaryOrange, size: 22),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Add Oil Spec',
                            style: TextStyle(
                              color: AppColors.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_selectedBrand != null)
                            Text(
                              'Target: ${_selectedBrand!.name}',
                              style: const TextStyle(
                                color: AppColors.primaryOrange,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
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

              // Brand Selector (if multiple available)
              if (widget.availableBrands.length > 1) ...[
                const Text(
                  'SELECT BRAND',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
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
                    child: DropdownButton<OilBrandModel>(
                      value: _selectedBrand,
                      isExpanded: true,
                      dropdownColor: AppColors.surfaceContainerHigh,
                      items: widget.availableBrands.map((brand) {
                        return DropdownMenuItem(
                          value: brand,
                          child: Text(brand.name,
                              style: const TextStyle(
                                  color: AppColors.onSurface, fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedBrand = val),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Viscosity & Composition Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'VISCOSITY GRADE',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _viscosityController,
                          style: const TextStyle(
                              color: AppColors.onSurface, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: '0W-40, 5W-30',
                            hintStyle: const TextStyle(
                                color: AppColors.textMuted, fontSize: 12),
                            filled: true,
                            fillColor: AppColors.surfaceContainerLowest,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
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
                          'CATEGORY TAG',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCategoryTag,
                              isExpanded: true,
                              dropdownColor: AppColors.surfaceContainerHigh,
                              items: _categoryTags.map((tag) {
                                return DropdownMenuItem(
                                  value: tag,
                                  child: Text(tag,
                                      style: const TextStyle(
                                          color: AppColors.onSurface,
                                          fontSize: 12)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedCategoryTag = val);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Formula Title
              const Text(
                'FORMULA / SUB-BRAND TITLE',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _titleController,
                style: const TextStyle(color: AppColors.onSurface, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'e.g. FS European Car Formula, ESP Emission Guard',
                  hintStyle:
                      const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLowest,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Composition
              const Text(
                'BASE COMPOSITION',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _compositions.map((comp) {
                  final isSelected = _selectedComposition == comp;
                  return InkWell(
                    onTap: () => setState(() => _selectedComposition = comp),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryOrange.withValues(alpha: 0.2)
                            : AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryOrange
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        comp,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primaryOrange
                              : AppColors.onSurface,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // OEM Approvals
              const Text(
                'OEM APPROVALS & SPECS',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _oemSpecsController,
                style: const TextStyle(color: AppColors.onSurface, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'e.g. Porsche A40, MB 229.5, VW 502 00, BMW LL-01',
                  hintStyle:
                      const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLowest,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
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
                      onPressed: _isSaving ? null : _handlePublish,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Publish Oil',
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
