import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/models/Branch/branch/branch.dart';
import 'package:recoverylab_front/models/Branch/branch/branch_schedule.dart';
import 'package:recoverylab_front/models/Branch/services/service.dart';
import 'package:recoverylab_front/models/Branch/branchService/service_durations.dart';
import 'package:recoverylab_front/models/Branch/staff/staff.dart';
import 'package:recoverylab_front/models/Offer/user_package.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/exception/exception_handling.dart';
import 'package:recoverylab_front/providers/exception/snack_bar.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:recoverylab_front/providers/session/branch_provider.dart';
import 'package:recoverylab_front/providers/session/user_session_provider.dart';
import 'package:recoverylab_front/providers/session/active_membership_provider.dart';
import 'package:recoverylab_front/models/Offer/user_membership.dart';
import 'package:sizer/sizer.dart';
import 'package:solar_icons/solar_icons.dart';

class ServiceDetailsPage extends ConsumerStatefulWidget {
  final Service service;

  const ServiceDetailsPage({required this.service, super.key});

  @override
  ConsumerState<ServiceDetailsPage> createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends ConsumerState<ServiceDetailsPage> {
  // Booking state
  int? selectedDuration;
  int? selectedPeopleCount = 1;
  bool showFullDescription = false;
  int? selectedBranchIndex = 0;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String notes = '';
  Staff? selectedStaff;
  String selectedType = 'single';
  String? selectedPaymentMethod;
  String? _actualBookingId;
  List<Branch?> branches = [];
  List<ServiceDuration?> durations = [];
  List<Staff?> staffList = [];
  int defaultCapacity = 2;
  List<UserPackage> _myPackages = [];
  UserPackage? _selectedPackage;
  BranchSchedule? _schedule;

  // Loading and error states
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() async {
    try {
      setState(() => isLoading = true);

      final user = ref.read(userSessionProvider).user;
      branches = ref.read(branchesProvider);
      final idx = branches.indexWhere((b) => b?.id == user?.branchId);
      selectedBranchIndex = idx >= 0 ? idx : 0;

      await Future.wait([_fetchServiceDetails(), _loadSchedule()]);
      _loadMyPackages();
      setState(() => isLoading = false);
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Failed to load service details';
      });
    }
  }

  Future<void> _fetchServiceDetails() async {
    try {
      final branchId = branches[selectedBranchIndex!]!.id;

      final response = await ref
          .read(apiProvider)
          .getBranchService(branchId: branchId, serviceId: widget.service.id);

      if (response == null || !response.success) {
        setState(() {
          hasError = true;
          errorMessage =
              response?.message ?? 'Service not available at this branch';
        });
        return;
      }

      if (response.data.isEmpty) {
        setState(() {
          hasError = true;
          errorMessage = 'Service not available at this branch';
        });
        return;
      }

      final branchService = response.data[0];

      // Check if service is offered
      if (!branchService.isOffered) {
        setState(() {
          hasError = true;
          errorMessage = 'This service is currently not offered at this branch';
        });
        return;
      }

      // Set durations from API
      durations = branchService.branchPricing;

      // Set staff from API
      staffList = response.staff;

      // Set default capacity
      defaultCapacity = branchService.defaultCapacity;

      // Set default duration if not already set
      if (durations.isNotEmpty && selectedDuration == null) {
        selectedDuration = durations[0]?.minutes;
      }

      setState(() {
        hasError = false;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Failed to fetch service details';
      });
    }
  }

  Future<void> _loadMyPackages() async {
    try {
      final packages = await ref.read(apiProvider).getMyPackages();
      if (mounted) setState(() => _myPackages = packages);
    } catch (_) {
      // Non-critical — user may not have packages
    }
  }

  Future<void> _loadSchedule() async {
    if (branches.isEmpty) return;
    try {
      final branchId = branches[selectedBranchIndex ?? 0]!.id;
      final schedule = await ref.read(apiProvider).getBranchSchedule(branchId);
      if (mounted) setState(() => _schedule = schedule);
    } catch (_) {
      // Non-critical — fall back to hardcoded hours
    }
  }

  Future<void> _onBranchChanged(int newBranchIndex) async {
    setState(() {
      selectedBranchIndex = newBranchIndex;
      isLoading = true;
      // Reset selections
      selectedDuration = null;
      selectedStaff = null;
    });

    await Future.wait([_fetchServiceDetails(), _loadSchedule()]);
    setState(() => isLoading = false);
  }

  // Format date and time for Laravel
  String? _formatDateTimeForApi() {
    if (selectedDate == null || selectedTime == null) return null;

    final dateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    return dateTime.toIso8601String().replaceFirst('T', ' ').substring(0, 19);
  }

  // Validate booking
  bool _validateBooking() {
    if (selectedDate == null || selectedTime == null) {
      AppSnackBar.show(context, 'Please select date and time');
      return false;
    }

    final selectedDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );
    if (selectedDateTime.isBefore(DateTime.now())) {
      AppSnackBar.show(context, 'Please select a future date and time');
      return false;
    }

    if (selectedDuration == null) {
      AppSnackBar.show(context, 'Please select duration');
      return false;
    }

    if (selectedType == 'group' && selectedPeopleCount == null) {
      AppSnackBar.show(context, 'Please select number of people for group booking');
      return false;
    }

    return true;
  }

  // Show booking confirmation modal; on confirm, call API directly (no payment method modal).
  void _showBookingConfirmation() {
    if (!_validateBooking()) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _buildBookingConfirmationModal(),
    );
  }
  void _processPayment() async {
    final formattedDateTime = _formatDateTimeForApi();
    final user = ref.read(userSessionProvider).user;

    if (user == null) {
      AppSnackBar.show(context, 'User not logged in');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildPaymentProcessingDialog(),
    );

    try {
      final response = await ref
          .read(apiProvider)
          .storeBooking(
            userId: user.id,
            branchId: branches[selectedBranchIndex!]!.id,
            serviceId: widget.service.id,
            formattedDateTime: formattedDateTime!,
            durationMinutes: selectedDuration!,
            participantCount: selectedPeopleCount!,
            staffId: selectedStaff?.user.id,
            notes: notes.isEmpty ? null : notes,
            paymentMethod: selectedPaymentMethod ?? 'CASH',
            usePackageId: _selectedPackage?.id,
          );

      // Backend returns { success, message, data: { booking, booking_id, ... } }
      final data = response['data'] as Map<String, dynamic>?;
      final bookingId = data?['booking_id'];
      final bookingObj = data?['booking'];
      _actualBookingId = (bookingId ?? bookingObj?['id'])?.toString();

      if (!mounted) return;

      Navigator.pop(context); // Close loading dialog
      _showPaymentSuccessModal();
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context); // Close loading dialog
      final message = e is ApiException
          ? e.message
          : e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      AppSnackBar.show(context, 'Booking failed: $message');
    }
  }

  Widget _buildBookingConfirmationModal() {
    final selectedDurationData = durations.firstWhere(
      (d) => d?.minutes == selectedDuration,
      orElse: () => durations[0],
    );

    return Container(
      padding: EdgeInsets.only(
        left: 4.w,
        right: 4.w,
        top: 4.w,
        bottom: MediaQuery.of(context).viewInsets.bottom + 4.w,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppColors.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 3.h),

          Text(
            'Booking Summary',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),

          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.dividerColor),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        SolarIconsOutline.windowFrame,
                        color: AppColors.info,
                        size: 16.sp,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        widget.service.name,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),

                Container(height: 0.5, color: AppColors.dividerColor),
                SizedBox(height: 2.h),

                Column(
                  children: [
                    _buildConfirmationDetail(
                      icon: SolarIconsOutline.calendar,
                      label: 'Date',
                      value:
                          '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                    ),
                    SizedBox(height: 1.5.h),
                    _buildConfirmationDetail(
                      icon: SolarIconsOutline.clockCircle,
                      label: 'Time',
                      value: _formatHour(selectedTime!.hour),
                    ),
                    SizedBox(height: 1.5.h),
                    _buildConfirmationDetail(
                      icon: Icons.schedule,
                      label: 'Duration',
                      value: '${selectedDuration} minutes',
                    ),
                    SizedBox(height: 1.5.h),
                    _buildConfirmationDetail(
                      icon: Icons.people,
                      label: 'People',
                      value:
                          '${selectedPeopleCount} ${selectedPeopleCount == 1 ? 'person' : 'people'}',
                    ),
                    SizedBox(height: 1.5.h),
                    if (selectedStaff != null)
                      _buildConfirmationDetail(
                        icon: Icons.person,
                        label: 'Staff Member',
                        value:
                            '${selectedStaff!.user.firstName} ${selectedStaff!.user.lastName}',
                      ),
                    if (selectedStaff != null) SizedBox(height: 1.5.h),
                    _buildConfirmationDetail(
                      icon: Icons.location_on,
                      label: 'Branch',
                      value: branches[selectedBranchIndex!]!.name,
                    ),
                    if (notes.isNotEmpty) SizedBox(height: 1.5.h),
                    if (notes.isNotEmpty)
                      _buildConfirmationDetail(
                        icon: Icons.note,
                        label: 'Notes',
                        value: notes.length > 30
                            ? '${notes.substring(0, 30)}...'
                            : notes,
                      ),
                  ],
                ),
                SizedBox(height: 2.h),

                // Package credit selector
                if (_myPackages.isNotEmpty) ...[
                  Container(height: 0.5, color: AppColors.dividerColor),
                  SizedBox(height: 2.h),
                  Text(
                    'Apply Package Credit',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  // None option
                  StatefulBuilder(
                    builder: (ctx, setInner) => Column(
                      children: [
                        GestureDetector(
                          onTap: () => setInner(() => _selectedPackage = null),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 3.w,
                              vertical: 1.2.h,
                            ),
                            margin: EdgeInsets.only(bottom: 1.h),
                            decoration: BoxDecoration(
                              color: _selectedPackage == null
                                  ? AppColors.primary.withOpacity(0.12)
                                  : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedPackage == null
                                    ? AppColors.primary
                                    : AppColors.dividerColor,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.close,
                                  size: 14.sp,
                                  color: _selectedPackage == null
                                      ? AppColors.primary
                                      : AppColors.textTertiary,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'No package credit',
                                  style: TextStyle(
                                    color: _selectedPackage == null
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ..._myPackages.map((pkg) {
                          final isSelected = _selectedPackage?.id == pkg.id;
                          return GestureDetector(
                            onTap: () => setInner(() => _selectedPackage = pkg),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 3.w,
                                vertical: 1.2.h,
                              ),
                              margin: EdgeInsets.only(bottom: 1.h),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.12)
                                    : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.dividerColor,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.card_giftcard,
                                    size: 14.sp,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textTertiary,
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Text(
                                      '${pkg.package?.name ?? 'Package'} · ${pkg.creditsRemaining} credit${pkg.creditsRemaining == 1 ? '' : 's'} left',
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  SizedBox(height: 1.h),
                ],

                Container(height: 0.5, color: AppColors.dividerColor),
                SizedBox(height: 2.h),

                Builder(
                  builder: (_) {
                    final totalInfo = _getDisplayTotalWithMembership(
                      selectedDurationData?.price,
                      selectedPeopleCount ?? 1,
                    );
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Amount',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14.sp,
                              ),
                            ),
                            if (totalInfo.$3 != null)
                              Padding(
                                padding: EdgeInsets.only(top: 0.3.h),
                                child: Text(
                                  totalInfo.$3!,
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (totalInfo.$2 != null)
                              Text(
                                totalInfo.$2!,
                                style: TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 12.sp,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            Text(
                              totalInfo.$1,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceLight,
                    foregroundColor: AppColors.textPrimary,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: AppColors.dividerColor),
                    ),
                  ),
                  child: Text(
                    'Edit Booking',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close confirmation sheet
                    _processPayment();       // Call API directly (default payment)
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.secondary,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: AppColors.primary.withOpacity(0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Confirm & Book',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Icon(Icons.arrow_forward, size: 16.sp),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildConfirmationDetail({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textTertiary, size: 16.sp),
        SizedBox(width: 4.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentProcessingDialog() {
    return Dialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 3.h),
            Text(
              'Processing Payment',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Please wait while we process your payment...',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentSuccessModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _buildPaymentSuccessModal(),
    );
  }

  Widget _buildPaymentSuccessModal() {
    return Container(
      padding: EdgeInsets.only(
        left: 4.w,
        right: 4.w,
        top: 4.w,
        bottom: MediaQuery.of(context).viewInsets.bottom + 4.w,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppColors.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 3.h),

          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: AppColors.success, size: 30.sp),
          ),
          SizedBox(height: 3.h),

          Text(
            'Payment Successful!',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 1.h),

          Text(
            'Your booking has been confirmed and payment has been processed successfully.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.sp,
              height: 1.5,
            ),
          ),
          SizedBox(height: 3.h),

          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.confirmation_number,
                  color: AppColors.info,
                  size: 16.sp,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking ID',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 11.sp,
                        ),
                      ),
                      Text(
                        _actualBookingId != null ? '#BK$_actualBookingId' : '—',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // TODO: Copy to clipboard
                  },
                  icon: Icon(Icons.copy, color: AppColors.info, size: 18.sp),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),

          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: AppColors.info, size: 16.sp),
                    SizedBox(width: 2.w),
                    Text(
                      'What\'s Next?',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  '• You will receive a confirmation email\n'
                  '• Arrive 15 minutes before your appointment\n'
                  '• Bring your ID for verification\n'
                  '• Cancel at least 24 hours in advance for full refund',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceLight,
                    foregroundColor: AppColors.textPrimary,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: AppColors.dividerColor),
                    ),
                  ),
                  child: Text(
                    'Book Another',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      Routes.navbar,
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.secondary,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'View Bookings',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          if (isLoading)
            _buildLoadingState()
          else if (hasError)
            _buildErrorState()
          else
            _buildContent(),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 2.h),
          Text(
            'Loading service details...',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final bool isBranchMismatch =
        errorMessage != null &&
        (errorMessage!.toLowerCase().contains('branch') ||
            errorMessage!.toLowerCase().contains('offered') ||
            errorMessage!.toLowerCase().contains('available'));

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeaderImage(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2.h),

                // Service name header
                Text(
                  widget.service.name,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 2.h),

                _buildBranchSelector(),
                SizedBox(height: 3.h),

                // Main error card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(5.w),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.dividerColor),
                  ),
                  child: Column(
                    children: [
                      // Icon container
                      Container(
                        width: 18.w,
                        height: 18.w,
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.info.withOpacity(0.25),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          SolarIconsOutline.mapPoint,
                          size: 28.sp,
                          color: AppColors.info,
                        ),
                      ),
                      SizedBox(height: 2.5.h),

                      Text(
                        'NOT AVAILABLE HERE',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 1.h),

                      Text(
                        isBranchMismatch
                            ? 'This service isn\'t offered\nat this branch'
                            : 'Unable to Load Service',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 1.5.h),

                      Text(
                        isBranchMismatch
                            ? 'Try switching to a different branch — the service\nmay be available at another location near you.'
                            : (errorMessage ??
                                  'Something went wrong. Please try again.'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),

                // Info tip row
                if (isBranchMismatch) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.info.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          SolarIconsOutline.infoCircle,
                          color: AppColors.info,
                          size: 18.sp,
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            'Use the branch selector above to check availability at other locations.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12.sp,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                ],

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.dividerColor),
                          ),
                          child: Center(
                            child: Text(
                              'Go Back',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: _showBranchSelectionModal,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                SolarIconsOutline.mapPoint,
                                color: AppColors.secondary,
                                size: 16.sp,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Switch Branch',
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeaderImage(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2.h),
                _buildServiceHeader(),
                SizedBox(height: 2.h),
                _buildBranchSelector(),
                SizedBox(height: 2.h),
                _buildAboutService(),
                SizedBox(height: 2.h),
                _buildIncludedServices(),
                SizedBox(height: 2.h),
                _buildPeopleSelector(),
                SizedBox(height: 2.h),
                _buildDateSelector(),
                SizedBox(height: 2.h),
                _buildTimeSelector(),
                SizedBox(height: 2.h),
                _buildDurationSelector(),
                if (staffList.isNotEmpty) _buildStaffSelector(),
                _buildNotesField(),
                SizedBox(height: 14.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage() {
    return Container(
      height: 30.h,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(widget.service.image),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.background.withOpacity(0.3),
                  AppColors.background.withOpacity(0.9),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8.h,
            left: 8.w,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.textPrimary,
                size: 18.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.service.name,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.people, color: AppColors.info, size: 14.sp),
                  SizedBox(width: 1.w),
                  Text(
                    'UP TO $defaultCapacity\nPEOPLE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.info,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBranchSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECTED BRANCH',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 1.h),
        GestureDetector(
          onTap: _showBranchSelectionModal,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.info),
            ),
            child: Row(
              children: [
                Icon(
                  SolarIconsBold.pointOnMap,
                  color: AppColors.strokeBorder,
                  size: 20.sp,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        branches[selectedBranchIndex ?? 0]!.name,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        branches[selectedBranchIndex ?? 0]!.address,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.expand_more,
                  color: AppColors.strokeBorder,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeopleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NUMBER OF PEOPLE',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 1.h),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How many people?',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.5.h),

              /// Single / Double / Group
              Row(
                children: [
                  Expanded(
                    child: _buildTypeCard(
                      label: 'Single',
                      isSelected: selectedType == 'single',
                      onTap: () {
                        setState(() {
                          selectedType = 'single';
                          selectedPeopleCount = 1;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: _buildTypeCard(
                      label: 'Double',
                      isSelected: selectedType == 'double',
                      onTap: () {
                        setState(() {
                          selectedType = 'double';
                          selectedPeopleCount = 2;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: _buildTypeCard(
                      label: 'Group',
                      isSelected: selectedType == 'group',
                      onTap: () {
                        setState(() {
                          selectedType = 'group';
                          selectedPeopleCount = null;
                        });
                      },
                    ),
                  ),
                ],
              ),

              /// Group numbers (3 → 8)
              if (selectedType == 'group') ...[
                SizedBox(height: 2.h),
                Center(
                  child: Wrap(
                    spacing: 1.5.w,
                    runSpacing: 2.h,
                    children: List.generate(6, (index) {
                      final count = index + 3;

                      return GestureDetector(
                        onTap: () {
                          setState(() => selectedPeopleCount = count);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.w,
                            vertical: 1.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: selectedPeopleCount == count
                                ? AppColors.info.withOpacity(0.2)
                                : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedPeopleCount == count
                                  ? AppColors.info
                                  : AppColors.dividerColor,
                            ),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              color: selectedPeopleCount == count
                                  ? AppColors.info
                                  : AppColors.textPrimary,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeCard({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.info.withOpacity(0.2)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.info : AppColors.dividerColor,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.info : AppColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    // Determine if the selected date is a closed day
    final bool selectedDayClosed =
        selectedDate != null &&
        _schedule != null &&
        _schedule!.slotsFor(selectedDate!) == null;
    final String? closedReason = selectedDate != null
        ? _schedule?.specialDateFor(selectedDate!)?.reason
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT DATE',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 1.h),
        GestureDetector(
          onTap: () async {
            final now = DateTime.now();
            final firstDate = now;
            final lastDate = now.add(const Duration(days: 90));

            final pickedDate = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? now,
              firstDate: firstDate,
              lastDate: lastDate,
              builder: (context, child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme: ColorScheme.light(
                      primary: AppColors.primary,
                      onPrimary: AppColors.secondary,
                    ),
                    dialogBackgroundColor: AppColors.background,
                  ),
                  child: child!,
                );
              },
            );

            if (pickedDate != null) {
              final slots = _schedule?.slotsFor(pickedDate);
              final special = _schedule?.specialDateFor(pickedDate);
              if (_schedule != null && slots == null) {
                // Day is fully closed
                final reason =
                    special?.reason ?? 'Branch is closed on this day';
                AppSnackBar.show(context, reason);
              } else if (special != null && !special.isClosed) {
                // Custom hours — inform the user
                final open = special.openTime?.substring(0, 5) ?? '';
                final close = special.closeTime?.substring(0, 5) ?? '';
                final note = special.reason != null
                    ? ' · ${special.reason}'
                    : '';
                AppSnackBar.show(context, 'Special hours on this day: $open – $close$note');
              }
              setState(() {
                selectedDate = pickedDate;
                selectedTime = null; // reset time when date changes
              });
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  SolarIconsBold.calendar,
                  color: AppColors.strokeBorder,
                  size: 20.sp,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    selectedDate == null
                        ? 'Choose a date'
                        : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                    style: TextStyle(
                      color: selectedDate == null
                          ? AppColors.textTertiary
                          : AppColors.textPrimary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.expand_more,
                  color: AppColors.strokeBorder,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),

        // Closed-day warning banner
        if (selectedDayClosed) ...[
          SizedBox(height: 1.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.error, size: 15.sp),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    closedReason ?? 'Branch is closed on this day',
                    style: TextStyle(color: AppColors.error, fontSize: 12.sp),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _formatHour(int hour) {
    final period = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:00 $period';
  }

  /// Format price for display: always EGP, smaller size.
  String _formatPrice(dynamic price) {
    if (price == null) return '0 EGP';
    final p = price is String ? price : price.toString();
    return '$p EGP';
  }

  /// Best membership discount % (0–100) for a service. Matches backend logic: ALL, SERVICE, CATEGORY.
  num _bestMembershipDiscountForService(UserMembership? membership, int serviceId, int categoryId) {
    if (membership == null || membership.plan == null) return 0;
    num best = 0;
    for (final b in membership.plan!.benefits) {
      final applies = b.targetType == 'ALL' ||
          (b.targetType == 'SERVICE' && b.targetId == serviceId) ||
          (b.targetType == 'CATEGORY' && b.targetId == categoryId);
      if (!applies) continue;
      if (b.benefitType == 'UNLIMITED_ACCESS') return 100;
      if (b.benefitType == 'DISCOUNT' && b.value != null && b.value! > best) best = b.value!;
    }
    return best;
  }

  /// Membership-aware total for display. Returns (displayString, originalTotalForStrikethrough or null).
  (String display, String? original, String? membershipLabel) _getDisplayTotalWithMembership(
    String? priceStr,
    int participantCount,
  ) {
    final baseTotal = (double.tryParse(priceStr ?? '0') ?? 0) * participantCount;
    final membership = ref.watch(activeMembershipProvider).value;
    final discountPct = _bestMembershipDiscountForService(
      membership,
      widget.service.id,
      widget.service.category.id,
    );
    if (discountPct >= 100) {
      return ('Free', baseTotal > 0 ? 'EGP ${baseTotal.toStringAsFixed(0)}' : null, 'Included in your membership');
    }
    if (discountPct > 0) {
      final discounted = baseTotal * (1 - discountPct / 100);
      return ('EGP ${discounted.toStringAsFixed(0)}', 'EGP ${baseTotal.toStringAsFixed(0)}', null);
    }
    return ('EGP ${baseTotal.toStringAsFixed(0)}', null, null);
  }

  void _showTimeSelectionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final now = DateTime.now();
        final isToday =
            selectedDate != null &&
            selectedDate!.year == now.year &&
            selectedDate!.month == now.month &&
            selectedDate!.day == now.day;

        // Get slots from branch schedule, fall back to 7 AM–10 PM.
        final scheduleSlots = selectedDate != null
            ? _schedule?.slotsFor(selectedDate!)
            : null;
        final baseSlots = scheduleSlots ?? List.generate(16, (i) => i + 7);
        final closeHour = (scheduleSlots != null && scheduleSlots.isNotEmpty)
            ? (scheduleSlots.last! + 1)
            : 23;

        // For today, skip hours already past.
        var availableHours = baseSlots.where((hour) {
          if (isToday && hour <= now.hour) return false;
          return true;
        }).toList();

        // Only show slots where appointment end is within branch hours.
        if (selectedDuration != null && selectedDuration! > 0) {
          final durationHours = (selectedDuration! / 60).ceil();
          availableHours = availableHours
              .where((hour) => hour + durationHours <= closeHour)
              .toList();
        }

        // Check if branch is explicitly closed on this day.
        final isBranchClosed =
            selectedDate != null && _schedule != null && scheduleSlots == null;
        final closedLabel = selectedDate != null
            ? (_schedule?.specialDateFor(selectedDate!)?.reason ??
                  'Branch is closed on this day')
            : 'Branch is closed on this day';

        return Padding(
          padding: EdgeInsets.only(
            left: 4.w,
            right: 4.w,
            top: 3.w,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 4.w,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 12.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: AppColors.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'SELECT TIME',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'Appointments start on the hour',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 11.sp,
                ),
              ),
              SizedBox(height: 2.h),
              if (isBranchClosed)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 3.h),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_busy,
                          color: AppColors.error,
                          size: 28.sp,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          closedLabel,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 13.sp,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Please select a different date.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (availableHours.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 3.h),
                  child: Center(
                    child: Text(
                      'No available slots for today.\nPlease select a future date.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13.sp,
                        height: 1.5,
                      ),
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: 2.w,
                  runSpacing: 1.5.h,
                  children: availableHours.map((hour) {
                    final isSelected = selectedTime?.hour == hour;
                    return GestureDetector(
                      onTap: () {
                        setState(
                          () => selectedTime = TimeOfDay(hour: hour, minute: 0),
                        );
                        Navigator.pop(sheetContext);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.info.withOpacity(0.15)
                              : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.info
                                : AppColors.dividerColor,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          _formatHour(hour),
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.info
                                : AppColors.textPrimary,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              SizedBox(height: 3.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeSelector() {
    final bool dayClosed =
        selectedDate != null &&
        _schedule != null &&
        _schedule!.slotsFor(selectedDate!) == null;
    final bool noDateSelected = selectedDate == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT TIME',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 1.h),
        GestureDetector(
          onTap: () {
            if (noDateSelected) {
              AppSnackBar.show(context, 'Please select a date first');
              return;
            }
            if (dayClosed) {
              final reason =
                  _schedule!.specialDateFor(selectedDate!)?.reason ??
                  'Branch is closed on this day';
              AppSnackBar.show(context, reason);
              return;
            }
            _showTimeSelectionSheet();
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: dayClosed
                  ? AppColors.error.withOpacity(0.06)
                  : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: dayClosed
                  ? Border.all(color: AppColors.error.withOpacity(0.3))
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  SolarIconsOutline.clockCircle,
                  color: dayClosed
                      ? AppColors.error
                      : noDateSelected
                      ? AppColors.textTertiary
                      : AppColors.strokeBorder,
                  size: 20.sp,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayClosed
                            ? 'Branch closed this day'
                            : noDateSelected
                            ? 'Select a date first'
                            : selectedTime == null
                            ? 'Choose a time'
                            : _formatHour(selectedTime!.hour),
                        style: TextStyle(
                          color: dayClosed
                              ? AppColors.error
                              : noDateSelected
                              ? AppColors.textTertiary
                              : selectedTime == null
                              ? AppColors.textTertiary
                              : AppColors.textPrimary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (!dayClosed &&
                          !noDateSelected &&
                          _schedule != null) ...[
                        SizedBox(height: 0.3.h),
                        Builder(
                          builder: (context) {
                            final slots = _schedule!.slotsFor(selectedDate!);
                            if (slots == null || slots.isEmpty)
                              return const SizedBox.shrink();
                            return Text(
                              'Available: ${_formatHour(slots.first)} – ${_formatHour(slots.last + 1)}',
                              style: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 11.sp,
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  dayClosed ? Icons.block : Icons.expand_more,
                  color: dayClosed ? AppColors.error : AppColors.strokeBorder,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSelector() {
    if (durations.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.schedule, color: AppColors.info, size: 18.sp),
            SizedBox(width: 2.w),
            Text(
              'Select Duration',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Column(
          children: durations.where((d) => d != null).map((duration) {
            final isSelected = selectedDuration == duration!.minutes;
            return GestureDetector(
              onTap: () => setState(() => selectedDuration = duration.minutes),
              child: Container(
                margin: EdgeInsets.only(bottom: 2.h),
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.info : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.info
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${duration.minutes}',
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${duration.minutes} Minutes',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                          ),
                          if (duration.description != null) ...[
                            SizedBox(height: 0.5.h),
                            Text(
                              duration.description!,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _formatPrice(duration.price),
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.info
                              : AppColors.textTertiary,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 3.w,
                                height: 3.w,
                                decoration: const BoxDecoration(
                                  color: AppColors.info,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStaffSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT STAFF MEMBER (OPTIONAL)',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 1.5.h),

        SizedBox(
          height: 16.h,
          child: ListView.separated(
            padding: EdgeInsets.only(bottom: 2.h),
            scrollDirection: Axis.horizontal,
            itemCount: staffList.length,
            separatorBuilder: (_, __) => SizedBox(width: 4.w),
            itemBuilder: (context, index) {
              final staff = staffList[index];
              if (staff == null) return const SizedBox.shrink();

              final isSelected = selectedStaff?.user.id == staff.user.id;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedStaff = isSelected ? null : staff;
                  });
                },
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(isSelected ? 0.8.w : 0.5.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.info
                              : AppColors.dividerColor,
                          width: isSelected ? 3 : 1.5,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 8.w,
                        backgroundImage: (staff.profilePicture.isNotEmpty
                            ? NetworkImage(staff.profilePicture)
                            : null),
                        backgroundColor: AppColors.surfaceLight,
                        child: staff.profilePicture.isEmpty
                            ? Icon(Icons.person, color: AppColors.textTertiary, size: 20.sp)
                            : null,
                      ),
                    ),

                    SizedBox(height: 1.h),
                    Text(
                      '${staff.user.firstName} ${(staff.user.lastName).isNotEmpty ? staff.user.lastName.substring(0, 1) : ''}.',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 0.5.h),

                    Text(
                      staff.employeeId.isNotEmpty ? staff.employeeId : '—',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 10.sp,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NOTES / SPECIAL REQUESTS',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            onChanged: (value) => notes = value,
            maxLines: 4,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 13.sp),
            decoration: InputDecoration(
              hintText: 'Any special requests or notes for your session...',
              hintStyle: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 13.sp,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(4.w),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutService() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About this service',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          widget.service.description,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13.sp,
            height: 1.6,
          ),
          maxLines: showFullDescription ? null : 3,
          overflow: showFullDescription
              ? TextOverflow.visible
              : TextOverflow.ellipsis,
        ),
        GestureDetector(
          onTap: () =>
              setState(() => showFullDescription = !showFullDescription),
          child: Padding(
            padding: EdgeInsets.only(top: 1.h),
            child: Row(
              children: [
                Text(
                  showFullDescription ? 'Read less' : 'Read more',
                  style: TextStyle(
                    color: AppColors.info,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 1.w),
                Icon(
                  showFullDescription
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.info,
                  size: 16.sp,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    if (hasError || durations.isEmpty) return const SizedBox.shrink();

    final selectedDurationData = durations.firstWhere(
      (d) => d?.minutes == selectedDuration,
      orElse: () => durations[0],
    );
    final totalInfo = _getDisplayTotalWithMembership(
      selectedDurationData?.price,
      selectedPeopleCount ?? 1,
    );

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border.all(color: AppColors.dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL PRICE',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    if (totalInfo.$2 != null)
                      Text(
                        totalInfo.$2!,
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 11.sp,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    Text(
                      totalInfo.$1,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (totalInfo.$3 != null)
                      Padding(
                        padding: EdgeInsets.only(top: 0.3.h),
                        child: Text(
                          totalInfo.$3!,
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _showBookingConfirmation,
                    child: Container(
                      margin: EdgeInsets.only(left: 4.w),
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Book Now',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Icon(
                            Icons.arrow_forward,
                            color: AppColors.secondary,
                            size: 16.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Container(
              width: 30.w,
              height: 0.3.h,
              decoration: BoxDecoration(
                color: AppColors.dividerColor,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBranchSelectionModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 12.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: AppColors.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Select Branch',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2.h),
              ...List.generate(branches.length, (index) {
                final branch = branches[index];
                return GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    if (index != selectedBranchIndex) {
                      await _onBranchChanged(index);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.dividerColor,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: index == selectedBranchIndex
                              ? AppColors.info
                              : AppColors.textSecondary,
                          size: 18.sp,
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                branch!.name,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14.sp,
                                  fontWeight: index == selectedBranchIndex
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                branch.address,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (index == selectedBranchIndex)
                          Icon(Icons.check, color: AppColors.info, size: 20.sp),
                      ],
                    ),
                  ),
                );
              }),
              SizedBox(height: 4.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIncludedServices() {
    final List<String?> services = [...widget.service.includedIn];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Included in Service',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),

        GridView.count(
          padding: EdgeInsets.only(top: 2.h),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 3,
          crossAxisSpacing: 3.w,
          mainAxisSpacing: 2.h,
          children: services.map((service) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    SolarIconsOutline.startShine,
                    color: AppColors.info,
                    size: 18.sp,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      service ?? 'Additional Service',
                      style: TextStyle(
                        color: AppColors.textPrimary,
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
      ],
    );
  }
}
