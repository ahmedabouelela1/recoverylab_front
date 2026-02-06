import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/models/Branch/branch/branch.dart';
import 'package:recoverylab_front/models/Branch/services/service.dart';
import 'package:recoverylab_front/models/Branch/services/serviceDurations/service_durations.dart';
import 'package:recoverylab_front/models/Branch/therapists/therapists.dart';
import 'package:recoverylab_front/providers/session/branch_provider.dart';
import 'package:recoverylab_front/providers/session/user_session_provider.dart';
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
  Therapist? selectedTherapist;
  String selectedType = 'single';
  List<Branch?> branches = [];
  List<ServiceDuration> durations = [];
  List<Therapist> therapists = [];

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
      selectedBranchIndex = user?.branchId ?? 0;
      branches = ref.read(branchesProvider);

      await _fetchServiceDetails();
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
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      final mockResponse = {
        "durations": [
          {"minutes": 60, "price": "\$80.00", "description": "Standard"},
          {"minutes": 90, "price": "\$110.00", "description": "Extended"},
          {"minutes": 120, "price": "\$140.00", "description": "Ultimate"},
        ],
        "therapists": [
          {
            "id": "1",
            "name": "Amira L.",
            "role": "SENIOR",
            "image":
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTSoTPPGzNCkV9dAgvZ-tehCaqYnKRnkpfLoA&s",
          },
          {
            "id": "2",
            "name": "Malika S.",
            "role": "EXPERT",
            "image":
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTSoTPPGzNCkV9dAgvZ-tehCaqYnKRnkpfLoA&s",
          },
        ],
        "available": true,
      };

      if (mockResponse['available'] == false) {
        setState(() {
          hasError = true;
          errorMessage = 'Service not available at this branch';
        });
        return;
      }

      durations = (mockResponse['durations'] as List)
          .map((d) => ServiceDuration.fromJson(d))
          .toList();

      therapists = (mockResponse['therapists'] as List)
          .map((t) => Therapist.fromJson(t))
          .toList();

      if (durations.isNotEmpty && selectedDuration == null) {
        selectedDuration = durations[0].minutes;
      }
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Failed to fetch service details';
      });
    }
  }

  Future<void> _onBranchChanged(int newBranchIndex) async {
    setState(() {
      selectedBranchIndex = newBranchIndex;
      isLoading = true;
    });

    await _fetchServiceDetails();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select date and time'),
          backgroundColor: AppColors.warning,
        ),
      );
      return false;
    }

    if (selectedDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select duration'),
          backgroundColor: AppColors.warning,
        ),
      );
      return false;
    }

    if (selectedType == 'group' && selectedPeopleCount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select number of people for group booking'),
          backgroundColor: AppColors.warning,
        ),
      );
      return false;
    }

    return true;
  }

  // Show booking confirmation modal
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

  // Process payment
  void _processPayment() {
    final formattedDateTime = _formatDateTimeForApi();

    final bookingData = {
      'service_id': widget.service.id,
      'branch_id': branches[selectedBranchIndex!]!.id,
      'duration': selectedDuration,
      'date_time': formattedDateTime,
      'notes': notes,
      'therapist_id': selectedTherapist?.id,
      'people_count': selectedPeopleCount,
      'booking_type': selectedType,
    };

    print('Booking data for payment: $bookingData');

    // TODO: Process payment with third-party API
    // Example:
    // 1. Close confirmation modal
    Navigator.pop(context);

    // 2. Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildPaymentProcessingDialog(),
    );

    // 3. Process payment (mock for now)
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context); // Close loading dialog

      // 4. Show success modal
      _showPaymentSuccessModal();
    });
  }

  Widget _buildBookingConfirmationModal() {
    final selectedDurationData = durations.firstWhere(
      (d) => d.minutes == selectedDuration,
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
          // Draggable handle
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

          // Title
          Text(
            'Booking Summary',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),

          // Booking details card
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.dividerColor),
            ),
            child: Column(
              children: [
                // Service name
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

                // Divider
                Container(height: 0.5, color: AppColors.dividerColor),
                SizedBox(height: 2.h),

                // Booking details grid
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
                      value: selectedTime!.format(context),
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
                    if (selectedTherapist != null)
                      _buildConfirmationDetail(
                        icon: Icons.person,
                        label: 'Therapist',
                        value: selectedTherapist!.name,
                      ),
                    if (selectedTherapist != null) SizedBox(height: 1.5.h),
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

                // Divider
                Container(height: 0.5, color: AppColors.dividerColor),
                SizedBox(height: 2.h),

                // Price summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                      ),
                    ),
                    Text(
                      selectedDurationData.price,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),

          // Confirm button
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
                  onPressed: _processPayment,
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
                        'Pay Now',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Icon(Icons.lock, size: 16.sp),
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

          // Success icon
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

          // Success message
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

          // Booking ID
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
                        '#BK${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
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

          // Next steps
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

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close success modal
                    Navigator.pop(context); // Go back to service details
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
                    Navigator.pop(context); // Close success modal
                    Navigator.pop(context); // Go back to service details
                    // TODO: Navigate to bookings screen
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
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeaderImage(),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                SizedBox(height: 2.h),
                _buildBranchSelector(),
                Icon(Icons.info_outline, size: 60.sp, color: AppColors.warning),
                SizedBox(height: 2.h),
                Text(
                  'Service Not Available',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  errorMessage ??
                      'This service is not available at this branch.\nPlease try another branch.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 2.h),
                ElevatedButton(
                  onPressed: _loadDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
                _buildPeopleSelector(),
                SizedBox(height: 2.h),
                _buildDateSelector(),
                SizedBox(height: 2.h),
                _buildTimeSelector(),
                SizedBox(height: 2.h),
                _buildDurationSelector(),
                if (therapists.isNotEmpty) _buildTherapistSelector(),
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
                    'UP TO 2\nPEOPLE',
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
              setState(() => selectedDate = pickedDate);
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
      ],
    );
  }

  Widget _buildTimeSelector() {
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
          onTap: () async {
            final pickedTime = await showTimePicker(
              context: context,
              initialTime: selectedTime ?? TimeOfDay.now(),
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

            if (pickedTime != null) {
              setState(() => selectedTime = pickedTime);
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
                  SolarIconsOutline.clockCircle,
                  color: AppColors.strokeBorder,
                  size: 20.sp,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    selectedTime == null
                        ? 'Choose a time'
                        : selectedTime!.format(context),
                    style: TextStyle(
                      color: selectedTime == null
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
          children: durations.map((duration) {
            final isSelected = selectedDuration == duration.minutes;
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
                          SizedBox(height: 0.5.h),
                          Text(
                            duration.description,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      duration.price,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
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

  Widget _buildTherapistSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT THERAPIST (OPTIONAL)',
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
            itemCount: therapists.length,
            separatorBuilder: (_, __) => SizedBox(width: 4.w),
            itemBuilder: (context, index) {
              final therapist = therapists[index];
              final isSelected = selectedTherapist?.id == therapist.id;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTherapist = isSelected ? null : therapist;
                  });
                },
                child: Column(
                  children: [
                    /// Avatar with border
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(isSelected ? 0.8.w : 0.5.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors
                                    .info // gold-like ring
                              : AppColors.dividerColor,
                          width: isSelected ? 3 : 1.5,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 8.w,
                        backgroundImage: NetworkImage(therapist.image),
                        backgroundColor: AppColors.surfaceLight,
                      ),
                    ),

                    SizedBox(height: 1.h),
                    Text(
                      therapist.name,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 0.5.h),

                    Text(
                      therapist.role.toUpperCase(),
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
      (d) => d.minutes == selectedDuration,
      orElse: () => durations[0],
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
                    Text(
                      selectedDurationData.price,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
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
}
