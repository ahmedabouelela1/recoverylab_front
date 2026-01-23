import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/models/Branch/branch/branch.dart';
import 'package:recoverylab_front/models/Branch/services/service_category.dart';
import 'package:recoverylab_front/models/Offer/offers.dart';
import 'package:recoverylab_front/models/Offer/recommended.dart';
import 'package:recoverylab_front/models/User/user.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/exception/snack_bar.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:recoverylab_front/providers/session/branch_provider.dart';
import 'package:recoverylab_front/providers/session/user_session_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:solar_icons/solar_icons.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  List<Branch> branches = [];
  List<Offers?> offers = [];
  List<ServiceCategory?> serviceCategories = [];
  List<Recommended?> recommendedServices = [];
  Branch? selectedBranch;
  late User user;

  final PageController _offersPageController = PageController(
    viewportFraction: 1,
  );
  final PageController _recommendedPageController = PageController(
    viewportFraction: 1,
  );
  int _currentOfferPage = 0;
  int _currentRecommendedPage = 0;
  Timer? _offersTimer;

  // Color theme
  final Color primaryGradientStart = AppColors.primary;
  final Color primaryGradientEnd = Color(0xFF7B61FF);
  final Color tagColor = AppColors.primary;
  final Color tagBgColor = AppColors.primary.withOpacity(0.15);

  @override
  void initState() {
    super.initState();
    _loadHome();
  }

  Future<void> _loadHome() async {
    try {
      final home = await ref.read(apiProvider).gethome();
      final branchProvider = ref.read(branchesProvider);
      final user = ref.read(userSessionProvider).user;

      setState(() {
        branches = branchProvider;
        offers = home['data']['offers'] ?? [];
        serviceCategories = home['data']['categories'] ?? [];
        recommendedServices = home['data']['recommended'] ?? [];

        // Set selected branch based on user's branch_id
        if (user?.branchId != null) {
          selectedBranch = branches.firstWhere(
            (branch) => branch.id == user!.branchId,
            orElse: () => branches.isNotEmpty
                ? branches.first
                : Branch(
                    id: 0,
                    name: 'No Branch',
                    address: '',
                    phone: '',
                    image: '',
                    mapsUrl: '',
                  ),
          );
        } else if (branches.isNotEmpty) {
          selectedBranch = branches.first;
        }
      });

      _startOffersAutoScroll();
    } catch (e, s) {
      print('e: $e, s: $s');
      AppSnackBar.show(context, e.toString());
    }
  }

  void _startOffersAutoScroll() {
    _offersTimer?.cancel();
    if (offers.isEmpty) return;

    _offersTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_offersPageController.hasClients) return;

      if (_currentOfferPage < offers.length - 1) {
        _currentOfferPage++;
      } else {
        _currentOfferPage = 0;
        _offersPageController.jumpToPage(0);
        return;
      }

      _offersPageController.animateToPage(
        _currentOfferPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _offersTimer?.cancel();
    _offersPageController.dispose();
    _recommendedPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    user = ref.watch(userSessionProvider).user!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header Sliver
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
                child: _buildSmoothHeader(),
              ),
            ),

            // Main Content
            SliverList(
              delegate: SliverChildListDelegate([
                _buildBranchSelector(),
                SizedBox(height: 2.h),
                _buildOffersPageView(),
                SizedBox(height: 2.h),
                _buildCategoriesSection(),
                SizedBox(height: 2.h),
                _buildRecommendedPageView(),
                SizedBox(height: 2.h),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  // 👤 Smooth Modern Header
  Widget _buildSmoothHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 0.2.h),
              Text(
                user.firstName + ' ' + user.lastName,
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.1,
                  letterSpacing: -0.3,
                ),
              ),

              // SizedBox(height: 0.8.h),
              // Container(
              //   padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
              //   decoration: BoxDecoration(
              //     color: tagBgColor,
              //     borderRadius: BorderRadius.circular(20),
              //   ),
              //   child: Row(
              //     mainAxisSize: MainAxisSize.min,
              //     children: [
              //       Icon(SolarIconsOutline.crown, size: 14, color: tagColor),
              //       SizedBox(width: 1.5.w),
              //       Text(
              //         'Premium Member',
              //         style: GoogleFonts.inter(
              //           fontSize: 12.sp,
              //           color: AppColors.focusedBorder,
              //           fontWeight: FontWeight.w600,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),

        // Notification Button
        Container(
          width: 24.sp,
          height: 24.sp,
          decoration: BoxDecoration(
            color: AppColors.focusedBorder.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.info.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  SolarIconsBold.bell,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
              ),
              // Positioned(
              //   top: 10,
              //   right: 10,
              //   child: Container(
              //     width: 10,
              //     height: 10,
              //     decoration: BoxDecoration(
              //       color: Colors.red,
              //       shape: BoxShape.circle,
              //       border: Border.all(color: Colors.white, width: 1.5),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ],
    );
  }

  // 🏢 Modern Branch Selector - FIXED
  Widget _buildBranchSelector() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Location",
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.2.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.info.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Branch>(
                value: selectedBranch,
                isExpanded: true,
                dropdownColor: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                icon: Icon(
                  SolarIconsOutline.altArrowDown,
                  color: AppColors.secondary,
                  size: 24,
                ),
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                hint: branches.isEmpty
                    ? Text(
                        'Loading branches...',
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                        ),
                      )
                    : null,
                onChanged: (Branch? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedBranch = newValue;
                    });
                  }
                },
                items: branches.map<DropdownMenuItem<Branch>>((Branch branch) {
                  return DropdownMenuItem<Branch>(
                    value: branch,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.focusedBorder.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            SolarIconsOutline.mapPoint,
                            size: 18,
                            color: AppColors.secondary,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            branch.name,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🌟 Premium Offers PageView - FIXED SPACING
  Widget _buildOffersPageView() {
    if (offers.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Special Offers",
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              Container(
                width: 24.w,
                padding: EdgeInsets.symmetric(
                  horizontal: 3.5.w,
                  vertical: 0.9.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(SolarIconsOutline.fire, size: 15, color: Colors.white),
                    SizedBox(width: 2.w),
                    Text(
                      "Hot Deals",
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 26.h,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollEndNotification) {
                final page = _offersPageController.page?.round() ?? 0;
                setState(() {
                  _currentOfferPage = page;
                });
              }
              return false;
            },
            child: PageView.builder(
              controller: _offersPageController,
              onPageChanged: (index) {
                setState(() {
                  _currentOfferPage = index;
                });
              },
              itemCount: offers.length,
              itemBuilder: (context, index) {
                // Fixed: Use symmetric padding
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 1.5.w),
                  child: _buildPremiumOfferCard(offers[index]!),
                );
              },
            ),
          ),
        ),
        SizedBox(height: 2.5.h),
        // Smooth Page Indicators
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              offers.length,
              (index) => GestureDetector(
                onTap: () {
                  _offersPageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 0.8.w),
                  width: _currentOfferPage == index ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentOfferPage == index
                        ? tagColor
                        : AppColors.textSecondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 🎴 Premium Offer Card
  Widget _buildPremiumOfferCard(Offers offer) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.network(offer.image, fit: BoxFit.cover),
            ),

            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(3.5.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              offer.title,
                              style: GoogleFonts.inter(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.1,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              offer.description,
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      (offer.discount == null || offer.discount!.isEmpty)
                          ? const SizedBox.shrink()
                          : Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 3.w,
                                vertical: 1.2.h,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    primaryGradientStart,
                                    primaryGradientEnd,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryGradientStart.withOpacity(
                                      0.4,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                offer.discount!,
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ],
                  ),

                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.5.w,
                        vertical: 1.2.h,
                      ),
                      width: 30.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Book Now',
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: primaryGradientStart,
                            ),
                          ),
                          SizedBox(width: 1.5.w),
                          Icon(
                            SolarIconsOutline.arrowRight,
                            size: 16,
                            color: primaryGradientStart,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🧭 Categories Section
  Widget _buildCategoriesSection() {
    if (serviceCategories.isEmpty) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Browse Categories",
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, Routes.categories);
                },
                child: Container(
                  width: 25.w,
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.5.w,
                    vertical: 0.9.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "See All",
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 1.5.w),
                      Icon(
                        SolarIconsOutline.arrowRight,
                        size: 14,
                        color: AppColors.secondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          serviceCategories.isEmpty || serviceCategories == null
              ? const SizedBox.shrink()
              : SizedBox(
                  height: 16.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    // padding: EdgeInsets.symmetric(horizontal: .w),
                    itemCount: serviceCategories.length,
                    separatorBuilder: (_, __) => SizedBox(width: 3.w),
                    itemBuilder: (context, index) {
                      final category = serviceCategories[index];
                      if (category == null) return SizedBox.shrink();
                      return _buildModernCategory(category);
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildModernCategory(ServiceCategory category) {
    return GestureDetector(
      onTap: () {
        // Navigator.pushNamed(context, Routes.categories, arguments: category.id);
      },
      child: Container(
        width: 35.w,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.network(
                  category.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.primary.withOpacity(0.1),
                      child: Center(
                        child: Icon(
                          SolarIconsOutline.maskHapply,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Gradient Overlay
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

              // Content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(2.5.h),
                  child: Text(
                    category.name,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 💆 Recommended PageView with Grid
  Widget _buildRecommendedPageView() {
    if (recommendedServices.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recommended for You",
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              Container(
                width: 25.w,
                padding: EdgeInsets.symmetric(
                  horizontal: 3.5.w,
                  vertical: 0.9.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      SolarIconsOutline.starFall,
                      size: 15,
                      color: Colors.white,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      "Top Rated",
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 22.h,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollEndNotification) {
                final page = _recommendedPageController.page?.round() ?? 0;
                setState(() {
                  _currentRecommendedPage = page;
                });
              }
              return false;
            },
            child: PageView.builder(
              controller: _recommendedPageController,
              onPageChanged: (index) {
                setState(() {
                  _currentRecommendedPage = index;
                });
              },
              itemCount: (recommendedServices.length + 1) ~/ 2,
              itemBuilder: (context, pageIndex) {
                final startIndex = pageIndex * 2;
                final endIndex = startIndex + 2;
                final services = recommendedServices.sublist(
                  startIndex,
                  endIndex > recommendedServices.length
                      ? recommendedServices.length
                      : endIndex,
                );

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Row(
                    children: services.map((service) {
                      if (service == null) return SizedBox.shrink();
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                            right: services.indexOf(service) == 0 ? 2.w : 0,
                          ),
                          child: _buildRecommendedCard(service),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: 2.5.h),
        // Page Indicators for Recommended
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              (recommendedServices.length + 1) ~/ 2,
              (index) => GestureDetector(
                onTap: () {
                  _recommendedPageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 0.8.w),
                  width: _currentRecommendedPage == index ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentRecommendedPage == index
                        ? tagColor
                        : AppColors.textSecondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ⭐ Premium Recommended Card
  Widget _buildRecommendedCard(Recommended service) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.serviceDetails,
          arguments: {'service': service.service, 'branch': service.branch},
        );
      },
      child: Container(
        height: 22.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.network(
                  service.service.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.primary.withOpacity(0.1),
                      child: Center(
                        child: Icon(
                          SolarIconsOutline.maskHapply,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(2.5.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        primaryGradientStart.withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.service.name,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.8.h),
                      Row(
                        children: [
                          Icon(
                            SolarIconsOutline.mapPoint,
                            size: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          SizedBox(width: 1.5.w),
                          Expanded(
                            child: Text(
                              service.branch.name,
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
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
