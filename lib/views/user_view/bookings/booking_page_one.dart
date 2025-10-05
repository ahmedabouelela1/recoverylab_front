import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

// Assuming these are your custom imports and models
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/models/booking_model.dart';
import 'package:recoverylab_front/models/staff_member_model.dart';
// 🔑 Import the next pages/screens
import 'package:recoverylab_front/views/user_view/bookings/booking_page_three.dart';
import 'package:recoverylab_front/views/user_view/bookings/booking_page_two.dart';
import 'package:recoverylab_front/views/user_view/bookings/booking_success_page.dart';
import 'package:recoverylab_front/views/user_view/bookings/staff_details_page.dart';

// --- MOCK DATA SETUP ---
// 🔑 FIX: Get the full reviews list from the model
final List<Map<String, dynamic>> _laylaReviews = mockLayla.reviews;
final List<Map<String, dynamic>> _emptyReviews =
    []; // Use this for staff without mock data

final List<StaffMember> allStaffMembers = [
  // Staff Member 1 (Layla) - NOW USING THE FULL REVIEWS LIST
  StaffMember(
    name: "Layla Nour",
    role: "Senior Massage Therapist",
    imageUrl: 'lib/assets/images/curly.jpg',
    bio:
        "Specializes in deep tissue, Egyptian aromatherapy, and prenatal massage with over 8 years of experience in holistic healing.",
    reviews: _laylaReviews, // CRITICAL FIX: Ensures reviews are passed
    rating: 4.8,
    reviewsCount: 273,
  ),
  // Staff Member 2 (Mariam)
  StaffMember(
    name: "Mariam El-Baz",
    role: "Spa Specialist",
    imageUrl: 'lib/assets/images/curly.jpg',
    bio:
        "Expert in traditional Egyptian spa treatments, specializing in relaxation and skin health.",
    reviews: _emptyReviews, // Correctly shows "No customer reviews yet."
    rating: 4.5,
    reviewsCount: 190,
  ),
  // Staff Member 3 (Ahmed)
  StaffMember(
    name: "Ahmed Hassan",
    role: "Deep Tissue Specialist",
    imageUrl: 'lib/assets/images/profile.png', // Placeholder
    bio:
        "Certified therapist focused on sports recovery and myofascial release techniques.",
    reviews: _emptyReviews,
    rating: 4.7,
    reviewsCount: 155,
  ),
  // Staff Member 4 (Noha)
  StaffMember(
    name: "Noha Tarek",
    role: "Acupuncture & Wellness",
    imageUrl: 'lib/assets/images/curly.jpg', // Placeholder
    bio:
        "Licensed acupuncturist integrating ancient techniques with modern wellness practices.",
    reviews: _emptyReviews,
    rating: 4.9,
    reviewsCount: 301,
  ),
];

class BookingPageOne extends StatefulWidget {
  final Booking booking;
  const BookingPageOne({super.key, required this.booking});

  @override
  State<BookingPageOne> createState() => _BookingPageOneState();
}

class _BookingPageOneState extends State<BookingPageOne> {
  late PageController _pageController;
  int _currentStepIndex = 0;
  final int _totalSteps = 3;

  // --- Shared State ---
  StaffMember? _selectedStaff;
  DateTime _selectedDate = DateTime.now();
  int _startTimeHour = 10;
  int _durationHour = 1;
  int _durationMinute = 0;
  String _timePeriod = 'am';
  String _personCount = "Double";

  // State for Page 0 (Book) - Add-ons
  final Map<String, int> _addonPrices = {
    "Aromatherapy": 20,
    "Hot Stone Therapy": 15,
    "Deep Tissue Upgrade": 25,
  };
  final Map<String, bool> _selectedAddons = {
    "Aromatherapy": false,
    "Hot Stone Therapy": false,
    "Deep Tissue Upgrade": false,
  };

  // Base price and fees for Checkout calculation
  final double _baseServicePrice = 142.90;
  static const double _taxAndFees = 14.80;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentStepIndex);
    _pageController.addListener(_updateCurrentStep);

    // Initializing with a default staff member
    _selectedStaff = allStaffMembers.firstWhere(
      (s) => s.name == "Layla Nour",
      orElse: () => allStaffMembers.first,
    );
  }

  void _updateCurrentStep() {
    int newIndex = _pageController.page?.round() ?? 0;
    if (newIndex != _currentStepIndex) {
      setState(() {
        _currentStepIndex = newIndex;
      });
    }
  }

  // --- Setters (used by other pages to update state) ---
  void _setTherapist(StaffMember? member) =>
      setState(() => _selectedStaff = member);
  void _setSelectedDate(DateTime date) => setState(() => _selectedDate = date);
  void _setStartTimeHour(int hour) => setState(() => _startTimeHour = hour);
  void _setDuration(int hr, int min) => setState(() {
    _durationHour = hr;
    _durationMinute = min;
  });
  void _setTimePeriod(String period) => setState(() => _timePeriod = period);
  void _setPersonCount(String count) => setState(() => _personCount = count);

  // --- Price Calculation for Page 3 ---
  double _calculateTotalPrice() {
    double addonsCost = 0.0;
    _selectedAddons.forEach((addon, isSelected) {
      if (isSelected) {
        addonsCost += _addonPrices[addon]!.toDouble();
      }
    });
    return _baseServicePrice + addonsCost + _taxAndFees;
  }

  @override
  void dispose() {
    _pageController.removeListener(_updateCurrentStep);
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    if (_currentStepIndex < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeIn,
      );
    } else {
      // FINAL ACTION: Navigate to the success screen when 'Confirm' is pressed
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const BookingSuccessPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String buttonText = _currentStepIndex == _totalSteps - 1
        ? "Confirm"
        : "Next";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Booking",
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            if (_currentStepIndex > 0) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: _buildProgressIndicator(),
          ),

          Expanded(
            child: PageView(
              controller: _pageController,
              // Disable swiping to force navigation via buttons/logic
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Step 0: Book
                _buildBookingStepContent(),

                // Step 1: Booking Info (Page Two)
                BookingPageTwo(
                  booking: widget.booking,
                  allStaffMembers: allStaffMembers,
                  selectedTherapist: _selectedStaff,
                  onTherapistSelected: _setTherapist,
                  selectedDate: _selectedDate,
                  onDateSelected: _setSelectedDate,
                  startTimeHour: _startTimeHour,
                  onStartTimeHourChanged: _setStartTimeHour,
                  durationHour: _durationHour,
                  durationMinute: _durationMinute,
                  onDurationChanged: _setDuration,
                  timePeriod: _timePeriod,
                  onTimePeriodChanged: _setTimePeriod,
                  // onPersonCountChanged: _setPersonCount, // This might be needed on PageTwo
                ),

                // Step 2: Checkout (Page Three - Final Content Step)
                BookingPageThree(
                  booking: widget.booking,
                  basePrice: _baseServicePrice,
                  totalPrice: _calculateTotalPrice(),
                  selectedAddons: _selectedAddons,
                  addonPrices: _addonPrices,
                  selectedTherapist: _selectedStaff,
                  selectedDate: _selectedDate,
                  startTimeHour: _startTimeHour,
                  timePeriod: _timePeriod,
                  durationHour: _durationHour,
                  durationMinute: _durationMinute,
                  personCount: _personCount, // Passed data
                ),
              ],
            ),
          ),

          // 3. Fixed Bottom Button
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 3.h),
            child: SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                onPressed: _goToNextStep,
                child: Text(
                  buttonText,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Progress Indicator ---
  Widget _buildProgressIndicator() {
    final steps = ["Book", "Booking Info", "Checkout"];

    return Row(
      children: List.generate(steps.length, (index) {
        final isCompleted = index < _currentStepIndex;
        final isActive = index == _currentStepIndex;

        final color = isCompleted || isActive
            ? AppColors.primary
            : AppColors.secondary.withOpacity(0.5);

        return Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (index > 0)
                    Expanded(
                      child: Container(height: 0.3.h, color: color),
                    ),
                  Container(
                    width: 3.5.h,
                    height: 3.5.h,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color,
                        width: isActive ? 2.0 : 1.0,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 20,
                              color: Colors.white,
                            )
                          : isActive
                          ? Text(
                              (index + 1).toString(),
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                  if (index < steps.length - 1)
                    Expanded(
                      child: Container(
                        height: 0.3.h,
                        color: isCompleted
                            ? AppColors.primary
                            : AppColors.secondary.withOpacity(0.5),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 1.h),

              Text(
                steps[index],
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: color,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // --- Step 0: Book Content (Service, Staff, Add-ons) ---
  Widget _buildBookingStepContent() {
    final booking = widget.booking;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServiceCard(booking),
          SizedBox(height: 3.h),
          _buildStaffSection(),
          SizedBox(height: 3.h),
          _buildAddOnsSection(),
          // Add padding for the fixed bottom button clearance
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Booking booking) {
    return Container(
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            child: Image.asset(
              booking.imageUrl,
              height: 20.h,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                    color: AppColors.textPrimary,
                  ),
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
                      booking.location,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.8.h),
                Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.warning, size: 18),
                    SizedBox(width: 1.w),
                    Text(
                      "${booking.rating} (320)",
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  booking.description,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffSection() {
    final staff = allStaffMembers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Staff Members",
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 15.sp,
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigation to full staff list
              },
              child: Text(
                "See All",
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.5.h),
        SizedBox(
          height: 10.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: staff.length,
            separatorBuilder: (_, __) => SizedBox(width: 4.w),
            itemBuilder: (context, index) {
              final member = staff[index];
              final isSelected = _selectedStaff?.name == member.name;

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedStaff = member);

                  // Navigate to staff details page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // Uses the StaffDetailsScreen from the staff_details_page.dart file
                      builder: (context) => StaffDetailsScreen(staff: member),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 3.h,
                          backgroundImage: AssetImage(member.imageUrl),
                        ),
                        if (isSelected)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 1.5.h,
                              height: 1.5.h,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.background,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 0.8.h),
                    Text(
                      member.name.split(' ').first,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
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

  Widget _buildAddOnsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Add-ons",
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 15.sp,
          ),
        ),
        SizedBox(height: 2.h),
        ..._selectedAddons.entries.map((entry) {
          final price = _addonPrices[entry.key]!;
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 0.8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.key,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "\$$price",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    SizedBox(
                      width: 3.h,
                      height: 3.h,
                      child: Checkbox(
                        value: entry.value,
                        onChanged: (val) {
                          setState(() {
                            _selectedAddons[entry.key] = val!;
                          });
                        },
                        activeColor: AppColors.primary,
                        checkColor: AppColors.secondary,
                        side: const BorderSide(color: AppColors.textSecondary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
