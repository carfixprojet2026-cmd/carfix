import 'package:material_ui/material_ui.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/oil_brand_model.dart';
import '../../data/models/oil_formula_model.dart';
import '../../data/services/oils_catalog_service.dart';

class BrandAccordionCard extends StatefulWidget {
  final OilBrandModel brand;
  final OilsCatalogService service;
  final bool initialExpanded;
  final VoidCallback onAddOilPressed;

  const BrandAccordionCard({
    super.key,
    required this.brand,
    required this.service,
    this.initialExpanded = false,
    required this.onAddOilPressed,
  });

  @override
  State<BrandAccordionCard> createState() => _BrandAccordionCardState();
}

class _BrandAccordionCardState extends State<BrandAccordionCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initialExpanded;
  }

  Future<void> _confirmDeleteBrand(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: AppColors.error, size: 24),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Delete ${widget.brand.name}?',
                style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Text(
          'This will permanently remove ${widget.brand.name} and all its associated oil formulations from Firebase.',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete Brand',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.service.deleteBrand(widget.brand.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSlate.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Brand Trigger Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              padding: const EdgeInsets.all(14.0),
              color: AppColors.surfaceContainer,
              child: Column(
                children: [
                  Row(
                    children: [
                      // Thumbnail
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.borderSlate,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: widget.brand.logoUrl != null
                            ? Image.network(
                                widget.brand.logoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Center(
                                  child: Icon(Icons.oil_barrel,
                                      color: AppColors.primaryOrange, size: 22),
                                ),
                              )
                            : const Center(
                                child: Icon(Icons.oil_barrel,
                                    color: AppColors.primaryOrange, size: 22),
                              ),
                      ),
                      const SizedBox(width: 12),

                      // Brand Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    widget.brand.name,
                                    style: const TextStyle(
                                      color: AppColors.onSurface,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryOrange
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    widget.brand.tier,
                                    style: const TextStyle(
                                      color: AppColors.primaryOrange,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${widget.brand.manufacturer} • ${widget.brand.oilCount} Formulations cataloged',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Chevron Icon
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 250),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: _isExpanded
                                ? AppColors.primaryOrange
                                : AppColors.textMuted,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // In-Header Action when expanded
                  if (_isExpanded) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryOrange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'ACTIVE BRAND SCOPE',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Delete Brand button
                            InkWell(
                              onTap: () => _confirmDeleteBrand(context),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColors.error.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.error,
                                  size: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Add Oil button
                            InkWell(
                              onTap: widget.onAddOilPressed,
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryOrange,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryOrange
                                          .withValues(alpha: 0.35),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.add,
                                        color: Colors.white, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Add Oil to ${widget.brand.name}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Collapsible Formulas List
          if (_isExpanded)
            StreamBuilder<List<OilFormulaModel>>(
              stream: widget.service.getFormulasForBrandStream(widget.brand.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  );
                }

                final formulas = snapshot.data ?? [];
                if (formulas.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    color: AppColors.surfaceContainerLowest,
                    child: Column(
                      children: [
                        const Icon(Icons.info_outline,
                            color: AppColors.textMuted, size: 24),
                        const SizedBox(height: 6),
                        Text(
                          'No oil formulas registered yet for ${widget.brand.name}',
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }

                return Container(
                  color: AppColors.surfaceContainerLowest,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: formulas.map((formula) {
                      return _buildFormulaItem(context, formula);
                    }).toList(),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFormulaItem(BuildContext context, OilFormulaModel formula) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSlate.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Viscosity Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  formula.viscosity,
                  style: const TextStyle(
                    color: AppColors.primaryOrange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formula.title,
                      style: const TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${formula.composition} • ${formula.oemSpecs}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Category Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  formula.categoryTag,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Footer with Garages count and Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_gas_station,
                      color: AppColors.primaryOrange, size: 14),
                  const SizedBox(width: 4),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 11.5),
                      children: [
                        const TextSpan(text: 'Active in '),
                        TextSpan(
                          text: '${formula.activeGaragesCount} ',
                          style: const TextStyle(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: 'Garages'),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Edit Action
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Edit ${formula.title}')),
                      );
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.edit,
                          color: AppColors.textMuted, size: 14),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Delete Action
                  InkWell(
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppColors.surfaceContainerHigh,
                          title: const Text('Remove Oil Formula',
                              style: TextStyle(color: AppColors.onSurface)),
                          content: Text(
                              'Are you sure you want to remove ${formula.title}?',
                              style: const TextStyle(
                                  color: AppColors.textSecondary)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancel',
                                  style: TextStyle(
                                      color: AppColors.textSecondary)),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.error),
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Delete',
                                  style: TextStyle(color: Colors.black)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await widget.service.deleteOilFormula(
                          formula.id,
                          formula.brandId,
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.delete_outline,
                          color: AppColors.error, size: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
