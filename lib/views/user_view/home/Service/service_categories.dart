import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recoverylab_front/components/shimmer_box.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/models/Branch/services/service_category.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:sizer/sizer.dart';
import 'package:solar_icons/solar_icons.dart';

class AllCategoriesPage extends ConsumerStatefulWidget {
  /// Pre-loaded categories from home, or null to load from API (shows shimmer).
  final List<ServiceCategory?>? categories;
  const AllCategoriesPage({super.key, this.categories});

  @override
  ConsumerState<AllCategoriesPage> createState() => _AllCategoriesPageState();
}

class _AllCategoriesPageState extends ConsumerState<AllCategoriesPage>
    with TickerProviderStateMixin {
  List<ServiceCategory> _categories = [];
  late List<ServiceCategory> filteredCategories;
  String searchQuery = '';
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  AnimationController? _shimmerController;
  Animation<double>? _shimmerAnim;

  @override
  void initState() {
    super.initState();
    final raw = widget.categories;
    if (raw != null && raw.isNotEmpty) {
      _categories = raw.whereType<ServiceCategory>().toList();
      filteredCategories = List.from(_categories);
    } else {
      filteredCategories = [];
      _isLoading = true;
      _shimmerController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1600),
      )..repeat();
      _shimmerAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _shimmerController!, curve: Curves.easeInOut),
      );
      _loadCategories();
    }
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadCategories() async {
    try {
      final home = await ref.read(apiProvider).gethome();
      if (!mounted) return;
      final categories =
          (home['data']['categories'] as List<dynamic>?)
              ?.map((e) => e as ServiceCategory)
              .toList() ??
          [];
      setState(() {
        _categories = categories;
        filteredCategories = List.from(categories);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _categories = [];
        filteredCategories = [];
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _shimmerController?.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      // You could implement lazy loading here if needed
    }
  }

  void _filterCategories(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredCategories = List.from(_categories);
      } else {
        filteredCategories = _categories
            .where(
              (category) =>
                  category.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: Icon(
            SolarIconsOutline.altArrowLeft,
            color: Colors.white,
            size: 20.sp,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: Text(
          'Browse Categories',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: _isLoading ? _buildShimmerBody() : _buildContent(),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 2.h),
              child: _buildSearchBar(),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            sliver: SliverMainAxisGroup(
              slivers: [
                // Header with count
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'All Categories',
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 0.8.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${filteredCategories.length} ${filteredCategories.length == 1 ? 'Category' : 'Categories'}',
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              color: AppColors.focusedBorder,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Empty state
                if (filteredCategories.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            SolarIconsOutline.magnifier,
                            size: 40.sp,
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'No categories found',
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Try searching for something else',
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              color: AppColors.textSecondary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Categories Grid - Square cards
                if (filteredCategories.isNotEmpty)
                  SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 3.w,
                      mainAxisSpacing: 3.w,
                      childAspectRatio: 1,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final category = filteredCategories[index];
                      return _buildCategoryCard(category: category);
                    }, childCount: filteredCategories.length),
                  ),
              ],
            ),
          ),
        ],
      );
  }

  Widget _buildShimmerBody() {
    final anim = _shimmerAnim;
    if (anim == null) return const SizedBox.shrink();
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 2.h),
            child: ShimmerBox(
              animation: anim,
              child: Container(
                height: 6.h,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          sliver: SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 1.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerBox(
                    animation: anim,
                    child: shimmerSkeletonBar(width: 28.w, height: 2.h),
                  ),
                  ShimmerBox(
                    animation: anim,
                    child: shimmerSkeletonBar(
                        width: 22.w, height: 2.5.h, radius: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 3.w,
              childAspectRatio: 1,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => ShimmerBox(
                animation: anim,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              childCount: 6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 6.h,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 4.w),
          Icon(
            SolarIconsOutline.magnifier,
            color: AppColors.textSecondary,
            size: 20,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _filterCategories,
              decoration: InputDecoration(
                hintText: "Search categories...",
                hintStyle: GoogleFonts.inter(
                  color: AppColors.textSecondary.withOpacity(0.7),
                  fontSize: 13.sp,
                ),
                border: InputBorder.none,
                counterText: '',
              ),
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              maxLength: 50,
            ),
          ),
          if (searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                _filterCategories('');
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: Icon(
                  SolarIconsOutline.closeCircle,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({required ServiceCategory category}) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.categories,
          arguments: {'category': category},
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.network(
                  category.image,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: AppColors.cardBackground,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Gradient overlay from top to bottom
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
              ),

              // Text centered
              Center(
                child: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: Text(
                    category.name,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
