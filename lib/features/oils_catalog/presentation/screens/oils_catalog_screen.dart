import 'package:material_ui/material_ui.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:carfix/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:carfix/features/parts_catalog/presentation/screens/parts_catalog_screen.dart';
import '../../data/models/oil_brand_model.dart';
import '../../data/models/oil_formula_model.dart';
import '../../data/services/oils_catalog_service.dart';
import '../widgets/add_brand_dialog.dart';
import '../widgets/add_oil_dialog.dart';
import '../widgets/brand_accordion_card.dart';

class OilsCatalogScreen extends StatefulWidget {
  const OilsCatalogScreen({super.key});

  @override
  State<OilsCatalogScreen> createState() => _OilsCatalogScreenState();
}

class _OilsCatalogScreenState extends State<OilsCatalogScreen> {
  final OilsCatalogService _service = OilsCatalogService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentNavIndex = 1; // 1 = Oils Catalog

  @override
  void initState() {
    super.initState();
    // Automatically seed initial 5 brands & formulas if Firestore is empty
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

  void _showAddBrandDialog() {
    showDialog(
      context: context,
      builder: (_) => AddBrandDialog(service: _service),
    );
  }

  void _showAddOilDialog({OilBrandModel? targetBrand, List<OilBrandModel>? allBrands}) {
    showDialog(
      context: context,
      builder: (_) => AddOilDialog(
        service: _service,
        availableBrands: allBrands ?? (targetBrand != null ? [targetBrand] : []),
        initialBrand: targetBrand,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(),
      body: StreamBuilder<List<OilBrandModel>>(
        stream: _service.getBrandsStream(),
        builder: (context, brandsSnapshot) {
          final brands = brandsSnapshot.data ?? [];

          return StreamBuilder<List<OilFormulaModel>>(
            stream: _service.getAllFormulasStream(),
            builder: (context, formulasSnapshot) {
              final formulas = formulasSnapshot.data ?? [];

              // Filter brands and formulas by search query
              final filteredBrands = brands.where((brand) {
                if (_searchQuery.isEmpty) return true;
                final matchesBrand = brand.name.toLowerCase().contains(_searchQuery);
                final matchesFormula = formulas.any((f) =>
                    f.brandId == brand.id &&
                    (f.viscosity.toLowerCase().contains(_searchQuery) ||
                        f.title.toLowerCase().contains(_searchQuery) ||
                        f.oemSpecs.toLowerCase().contains(_searchQuery)));
                return matchesBrand || matchesFormula;
              }).toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Action Buttons Pair
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              shadowColor: AppColors.primaryOrange.withValues(alpha: 0.4),
                            ),
                            icon: const Icon(Icons.add_business, size: 19),
                            label: const Text(
                              'Add Brand',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                            ),
                            onPressed: _showAddBrandDialog,
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
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.add_circle,
                                color: AppColors.primaryOrange, size: 19),
                            label: const Text(
                              'Add Oil Spec',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                            ),
                            onPressed: () => _showAddOilDialog(allBrands: brands),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Live Telemetry / Oil System Snapshot
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderSlate.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildTelemetryTile(
                              label: 'BRANDS',
                              value: '${brands.isNotEmpty ? brands.length : 5}',
                              isHighlighted: false,
                            ),
                          ),
                          Expanded(
                            child: _buildTelemetryTile(
                              label: 'FORMULAS',
                              value: '${formulas.isNotEmpty ? formulas.length : 24}',
                              isHighlighted: true,
                            ),
                          ),
                          Expanded(
                            child: _buildTelemetryTile(
                              label: 'GARAGES',
                              value: '89',
                              isHighlighted: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Search & Filter Bar
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderSlate.withValues(alpha: 0.5)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: AppColors.onSurface, fontSize: 13.5),
                        decoration: InputDecoration(
                          hintText: 'Search motor oil brands or grades (e.g. 5W-30)...',
                          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                          prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.tune, color: AppColors.textMuted, size: 18),
                            onPressed: () {},
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Section Title
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
                            const SizedBox(width: 8),
                            const Text(
                              'VERIFIED CATALOGS & VISCOSITY MATRIX',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          'Tap brand to view',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Brand Accordions
                    if (brandsSnapshot.connectionState == ConnectionState.waiting && brands.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryOrange,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    else if (filteredBrands.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 36),
                        child: Column(
                          children: [
                            const Icon(Icons.search_off, color: AppColors.textMuted, size: 36),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No brands registered yet. Tap "Add Brand" to start!'
                                  : 'No brands match "$_searchQuery"',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredBrands.length,
                        separatorBuilder: (_, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final brand = filteredBrands[index];
                          return BrandAccordionCard(
                            brand: brand,
                            service: _service,
                            initialExpanded: index == 0, // First brand expanded by default
                            onAddOilPressed: () => _showAddOilDialog(
                              targetBrand: brand,
                              allBrands: brands,
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 32),
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
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primaryOrange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'CAR FIX',
            style: TextStyle(
              color: AppColors.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            '/',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
          const SizedBox(width: 6),
          const Text(
            'ADMIN',
            style: TextStyle(
              color: AppColors.primaryOrange,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
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
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.primaryOrange,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 18),
        ),
      ],
    );
  }

  Widget _buildTelemetryTile({
    required String label,
    required String value,
    required bool isHighlighted,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.surfaceContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isHighlighted ? AppColors.primaryOrange : AppColors.textMuted,
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: isHighlighted ? AppColors.primaryOrange : AppColors.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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
              _buildNavItem(1, Icons.oil_barrel, 'Oils Catalog'),
              _buildNavItem(2, Icons.build_outlined, 'Parts Catalog'),
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
        } else if (index == 2) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const PartsCatalogScreen()),
          );
        } else {
          setState(() => _currentNavIndex = index);
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
