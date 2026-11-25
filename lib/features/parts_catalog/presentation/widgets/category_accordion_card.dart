import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/part_category_model.dart';
import '../../data/models/spare_part_model.dart';
import '../../data/services/parts_catalog_service.dart';

class CategoryAccordionCard extends StatefulWidget {
  final PartCategoryModel category;
  final PartsCatalogService service;
  final bool initialExpanded;
  final VoidCallback onAddPartPressed;

  const CategoryAccordionCard({
    super.key,
    required this.category,
    required this.service,
    this.initialExpanded = false,
    required this.onAddPartPressed,
  });

  @override
  State<CategoryAccordionCard> createState() => _CategoryAccordionCardState();
}

class _CategoryAccordionCardState extends State<CategoryAccordionCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initialExpanded;
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'disc_full':
        return Icons.album_outlined;
      case 'air':
        return Icons.air;
      case 'settings_suggest':
        return Icons.settings_suggest;
      case 'swap_vert':
        return Icons.swap_vert;
      case 'fact_check':
        return Icons.fact_check;
      case 'bolt':
        return Icons.bolt;
      default:
        return Icons.build;
    }
  }

  Future<void> _confirmDeleteCategory(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.error,
              size: 24,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Delete ${widget.category.name}?',
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Text(
          'This will permanently remove ${widget.category.name} and all parts registered under it from Firebase.',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Delete System',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.service.deleteCategory(widget.category.id);
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
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header Bar
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              padding: const EdgeInsets.all(14.0),
              color: AppColors.surfaceContainer,
              child: Column(
                children: [
                  Row(
                    children: [
                      // Visual Thumbnail or Icon Container
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderSlate),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: widget.category.imageUrl != null
                            ? Image.network(
                                widget.category.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Center(
                                  child: Icon(
                                    _getCategoryIcon(widget.category.iconName),
                                    color: AppColors.primaryOrange,
                                    size: 22,
                                  ),
                                ),
                              )
                            : Center(
                                child: Icon(
                                  _getCategoryIcon(widget.category.iconName),
                                  color: AppColors.primaryOrange,
                                  size: 22,
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),

                      // System / Category Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.category.name,
                              style: const TextStyle(
                                color: AppColors.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.category.description.isNotEmpty
                                  ? widget.category.description
                                  : '${widget.category.partsCount} Standardized Parts',
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

                  // Actions sub-bar when expanded
                  if (_isExpanded) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'SHOP INVENTORY LINKED PARTS',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Delete Category Button
                            InkWell(
                              onTap: () => _confirmDeleteCategory(context),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColors.error.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.error,
                                  size: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),

                            // Add Part to Category Button
                            InkWell(
                              onTap: widget.onAddPartPressed,
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryOrange,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryOrange.withValues(
                                        alpha: 0.35,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Add Part',
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

          // Collapsible Parts Stream
          if (_isExpanded)
            StreamBuilder<List<SparePartModel>>(
              stream: widget.service.getPartsForCategoryStream(
                widget.category.id,
              ),
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

                final parts = snapshot.data ?? [];
                if (parts.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    color: AppColors.surfaceContainerLowest,
                    child: Column(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.textMuted,
                          size: 24,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'No parts registered yet for ${widget.category.name}',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Container(
                  color: AppColors.surfaceContainerLowest,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: parts.map((part) {
                      return _buildPartItem(context, part);
                    }).toList(),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPartItem(BuildContext context, SparePartModel part) {
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
              // Part Image / Thumbnail
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: part.imageUrl != null
                    ? Image.network(
                        part.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(
                            Icons.build,
                            color: AppColors.primaryOrange,
                            size: 22,
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.build,
                          color: AppColors.primaryOrange,
                          size: 22,
                        ),
                      ),
              ),
              const SizedBox(width: 10),

              // Part Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      part.partName,
                      style: const TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            part.partNumber,
                            style: const TextStyle(
                              color: AppColors.primaryOrange,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '•',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            part.position,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (part.fitment.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Fitment: ${part.fitment}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Action buttons (Delete)
              InkWell(
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppColors.surfaceContainerHigh,
                      title: const Text(
                        'Remove Part SKU',
                        style: TextStyle(color: AppColors.onSurface),
                      ),
                      content: Text(
                        'Are you sure you want to remove ${part.partName} (${part.partNumber})?',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                          ),
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await widget.service.deletePart(part.id, part.categoryId);
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
                  child: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                    size: 15,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Footer info
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                part.specTag,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
