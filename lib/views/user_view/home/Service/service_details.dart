import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recoverylab_front/components/branch_selector.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/models/Branch/branch/branch.dart';
import 'package:recoverylab_front/models/Branch/branch/branch_schedule.dart';
import 'package:recoverylab_front/models/Branch/services/service.dart';
import 'package:recoverylab_front/models/Branch/branchService/service_durations.dart';
import 'package:recoverylab_front/models/Branch/staff/staff.dart';
import 'package:recoverylab_front/models/Offer/offer_package.dart';
import 'package:recoverylab_front/models/Offer/user_package.dart';
import 'package:recoverylab_front/models/User/user_points.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/exception/exception_handling.dart';
import 'package:recoverylab_front/providers/exception/snack_bar.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:recoverylab_front/providers/session/branch_provider.dart';
import 'package:recoverylab_front/providers/session/user_session_provider.dart';
import 'package:recoverylab_front/providers/session/active_membership_provider.dart';
import 'package:recoverylab_front/providers/session/active_offer_provider.dart';
import 'package:recoverylab_front/views/user_view/bookings/booking_success_page.dart';
import 'package:recoverylab_front/views/user_view/packages/packages_details_page.dart';
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
  List<Branch> branches = [];
  List<ServiceDuration?> durations = [];
  List<Staff?> staffList = [];

  /// Full list from branch-service (all qualified staff); restored when date/time/duration change.
  List<Staff?> _allQualifiedStaff = [];
  bool _staffAvailabilityFailed = false;
  int defaultCapacity = 2;
  List<UserPackage> _myPackages = [];
  UserPackage? _selectedPackage;
  List<OfferPackage> _catalogPackages = [];
  UserPoints? _userPoints;
  bool _redeemPoints = false;
  BranchSchedule? _schedule;

  // Loading and error states
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;

  late ActiveOfferNotifier _activeOfferNotifier;

  @override
  void initState() {
    super.initState();
    _activeOfferNotifier = ref.read(activeOfferProvider.notifier);
    _loadDetails();
  }

  void _loadDetails() async {
    try {
      setState(() => isLoading = true);

      // Ensure branches are loaded (e.g. if user opened service details before splash finished)
      List<Branch> branchList = ref.read(branchesProvider);
      if (branchList.isEmpty) {
        await ref.read(branchesProvider.notifier).ensureBranchesFetched();
        branchList = ref.read(branchesProvider);
      }

      branches = branchList;
      final user = ref.read(userSessionProvider).user;
      final idx = branches.indexWhere((b) => b.id == user?.branchId);
      selectedBranchIndex = idx >= 0 ? idx : 0;

      if (branches.isEmpty) {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage =
              'No branches available. Please select a branch in Settings and try again.';
        });
        return;
      }

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
      if (branches.isEmpty ||
          selectedBranchIndex == null ||
          selectedBranchIndex! >= branches.length) {
        setState(() {
          hasError = true;
          errorMessage =
              'No branch selected. Please select a branch in Settings.';
        });
        return;
      }

      final branchId = branches[selectedBranchIndex!].id;

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

      // Set staff from API, but hide internal fallback "All Staff" records
      final filteredStaff = response.staff.where((staff) {
        if (staff == null) return false;
        final id = staff.employeeId;
        if (id.isEmpty) return true;
        return !id.toUpperCase().startsWith('ALL-STAF');
      }).toList();

      staffList = filteredStaff;
      _allQualifiedStaff = List<Staff?>.from(filteredStaff);

      // Set default capacity
      defaultCapacity = branchService.defaultCapacity;

      // Set default duration if not already set
      if (durations.isNotEmpty && selectedDuration == null) {
        selectedDuration = durations[0]?.minutes;
      }

      setState(() {
        hasError = false;
        errorMessage = null;
        _staffAvailabilityFailed = false;
      });
      await _loadCatalogPackages();
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Failed to fetch service details';
      });
    }
  }

  Future<void> _loadCatalogPackages() async {
    if (!mounted) return;
    if (branches.isEmpty ||
        selectedBranchIndex == null ||
        selectedBranchIndex! >= branches.length ||
        selectedDuration == null) {
      setState(() => _catalogPackages = []);
      return;
    }
    final branchId = branches[selectedBranchIndex!].id;
    try {
      final list = await ref.read(apiProvider).getPackages(
            type: 'PACKAGE',
            branchId: branchId,
            serviceId: widget.service.id,
            durationMinutes: selectedDuration!,
          );
      if (mounted) setState(() => _catalogPackages = list);
    } catch (_) {
      if (mounted) setState(() => _catalogPackages = []);
    }
  }

  Future<void> _loadMyPackages() async {
    try {
      final results = await Future.wait([
        ref.read(apiProvider).getMyPackages(),
        ref.read(apiProvider).getMyPoints(),
      ]);
      if (!mounted) return;
      final packages = results[0] as List<UserPackage>;
      final points = results[1] as UserPoints;
      final eligible = packages.where(_isPackageEligibleForBooking).toList();
      setState(() {
        _myPackages = eligible;
        _userPoints = points;
        if (_selectedPackage != null &&
            !eligible.any((pkg) => pkg.id == _selectedPackage!.id)) {
          _selectedPackage = null;
        }
      });
    } catch (_) {
      // Non-critical
    }
  }

  bool _isPackageEligibleForBooking(UserPackage pkg) {
    final currentUserId = ref.read(userSessionProvider).user?.id;
    if (currentUserId == null || pkg.userId != currentUserId) return false;
    if (pkg.status != 'ACTIVE' || pkg.creditsRemaining <= 0) return false;
    final offerPackage = pkg.package;
    if (offerPackage == null ||
        !offerPackage.isPackage ||
        !offerPackage.isActive) {
      return false;
    }
    if (offerPackage.serviceId != null && offerPackage.durationMinutes != null) {
      if (offerPackage.serviceId != widget.service.id) return false;
      if (selectedDuration == null ||
          offerPackage.durationMinutes != selectedDuration) {
        return false;
      }
    }
    final expiry = pkg.expiryDate;
    if (expiry == null || expiry.isEmpty) return true;
    final parsedExpiry = DateTime.tryParse(expiry);
    if (parsedExpiry == null) return true;
    final today = DateTime.now();
    final expiryDate = DateTime(
      parsedExpiry.year,
      parsedExpiry.month,
      parsedExpiry.day,
    );
    final currentDate = DateTime(today.year, today.month, today.day);
    return !expiryDate.isBefore(currentDate);
  }

  UserMembership? _currentBookableMembership() {
    final membership = ref.watch(activeMembershipProvider).value;
    if (membership == null || !membership.isActive) return null;
    final parsedEndDate = DateTime.tryParse(membership.endDate);
    if (parsedEndDate == null) return membership;
    final today = DateTime.now();
    final currentDate = DateTime(today.year, today.month, today.day);
    final endDate = DateTime(
      parsedEndDate.year,
      parsedEndDate.month,
      parsedEndDate.day,
    );
    if (endDate.isBefore(currentDate)) return null;
    return membership;
  }

  Future<void> _loadSchedule() async {
    if (branches.isEmpty) return;
    try {
      final branchId = branches[selectedBranchIndex ?? 0].id;
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
      selectedDate = null;
      selectedTime = null;
      selectedStaff = null;
      _selectedPackage = null;
      _staffAvailabilityFailed = false;
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

  /// Fetch staff who are actually available at the selected slot and update staffList.
  Future<void> _fetchAvailableStaffForSelectedSlot() async {
    if (selectedDate == null ||
        selectedTime == null ||
        selectedDuration == null ||
        selectedBranchIndex == null ||
        selectedBranchIndex! >= branches.length)
      return;
    final branchId = branches[selectedBranchIndex!].id;
    final scheduledStart = _formatDateTimeForApi();
    if (scheduledStart == null) return;
    try {
      final list = await ref
          .read(apiProvider)
          .getAvailableStaff(
            branchId: branchId,
            serviceId: widget.service.id,
            scheduledStart: scheduledStart,
            durationMinutes: selectedDuration!,
          );
      if (!mounted) return;
      // Hide internal fallback "All Staff" records from the selectable staff list
      final newList = list
          .where((staff) {
            final id = staff.employeeId;
            if (id.isEmpty) return true;
            return !id.toUpperCase().startsWith('ALL-STAF');
          })
          .map<Staff?>((s) => s)
          .toList();
      setState(() {
        staffList = newList;
        _staffAvailabilityFailed = false;
        if (selectedStaff != null &&
            !newList.any((s) => s?.id == selectedStaff?.id)) {
          selectedStaff = null;
        }
      });
    } catch (e, s) {
      print('Error fetching available staff: $e');
      print('Stack trace: $s');
      if (!mounted) return;
      setState(() {
        staffList = [];
        selectedStaff = null;
        _staffAvailabilityFailed = true;
      });
      AppSnackBar.show(
        context,
        'Could not verify staff availability right now. You can still continue without selecting a staff member.',
      );
    }
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
      AppSnackBar.show(
        context,
        'Please select number of people for group booking',
      );
      return false;
    }

    return true;
  }

  // Returns how many points the user would use for this booking (capped at booking total value).
  int _pointsForBooking() {
    if (_userPoints == null || _userPoints!.redeemableNow <= 0) return 0;
    final dur = durations.firstWhere(
      (d) => d?.minutes == selectedDuration,
      orElse: () => durations.isNotEmpty ? durations[0] : null,
    );
    final bookingTotal =
        (double.tryParse(dur?.price ?? '0') ?? 0) * (selectedPeopleCount ?? 1);
    if (bookingTotal <= 0) return 0;
    // User can use all their points, capped at the booking total value in points (100pts = 1 EGP)
    final maxByBooking = (bookingTotal * 100).floor();
    return min(_userPoints!.redeemableNow, maxByBooking);
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

  String _friendlyBookingError(String raw) {
    var msg = raw;
    const prefixes = [
      'Failed to create booking: ',
      'Appointment validation failed: ',
      'Failed to create combo booking: ',
    ];
    for (final prefix in prefixes) {
      if (msg.startsWith(prefix)) {
        msg = msg.substring(prefix.length);
      }
    }
    return msg.trim();
  }

  BookingSuccessArgs _buildSuccessArgs() {
    String? dateTimeLabel;
    if (selectedDate != null && selectedTime != null) {
      final d = selectedDate!;
      final t = selectedTime!;
      final hour = t.hour.toString().padLeft(2, '0');
      final minute = t.minute.toString().padLeft(2, '0');
      dateTimeLabel = '${d.day}/${d.month}/${d.year} at $hour:$minute';
    }
    return BookingSuccessArgs(
      serviceName: widget.service.name,
      dateTimeLabel: dateTimeLabel,
      staffName: selectedStaff?.displayName,
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
      final activeOffer = ref.read(activeOfferProvider);
      final response = await ref
          .read(apiProvider)
          .storeBooking(
            userId: user.id,
            branchId: branches[selectedBranchIndex!].id,
            serviceId: widget.service.id,
            formattedDateTime: formattedDateTime!,
            durationMinutes: selectedDuration!,
            participantCount: selectedPeopleCount!,
            staffId: selectedStaff?.id,
            notes: notes.isEmpty ? null : notes,
            paymentMethod: selectedPaymentMethod ?? 'CASH',
            usePackageId: _selectedPackage?.id,
            redeemPoints: _redeemPoints,
            offerId: activeOffer?.id,
          );
      // Offer consumed — clear so it doesn't apply to future bookings.
      ref.read(activeOfferProvider.notifier).clear();

      // Backend returns { success, message, data: { booking, booking_id, ... } }
      final data = response['data'] as Map<String, dynamic>?;
      final bookingId = data?['booking_id'];
      final bookingObj = data?['booking'];
      final rawId = (bookingId ?? bookingObj?['id']);
      _actualBookingId = rawId?.toString();

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      final isOnlinePayment = (selectedPaymentMethod ?? 'CASH') == 'ONLINE';
      if (isOnlinePayment && rawId != null) {
        // Initiate Paymob payment and navigate to WebView
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => _buildPaymentProcessingDialog(),
        );
        try {
          final payResult = await ref
              .read(apiProvider)
              .initiatePayment(rawId is int ? rawId : int.parse(rawId.toString()));
          if (!mounted) return;
          Navigator.pop(context); // Close second loading dialog
          final payData = payResult['data'] as Map<String, dynamic>?;
          final bookingIdInt =
              rawId is int ? rawId : int.parse(rawId.toString());
          if (payData?['already_paid'] == true) {
            Navigator.pushReplacementNamed(
              context,
              Routes.paymentStatus,
              arguments: {'isSuccess': true, 'bookingId': bookingIdInt},
            );
            return;
          }
          final checkoutUrl = payData?['checkout_url'] as String?;
          if (checkoutUrl == null || checkoutUrl.isEmpty) {
            _showPaymentSuccessModal();
            return;
          }
          Navigator.pushReplacementNamed(
            context,
            Routes.paymentScreen,
            arguments: {
              'checkoutUrl': checkoutUrl,
              'bookingId': bookingIdInt,
            },
          );
        } catch (e) {
          if (!mounted) return;
          Navigator.pop(context); // Close loading dialog
          AppSnackBar.show(context,
              'Payment initiation failed. Your booking is saved — you can pay at the branch.');
          Navigator.pushReplacementNamed(
            context,
            Routes.bookingSuccessPage,
            arguments: _buildSuccessArgs(),
          );
        }
      } else {
        _showPaymentSuccessModal();
      }
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context); // Close loading dialog
      final raw = e is ApiException
          ? e.message
          : e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      final message = _friendlyBookingError(raw);
      AppSnackBar.show(context, message);
    }
  }

  Widget _buildBookingConfirmationModal() {
    final selectedDurationData = durations.firstWhere(
      (d) => d?.minutes == selectedDuration,
      orElse: () => durations[0],
    );
    final eligiblePackages = _myPackages
        .where(_isPackageEligibleForBooking)
        .toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
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
          Flexible(
            child: SingleChildScrollView(
              child: Container(
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
                          value: '$selectedDuration minutes',
                        ),
                        SizedBox(height: 1.5.h),
                        _buildConfirmationDetail(
                          icon: Icons.people,
                          label: 'People',
                          value:
                              '$selectedPeopleCount ${selectedPeopleCount == 1 ? 'person' : 'people'}',
                        ),
                        SizedBox(height: 1.5.h),
                        if (selectedStaff != null)
                          _buildConfirmationDetail(
                            icon: Icons.person,
                            label: 'Staff Member',
                            value:
                                selectedStaff!.displayName,
                          ),
                        if (selectedStaff != null) SizedBox(height: 1.5.h),
                        _buildConfirmationDetail(
                          icon: Icons.location_on,
                          label: 'Branch',
                          value: branches[selectedBranchIndex!].name,
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
                    if (eligiblePackages.isNotEmpty) ...[
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
                      StatefulBuilder(
                        builder: (ctx, setInner) {
                          void updatePackage(UserPackage? pkg) {
                            setState(() => _selectedPackage = pkg);
                            setInner(() {});
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () => updatePackage(null),
                                child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 3.w,
                                  vertical: 1.2.h,
                                ),
                                margin: EdgeInsets.only(bottom: 1.h),
                                decoration: BoxDecoration(
                                  color: _selectedPackage == null
                                      ? AppColors.primary.withOpacity(0.2)
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
                                          ? AppColors.info
                                          : AppColors.textTertiary,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      'No package credit',
                                      style: TextStyle(
                                        color: _selectedPackage == null
                                            ? AppColors.info
                                            : AppColors.textSecondary,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ...eligiblePackages.map((pkg) {
                              final isSelected = _selectedPackage?.id == pkg.id;
                              return GestureDetector(
                                onTap: () => updatePackage(pkg),
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
                                            ? AppColors.info
                                            : AppColors.textTertiary,
                                      ),
                                      SizedBox(width: 2.w),
                                      Expanded(
                                        child: Text(
                                          '${pkg.package?.name ?? 'Package'} · ${pkg.creditsRemaining} credit${pkg.creditsRemaining == 1 ? '' : 's'} left',
                                          style: TextStyle(
                                            color: isSelected
                                                ? AppColors.info
                                                : AppColors.textSecondary,
                                            fontSize: 13.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                              SizedBox(height: 1.h),
                              Container(height: 0.5, color: AppColors.dividerColor),
                              SizedBox(height: 2.h),
                              Builder(
                                builder: (_) {
                                  final totalInfo =
                                      _getDisplayTotalWithMembershipAndPackage(
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
                          );
                        },
                      ),
                    ],
                    if (eligiblePackages.isEmpty) ...[
                        Container(height: 0.5, color: AppColors.dividerColor),
                        SizedBox(height: 2.h),
                        Builder(
                          builder: (_) {
                            final totalInfo =
                                _getDisplayTotalWithMembershipAndPackage(
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
                    ],
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Active promotional offer banner
          Builder(builder: (ctx) {
            final activeOffer = ref.watch(activeOfferProvider);
            if (activeOffer == null) return const SizedBox.shrink();
            final branchId = selectedBranchIndex != null &&
                    branches.length > selectedBranchIndex!
                ? branches[selectedBranchIndex!].id
                : null;
            if (!activeOffer.appliesToService(
              serviceId: widget.service.id,
              categoryId: widget.service.category.id,
              branchId: branchId,
            )) {
              return const SizedBox.shrink();
            }
            final badge = activeOffer.discountBadge;
            return Container(
              margin: EdgeInsets.only(bottom: 2.h),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.success.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Icon(SolarIconsBold.tag, size: 18.sp, color: AppColors.success),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activeOffer.title,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (badge != null)
                          Text(
                            badge,
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => ref.read(activeOfferProvider.notifier).clear(),
                    child: Icon(Icons.close, size: 16.sp, color: AppColors.textTertiary),
                  ),
                ],
              ),
            );
          }),

          // Points redemption toggle
          Builder(builder: (_) {
            final capped = _pointsForBooking();
            if (capped <= 0) return const SizedBox.shrink();
            final cappedEgp = capped / 100.0;
            return StatefulBuilder(
              builder: (ctx, setInner) {
                return Container(
                  margin: EdgeInsets.only(bottom: 2.h),
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                  decoration: BoxDecoration(
                    color: _redeemPoints
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _redeemPoints
                          ? AppColors.primary
                          : AppColors.dividerColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        SolarIconsBold.star,
                        size: 18.sp,
                        color: _redeemPoints
                            ? AppColors.primary
                            : AppColors.textTertiary,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Use $capped points',
                              style: TextStyle(
                                color: _redeemPoints
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '= ${cappedEgp.toStringAsFixed(2)} EGP off',
                              style: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _redeemPoints,
                        onChanged: (v) {
                          setState(() => _redeemPoints = v);
                          setInner(() {});
                        },
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                );
              },
            );
          }),

          // Payment method selector
          StatefulBuilder(
            builder: (ctx, setInner) {
              final isOnline = (selectedPaymentMethod ?? 'CASH') == 'ONLINE';
              return Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => selectedPaymentMethod = 'CASH');
                          setInner(() {});
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          decoration: BoxDecoration(
                            color: !isOnline
                                ? AppColors.primary
                                : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: !isOnline
                                  ? AppColors.primary
                                  : AppColors.dividerColor,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.store_outlined,
                                size: 16.sp,
                                color: !isOnline
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Pay at Branch',
                                style: TextStyle(
                                  color: !isOnline
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                  fontSize: 12.sp,
                                  fontWeight: !isOnline
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => selectedPaymentMethod = 'ONLINE');
                          setInner(() {});
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          decoration: BoxDecoration(
                            color: isOnline
                                ? AppColors.primary
                                : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isOnline
                                  ? AppColors.primary
                                  : AppColors.dividerColor,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.credit_card,
                                size: 16.sp,
                                color: isOnline
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Pay Online',
                                style: TextStyle(
                                  color: isOnline
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                  fontSize: 12.sp,
                                  fontWeight: isOnline
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

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
                    final user = ref.read(userSessionProvider).user;
                    if (user == null) return;
                    final selDurationData = durations.firstWhere(
                      (d) => d?.minutes == selectedDuration,
                      orElse: () => durations[0],
                    );
                    final totalInfo =
                        _getDisplayTotalWithMembershipAndPackage(
                      selDurationData?.price,
                      selectedPeopleCount ?? 1,
                    );
                    final baseTotal =
                        (double.tryParse(selDurationData?.price ?? '0') ??
                                0) *
                            (selectedPeopleCount ?? 1);
                    final activeOffer = ref.read(activeOfferProvider);
                    Navigator.pop(context); // Close confirmation sheet
                    Navigator.pushNamed(
                      context,
                      Routes.bookingConfirmation,
                      arguments: {
                        'userId': user.id,
                        'branchId': branches[selectedBranchIndex!].id,
                        'branchName': branches[selectedBranchIndex!].name,
                        'serviceId': widget.service.id,
                        'serviceName': widget.service.name,
                        'formattedDateTime': _formatDateTimeForApi()!,
                        'durationMinutes': selectedDuration!,
                        'participantCount': selectedPeopleCount!,
                        'staffId': selectedStaff?.id,
                        'staffName': selectedStaff?.displayName,
                        'notes': notes.isEmpty ? null : notes,
                        'paymentMethod': selectedPaymentMethod ?? 'CASH',
                        'usePackageId': _selectedPackage?.id,
                        'packageName': _selectedPackage?.package?.name,
                        'redeemPoints': _redeemPoints,
                        'offerId': activeOffer?.id,
                        'displayDate':
                            '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                        'displayTime': _formatHour(selectedTime!.hour),
                        'basePrice':
                            'EGP ${baseTotal.toStringAsFixed(0)}',
                        'finalPrice': totalInfo.$1,
                        'discountLabel': totalInfo.$3,
                      },
                    );
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
                        'Review & Pay',
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
                    ref.read(bookingNeedsRefreshProvider.notifier).set(true);
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
  void dispose() {
    _activeOfferNotifier.clear();
    super.dispose();
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
                          fontSize: 16.sp,
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
                        onTap: () {
                          final selectedBranch =
                              selectedBranchIndex != null &&
                                  selectedBranchIndex! < branches.length
                              ? branches[selectedBranchIndex!]
                              : null;
                          if (selectedBranch == null) return;
                          BranchSelector.showSelectionModal(
                            context: context,
                            branches: branches,
                            selectedBranch: selectedBranch,
                            onSelected: (branch) async {
                              final newBranchIndex = branches.indexWhere(
                                (b) => b.id == branch.id,
                              );
                              if (newBranchIndex != -1) {
                                await _onBranchChanged(newBranchIndex);
                              }
                            },
                          );
                        },
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
                if (_catalogPackages.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  _buildSessionPackagesCatalog(),
                ],
                if (staffList.isNotEmpty) _buildStaffSelector(),
                if (selectedDate != null &&
                    selectedTime != null &&
                    selectedDuration != null &&
                    staffList.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: 2.h),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: _staffAvailabilityFailed
                            ? AppColors.warning.withOpacity(0.08)
                            : AppColors.info.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _staffAvailabilityFailed
                              ? AppColors.warning.withOpacity(0.25)
                              : AppColors.info.withOpacity(0.25),
                        ),
                      ),
                      child: Text(
                        _staffAvailabilityFailed
                            ? 'Staff availability could not be verified for this slot. Continue without selecting a staff member if you want the branch to handle assignment.'
                            : 'No staff available for this time slot. Please select a different date or time.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.sp,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
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
    final selectedBranch =
        selectedBranchIndex != null && selectedBranchIndex! < branches.length
        ? branches[selectedBranchIndex!]
        : null;

    return BranchSelector(
      title: 'SELECTED BRANCH',
      branches: branches,
      selectedBranch: selectedBranch,
      onSelected: (branch) async {
        final newBranchIndex = branches.indexWhere((b) => b.id == branch.id);
        if (newBranchIndex != -1) {
          await _onBranchChanged(newBranchIndex);
        }
      },
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
                    colorScheme: ColorScheme.dark(
                      primary: AppColors.info,
                      onPrimary: AppColors.background,
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
                AppSnackBar.show(
                  context,
                  'Special hours on this day: $open – $close$note',
                );
              }
              setState(() {
                selectedDate = pickedDate;
                selectedTime = null; // reset time when date changes
                selectedStaff = null;
                staffList = List<Staff?>.from(_allQualifiedStaff);
                _staffAvailabilityFailed = false;
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

  /// Best membership discount % (0–100) for a service using relation targets.
  num _bestMembershipDiscountForService(
    UserMembership? membership,
    int serviceId,
    int categoryId,
  ) {
    if (membership == null || membership.plan == null) return 0;
    num best = 0;
    for (final b in membership.plan!.benefits) {
      if (!b.appliesTo(serviceId: serviceId, categoryId: categoryId)) continue;
      if (b.benefitType == 'UNLIMITED_ACCESS') return 100;
      if (b.benefitType == 'DISCOUNT' && b.value != null && b.value! > best)
        best = b.value!;
    }
    return best;
  }

  /// Membership-aware total for display. Returns (displayString, originalTotalForStrikethrough or null).
  (String display, String? original, String? membershipLabel)
  _getDisplayTotalWithMembership(String? priceStr, int participantCount) {
    final baseTotal =
        (double.tryParse(priceStr ?? '0') ?? 0) * participantCount;
    final membership = _currentBookableMembership();
    final discountPct = _bestMembershipDiscountForService(
      membership,
      widget.service.id,
      widget.service.category.id,
    );
    if (discountPct >= 100) {
      return (
        'Free',
        baseTotal > 0 ? 'EGP ${baseTotal.toStringAsFixed(0)}' : null,
        'Included in your membership',
      );
    }
    if (discountPct > 0) {
      final discounted = baseTotal * (1 - discountPct / 100);
      return (
        'EGP ${discounted.toStringAsFixed(0)}',
        'EGP ${baseTotal.toStringAsFixed(0)}',
        null,
      );
    }
    return ('EGP ${baseTotal.toStringAsFixed(0)}', null, null);
  }

  /// Best of membership vs selected package (matches backend: no stacking, higher % wins).
  /// Package only applies if user selected one and it has credits.
  (String display, String? original, String? label)
  _getDisplayTotalWithMembershipAndPackage(
    String? priceStr,
    int participantCount,
  ) {
    final baseTotal =
        (double.tryParse(priceStr ?? '0') ?? 0) * participantCount;
    final membership = _currentBookableMembership();
    final membershipPct = _bestMembershipDiscountForService(
      membership,
      widget.service.id,
      widget.service.category.id,
    );
    final offer = _selectedPackage?.package;
    final legacyUnbound =
        offer != null &&
        offer.serviceId == null &&
        offer.durationMinutes == null;
    final boundMatches = offer != null &&
        offer.serviceId == widget.service.id &&
        offer.durationMinutes == selectedDuration;
    final bool packageDiscountApplies = _selectedPackage != null &&
        _selectedPackage!.creditsRemaining > 0 &&
        offer != null &&
        (legacyUnbound || boundMatches);
    final packagePct = packageDiscountApplies && offer != null
        ? (offer.discountPercentage ?? 0).toDouble()
        : 0.0;

    // Step 1: resolve membership/package
    double priceAfterMembershipPackage = baseTotal;
    String? membershipPackageLabel;
    bool isFreeViaMembership = false;

    if (membershipPct >= 100) {
      priceAfterMembershipPackage = 0;
      membershipPackageLabel = 'Included in your membership';
      isFreeViaMembership = true;
    } else {
      final packageWins = packagePct > membershipPct;
      final bestPct = packageWins ? packagePct : membershipPct;
      if (bestPct > 0) {
        priceAfterMembershipPackage = baseTotal * (1 - bestPct / 100);
        membershipPackageLabel = packageWins
            ? '${packagePct.toInt()}% off with package'
            : '${membershipPct.toInt()}% off with membership';
      }
    }

    if (isFreeViaMembership) {
      return (
        'Free',
        baseTotal > 0 ? 'EGP ${baseTotal.toStringAsFixed(0)}' : null,
        membershipPackageLabel,
      );
    }
    if (priceAfterMembershipPackage < baseTotal) {
      return (
        'EGP ${priceAfterMembershipPackage.toStringAsFixed(0)}',
        'EGP ${baseTotal.toStringAsFixed(0)}',
        membershipPackageLabel,
      );
    }

    // Promotional offer (best vs membership/package — mirrors backend)
    final activeOffer = ref.read(activeOfferProvider);
    final branchId = selectedBranchIndex != null &&
            branches.length > selectedBranchIndex!
        ? branches[selectedBranchIndex!].id
        : null;
    if (activeOffer != null &&
        activeOffer.appliesToService(
          serviceId: widget.service.id,
          categoryId: widget.service.category.id,
          branchId: branchId,
        ) &&
        participantCount > 0) {
      final unitPrice = baseTotal / participantCount;
      final offerPct = activeOffer.discountPercentForUnitPrice(unitPrice);
      final packageWins = packagePct > membershipPct;
      final offerWins = !packageWins && offerPct > membershipPct;
      if (offerWins && offerPct > 0) {
        final afterOffer = activeOffer.applyDiscountToAmount(baseTotal);
        return (
          'EGP ${afterOffer.toStringAsFixed(0)}',
          'EGP ${baseTotal.toStringAsFixed(0)}',
          activeOffer.discountBadge,
        );
      }
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
            ? (scheduleSlots.last + 1)
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
                        _fetchAvailableStaffForSelectedSlot();
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

  Widget _buildSessionPackagesCatalog() {
    if (selectedDuration == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.card_giftcard, color: AppColors.info, size: 18.sp),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                'Session packages for ${widget.service.name} · $selectedDuration min',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Text(
          'Credits apply only to this service and session length.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11.sp,
          ),
        ),
        SizedBox(height: 1.5.h),
        ..._catalogPackages.map((p) {
          final credits = p.totalCredits;
          final discount = p.discountPercentage;
          return Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 1.5.h),
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.dividerColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                      ),
                      if (credits != null)
                        Text(
                          '$credits credits${discount != null ? ' · ${discount.toInt()}% off per session' : ''}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11.sp,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  'EGP ${p.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(width: 2.w),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PackageDetailsPage(
                          itemId: p.id,
                          type: PackageType.package,
                          title: p.name,
                          description: p.description ?? '',
                          imagePath: p.image?.isNotEmpty == true
                              ? p.image!
                              : widget.service.image,
                          totalDuration:
                              credits != null ? '$credits sessions' : '',
                          price: p.price.toStringAsFixed(0),
                          inclusions: [
                            {
                              'icon': 'icon_massage',
                              'name':
                                  '${widget.service.name} · $selectedDuration min only',
                              'duration': '',
                            },
                            if (credits != null)
                              {
                                'icon': 'icon_spa',
                                'name': '$credits session credits',
                                'duration': '',
                              },
                            if (discount != null)
                              {
                                'icon': 'icon_discount',
                                'name': '${discount.toInt()}% off per booked session',
                                'duration': '',
                              },
                            if (p.validityDays != null)
                              {
                                'icon': 'icon_spa',
                                'name': 'Valid for ${p.validityDays} days after purchase',
                                'duration': '',
                              },
                          ],
                        ),
                      ),
                    ).then((_) {
                      _loadMyPackages();
                    });
                  },
                  child: Text(
                    'Buy',
                    style: TextStyle(color: AppColors.info, fontSize: 12.sp),
                  ),
                ),
              ],
            ),
          );
        }),
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
              onTap: () async {
                setState(() {
                  selectedDuration = duration.minutes;
                  selectedTime =
                      null; // Re-pick time so it stays within branch hours for new duration
                  selectedStaff = null;
                  staffList = List<Staff?>.from(_allQualifiedStaff);
                  _staffAvailabilityFailed = false;
                });
                await _loadCatalogPackages();
                await _loadMyPackages();
              },
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

              final isSelected = selectedStaff?.id == staff.id;

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
                            ? Icon(
                                Icons.person,
                                color: AppColors.textTertiary,
                                size: 20.sp,
                              )
                            : null,
                      ),
                    ),

                    SizedBox(height: 1.h),
                    Text(
                      '${staff.firstName} ${staff.lastName.isNotEmpty ? staff.lastName.substring(0, 1) : ''}.',
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

  Widget _buildIncludedServiceItem(String? service) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.topLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 0.15.h),
            child: Icon(
              SolarIconsOutline.startShine,
              color: AppColors.info,
              size: 18.sp,
            ),
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
  }

  Widget _buildIncludedServices() {
    final List<String?> services = [...widget.service.includedIn];
    final horizontalGap = 3.w;
    final rowSpacing = 2.h;

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
        Padding(
          padding: EdgeInsets.only(top: 2.h),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < services.length; i += 2)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: i + 2 >= services.length ? 0 : rowSpacing,
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _buildIncludedServiceItem(services[i]),
                          ),
                          SizedBox(width: horizontalGap),
                          Expanded(
                            child: i + 1 < services.length
                                ? _buildIncludedServiceItem(services[i + 1])
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
