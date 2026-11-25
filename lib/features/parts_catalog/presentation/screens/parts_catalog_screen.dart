import 'package:material_ui/material_ui.dart';
import 'package:carfix/core/constants/app_colors.dart';
import 'package:carfix/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:carfix/features/oils_catalog/presentation/screens/oils_catalog_screen.dart';
import 'package:carfix/features/parts_catalog/data/models/part_category_model.dart';
import 'package:carfix/features/parts_catalog/data/models/spare_part_model.dart';
import 'package:carfix/features/parts_catalog/data/services/parts_catalog_service.dart';
import 'package:carfix/features/parts_catalog/presentation/widgets/add_part_sku_dialog.dart';
import 'package:carfix/features/parts_catalog/presentation/widgets/add_system_dialog.dart';
import 'package:carfix/features/parts_catalog/presentation/widgets/category_accordion_card.dart';

class PartsCatalogScreen extends StatefulWidget {
  const PartsCatalogScreen({super.key});

  @override
  State<PartsCatalogScreen> createState() => _PartsCatalogScreenState();
}

class _PartsCatalogScreenState extends State<PartsCatalogScreen> {
  final PartsCatalogService _service = PartsCatalogService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final int _currentNavIndex = 2; // 2 = Parts Catalog

  @override
  void initState() {
    super.initState();
    _service.seedInitialDataIfEmpty();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddSystemDialog() {
    showDialog(
      context: context,
      builder: (_) => AddSystemDialog(service: _service),
    );
  }

  void _showAddPartSkuDialog({
    PartCategoryModel? targetCategory,
    List<PartCategoryModel>? allCategories,
  }) {
    showDialog(
      context: context,
      builder: (_) => AddPartSkuDialog(
        service: _service,
        availableCategories: allCategories ?? (targetCategory != null ? [targetCategory] : []),
        initialCategory: targetCategory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(),
      body: StreamBuilder<List<PartCategoryModel>>(
        stream: _service.getCategoriesStream(),
        builder: (context, categoriesSnapshot) {
          final categories = categoriesSnapshot.data ?? [];

          return StreamBuilder<List<SparePartModel>>(
            stream: _service.getAllPartsStream(),
            builder: (context, partsSnapshot) {
              final allParts = partsSnapshot.data ?? [];

              // Filter categories and parts by search query
              final filteredCategories = categories.where((cat) {
                if (_searchQuery.isEmpty) return true;
                final matchesCategory = cat.name.toLowerCase().contains(_searchQuery) ||
                    cat.description.toLowerCase().contains(_searchQuery);
                final matchesPart = allParts.any((p) =>
                    p.categoryId == cat.id &&
                    (p.partName.toLowerCase().contains(_searchQuery) ||
                        p.partNumber.toLowerCase().contains(_searchQuery) ||
                        p.fitment.toLowerCase().contains(_searchQuery) ||
                        p.oemCrossRef.toLowerCase().contains(_searchQuery)));
                return matchesCategory || matchesPart;
              }).toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dual Action Buttons: + Add System & + Add Part SKU
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 4,
                              shadowColor: AppColors.primaryOrange.withValues(alpha: 0.4),
                            ),
                            icon: const Icon(Icons.folder_special, size: 18),
                            label: const Text(
                              '+ Add System',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                            ),
                            onPressed: _showAddSystemDialog,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.surfaceContainerHigh,
                              foregroundColor: AppColors.onSurface,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(
                              Icons.post_add,
                              color: AppColors.primaryOrange,
                              size: 18,
                            ),
                            label: const Text(
                              '+ Add Part SKU',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                            ),
                            onPressed: () => _showAddPartSkuDialog(allCategories: categories),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Search & Filter Box
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderSlate.withValues(alpha: 0.6)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: AppColors.onSurface, fontSize: 13.5),
                        decoration: InputDecoration(
                          hintText: 'Search categories, OEM SKUs, brake pads, filters...',
                          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                          prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: AppColors.textMuted, size: 18),
                                  onPressed: () => _searchController.clear(),
                                )
                              : const Icon(Icons.tune, color: AppColors.textMuted, size: 18),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section Header with Verified SKUs Count
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryOrange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'GLOBAL MASTER CATALOG',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${allParts.length} Verified SKUs',
                            style: const TextStyle(
                              color: AppColors.primaryOrange,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Master Categories Accordion List
                    if (categoriesSnapshot.connectionState == ConnectionState.waiting) ...[
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(color: AppColors.primaryOrange),
                        ),
                      ),
                    ] else if (filteredCategories.isEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32.0),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: const [
                            Icon(Icons.inventory_2_outlined, color: AppColors.textMuted, size: 40),
                            SizedBox(height: 12),
                            Text(
                              'No matching vehicle systems or parts found',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredCategories.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final cat = filteredCategories[index];
                          return CategoryAccordionCard(
                            key: ValueKey(cat.id),
                            category: cat,
                            service: _service,
                            initialExpanded: index == 0,
                            onAddPartPressed: () => _showAddPartSkuDialog(
                              targetCategory: cat,
                              allCategories: categories,
                            ),
                          );
                        },
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Quick Telemetry & Sync Active Banner
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderSlate.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primaryOrange.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.sync,
                              color: AppColors.primaryOrange,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Catalog Sync Active',
                                  style: TextStyle(
                                    color: AppColors.onSurface,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'All ${allParts.length} SKUs pushed to partner garages & workshops',
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.verified,
                            color: AppColors.textMuted,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface.withValues(alpha: 0.95),
      elevation: 0,
      titleSpacing: 16,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primaryOrange,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryOrange,
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'CAR FIX',
            style: TextStyle(
              color: AppColors.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const Text(
            ' / ',
            style: TextStyle(color: AppColors.borderSlate, fontSize: 16),
          ),
          const Text(
            'ADMIN',
            style: TextStyle(
              color: AppColors.primaryOrange,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'SUPERADMIN',
              style: TextStyle(
                color: AppColors.primaryOrange,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.primaryOrange,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          top: BorderSide(color: AppColors.borderSlate.withValues(alpha: 0.6)),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.dashboard_outlined, 'Dashboard'),
              _buildNavItem(1, Icons.oil_barrel_outlined, 'Oils Catalog'),
              _buildNavItem(2, Icons.build, 'Parts Catalog'),
              _buildNavItem(3, Icons.verified_user_outlined, 'Approvals'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentNavIndex == index;
    return InkWell(
      onTap: () {
        if (index == 0) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        } else if (index == 1) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const OilsCatalogScreen()),
          );
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryOrange : AppColors.textMuted,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primaryOrange : AppColors.textMuted,
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
