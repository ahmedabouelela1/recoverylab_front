// lib/pages/booking/booking_page_two.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
// Assuming these are your custom imports
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/models/booking_model.dart';
import 'package:recoverylab_front/models/staff_member_model.dart';

class BookingPageTwo extends StatefulWidget {
  final Booking booking;
  final List<StaffMember> allStaffMembers;

  // State from parent container
  final StaffMember? selectedTherapist;
  final Function(StaffMember?) onTherapistSelected;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final int startTimeHour;
  final Function(int) onStartTimeHourChanged;
  final int durationHour;
  final int durationMinute;
  final Function(int, int) onDurationChanged;
  final String timePeriod;
  final Function(String) onTimePeriodChanged;

  const BookingPageTwo({
    super.key,
    required this.booking,
    required this.allStaffMembers,
    required this.selectedTherapist,
    required this.onTherapistSelected,
    required this.selectedDate,
    required this.onDateSelected,
    required this.startTimeHour,
    required this.onStartTimeHourChanged,
    required this.durationHour,
    required this.durationMinute,
    required this.onDurationChanged,
    required this.timePeriod,
    required this.onTimePeriodChanged,
  });

  @override
  State<BookingPageTwo> createState() => _BookingPageTwoState();
}

class _BookingPageTwoState extends State<BookingPageTwo> {
  // Local state for party size selection
  String _selectedPartySize = 'Double'; // Initial state based on screenshot

  // Lists for dropdown options
  final List<int> availableHours = List.generate(
    12,
    (index) => index + 1,
  ); // 1 to 12
  // Durations in minutes: 60, 90, 120 (1hr, 1.5hr, 2hr)
  final List<int> availableDurations = [60, 90, 120];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // This section is now Step 1: Booking Info
          _buildServiceHeader(),
          SizedBox(height: 3.h),
          _buildPartySizeSelector(),
          SizedBox(height: 3.h),
          _buildTherapistSection(),
          SizedBox(height: 3.h),

          // Dropdown/Picker-style selectors
          _buildDateSelector(),
          SizedBox(height: 3.h),
          _buildTimeSelector(),
          SizedBox(height: 3.h),
          _buildDurationSelector(),

          SizedBox(height: 1.h),
        ],
      ),
    );
  }

  // --- UI Building Blocks ---

  Widget _buildServiceHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            widget.booking.imageUrl,
            height: 10.h,
            width: 25.w,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.booking.title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  // Checkmark on service header (based on Screenshot 2025-10-05 193633.png)
                  const Icon(
                    Icons.check_box,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ],
              ),
              SizedBox(height: 0.5.h),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    widget.booking.location,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.5.h),
              Row(
                children: [
                  const Icon(Icons.star, color: AppColors.warning, size: 16),
                  SizedBox(width: 1.w),
                  Text(
                    "${widget.booking.rating}(320)",
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPartySizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title is omitted in the screenshot, but keeping the structure for clarity
        /* Text(
          "Party Size",
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 15.sp,
          ),
        ),
        SizedBox(height: 1.5.h), */
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ["Single", "Double", "Group"].map((size) {
            bool isSelected = _selectedPartySize == size;
            return GestureDetector(
              onTap: () => setState(() => _selectedPartySize = size),
              child: Container(
                width: 28.w,
                height: 10.h,
                decoration: BoxDecoration(
                  // Use primary color tint for selected item background
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors
                              .cardBackground, // Solid dark background means border is implicit
                    width: isSelected ? 1 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      size == "Single"
                          ? Icons.person
                          : (size == "Double" ? Icons.people_alt : Icons.group),
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      size: 3.h,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      size,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
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

  Widget _buildTherapistSection() {
    final selected = widget.selectedTherapist;
    if (selected == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Therapist",
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 15.sp,
          ),
        ),
        SizedBox(height: 1.5.h),
        GestureDetector(
          onTap: () {
            // Logic to change therapist goes here
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 4.w),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              // No visible border, just the dark card background
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 3.h,
                  backgroundImage: AssetImage(selected.imageUrl),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selected.name,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        selected.role,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Small green dot for selection confirmation
                Container(
                  width: 1.5.h,
                  height: 1.5.h,
                  decoration: BoxDecoration(
                    color: Colors
                        .lightGreen, // Using a standard green color for the dot
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- Dropdown/Picker Widgets (Matching Screenshot 2025-10-05 193633.png) ---

  Widget _buildDateSelector() {
    // Format date as "June 15, 2025"
    String displayDate =
        '${_getMonthName(widget.selectedDate.month)} ${widget.selectedDate.day},${widget.selectedDate.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Date",
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 15.sp,
          ),
        ),
        SizedBox(height: 1.5.h),
        GestureDetector(
          onTap: () => _showDatePicker(context), // Use standard date picker
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  displayDate,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector() {
    // Current display is "10:00 Am" based on initial state and screenshot
    String formattedTime =
        "${widget.startTimeHour.toString().padLeft(2, '0')}:00 ${widget.timePeriod.toUpperCase()}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Time",
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 15.sp,
          ),
        ),
        SizedBox(height: 1.5.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: formattedTime,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textSecondary,
              ),
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              dropdownColor: AppColors.cardBackground,
              items: _getAvailableTimeSlots().map((String slot) {
                return DropdownMenuItem<String>(value: slot, child: Text(slot));
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _updateTime(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSelector() {
    // Current display is "1 Hour 00 minute"
    int totalMinutes = widget.durationHour * 60 + widget.durationMinute;
    String displayDuration = _formatDuration(totalMinutes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Duration",
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 15.sp,
          ),
        ),
        SizedBox(height: 1.5.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              value: totalMinutes,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textSecondary,
              ),
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              dropdownColor: AppColors.cardBackground,
              items: availableDurations.map((int minutes) {
                return DropdownMenuItem<int>(
                  value: minutes,
                  child: Text(_formatDuration(minutes)),
                );
              }).toList(),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  int hr = newValue ~/ 60;
                  int min = newValue % 60;
                  widget.onDurationChanged(hr, min);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  // --- Helper Functions ---

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'June',
      'July',
      'Aug',
      'Sept',
      'Oct',
      'Nov',
      'Dec',
    ];
    // Ensure month is 1-indexed for the array lookup (which is 0-indexed)
    return months[month - 1];
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.textPrimary,
              surface: AppColors.cardBackground,
              onSurface: AppColors.textPrimary,
            ),
            dialogBackgroundColor: AppColors.background,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      widget.onDateSelected(picked);
    }
  }

  List<String> _getAvailableTimeSlots() {
    List<String> slots = [];
    for (var period in ['am', 'pm']) {
      for (var hour in availableHours) {
        // Generate slots only on the hour for simplicity
        slots.add(
          "${hour.toString().padLeft(2, '0')}:00 ${period.toUpperCase()}",
        );
      }
    }
    // Ensure the currently selected slot is included and sort them naturally (optional, but good practice)
    slots.sort((a, b) {
      int aHour = int.parse(a.substring(0, 2));
      String aPeriod = a.substring(6);
      int bHour = int.parse(b.substring(0, 2));
      String bPeriod = b.substring(6);

      // Convert to 24-hour time for accurate sorting
      int to24Hour(int hour, String period) {
        if (period == 'AM') return hour == 12 ? 0 : hour;
        return hour == 12 ? 12 : hour + 12;
      }

      return to24Hour(aHour, aPeriod).compareTo(to24Hour(bHour, bPeriod));
    });

    // Add current selection if not found (shouldn't happen with the generation logic, but for safety)
    String currentSlot =
        "${widget.startTimeHour.toString().padLeft(2, '0')}:00 ${widget.timePeriod.toUpperCase()}";
    if (!slots.contains(currentSlot)) {
      slots.insert(0, currentSlot);
    }

    return slots;
  }

  void _updateTime(String newSlot) {
    RegExp regex = RegExp(r"(\d{2}):00 (AM|PM)");
    Match? match = regex.firstMatch(newSlot);

    if (match != null) {
      int hour = int.parse(match.group(1)!);
      String period = match.group(2)!.toLowerCase();

      widget.onStartTimeHourChanged(hour);
      widget.onTimePeriodChanged(period);
    }
  }

  String _formatDuration(int totalMinutes) {
    if (totalMinutes <= 0) return "00 minute";
    int hr = totalMinutes ~/ 60;
    int min = totalMinutes % 60;

    String hrPart = hr > 0 ? "$hr Hour" : "";
    String minPart = min > 0 ? "$min minute" : "";

    // Format to match the screenshot: "1 Hour 00 minute" or "30 minute"
    if (hr > 0 && min == 0) return "$hr Hour 00 minute";
    if (hr == 0 && min > 0) return "$min minute";

    return "$hrPart $minPart".trim();
  }
}
