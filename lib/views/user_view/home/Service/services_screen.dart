import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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

class _ServicesPageState extends ConsumerState<ServicesPage> {
  List<Branch> branches = [];
  Branch? selectedBranch;
  User? user;
  List<Service?> services = [];
  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  void _loadPage() async {
    final branchList = ref.read(branchesProvider);
    user = ref.read(userSessionProvider).user;

    final response = await ref
        .read(apiProvider)
        .getServicesByCategory(widget.category.id);

    setState(() {
      branches = branchList;
      services = response;
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
          _buildBranchSelector(),

          // Services list
          Expanded(
            child: services.isNotEmpty
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

  Widget _buildBranchSelector() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),
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

  Widget _buildServiceCard({
    required BuildContext context,
    required Service service,
  }) {
    return GestureDetector(
      onTap: () {
        print('service.image: ${service.image}');
        Navigator.pushNamed(
          context,
          Routes.serviceDetails,
          arguments: {
            'title': "${service.name} Details",
            'location': service.description,
            'branch': selectedBranch,
            'price': "123456",
            'duration': "12345",
            'image': service.image,
          },
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
