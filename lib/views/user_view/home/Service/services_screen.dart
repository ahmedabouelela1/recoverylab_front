import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recoverylab_front/components/shimmer_box.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/models/Branch/branch/branch.dart';
import 'package:recoverylab_front/models/Branch/services/service.dart';
import 'package:recoverylab_front/models/Branch/services/service_category.dart';
import 'package:recoverylab_front/models/User/user.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:recoverylab_front/providers/session/branch_provider.dart';
import 'package:recoverylab_front/providers/session/user_session_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:solar_icons/solar_icons.dart';

class ServicesPage extends ConsumerStatefulWidget {
  final ServiceCategory category;
  const ServicesPage({super.key, required this.category});

  @override
  ConsumerState<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends ConsumerState<ServicesPage>
    with TickerProviderStateMixin {
  List<Branch> branches = [];
  Branch? selectedBranch;
  User? user;
  List<Service?> services = [];
  bool _isLoading = true;
  AnimationController? _shimmerController;
  Animation<double>? _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shimmerController!, curve: Curves.easeInOut),
    );
    _loadPage();
  }

  @override
  void dispose() {
    _shimmerController?.dispose();
    super.dispose();
  }

  void _loadPage() async {
    final branchList = ref.read(branchesProvider);
    user = ref.read(userSessionProvider).user;

    try {
      final response = await ref
          .read(apiProvider)
          .getServicesByCategory(widget.category.id);

      if (!mounted) return;
      setState(() {
        branches = branchList;
        services = response;
        _isLoading = false;
        if (user?.branchId != null && branches.isNotEmpty) {
          try {
            selectedBranch = branches.firstWhere(
              (branch) => branch.id.toString() == user!.branchId,
            );
          } catch (e) {
            selectedBranch = branches.first;
          }
        } else if (branches.isNotEmpty) {
          selectedBranch = branches.first;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        services = [];
        _isLoading = false;
      });
    }
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
            color: AppColors.textPrimary, // Changed to textPrimary
            size: 20.sp,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: Text(
          widget.category.name,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: Column(
        children: [
          // _buildBranchSelector(),
          _searchBar(),

          // Services list
          Expanded(
            child: _isLoading
                ? _buildShimmerBody()
                : services.isNotEmpty
                    ? ListView.builder(
                    padding: EdgeInsets.all(4.w),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 2.h),
                        child: _buildServiceCard(
                          context: context,
                          service: service!,
                        ),
                      );
                    },
                  )
                    : Center(
                        child: Text(
                          'No services available in this category.',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBody() {
    final anim = _shimmerAnim;
    if (anim == null) return const SizedBox.shrink();
    return ListView(
      padding: EdgeInsets.all(4.w),
      children: List.generate(
        5,
        (_) => Padding(
          padding: EdgeInsets.only(bottom: 2.h),
          child: ShimmerBox(
            animation: anim,
            child: Container(
              height: 22.h,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ShimmerBox(
                    animation: anim,
                    child: shimmerSkeletonBar(width: 60.w, height: 2.2.h),
                  ),
                  SizedBox(height: 1.h),
                  ShimmerBox(
                    animation: anim,
                    child: shimmerSkeletonBar(width: 80.w, height: 1.8.h),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search services...',
          hintStyle: GoogleFonts.inter(fontSize: 13.sp, color: Colors.white),
          prefixIcon: Icon(
            SolarIconsOutline.magnifier,
            color: Colors.white,
            size: 20.sp,
          ),
          filled: true,
          fillColor: AppColors.cardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
        cursorColor: Colors.white,
        onChanged: (value) {},
      ),
    );
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required Service service,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.serviceDetails,
          arguments: {'service': service},
        );
      },
      child: Container(
        height: 22.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(service.image),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.7), Colors.transparent],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                service.name,
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 0.5.h),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 15, color: Colors.white),
                  SizedBox(width: 1.w),
                  Text(
                    service.description,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  "view details",
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
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
