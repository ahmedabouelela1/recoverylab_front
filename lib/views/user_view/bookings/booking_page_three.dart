import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/models/booking_model.dart';
import 'package:recoverylab_front/models/staff_member_model.dart';

class BookingPageThree extends StatelessWidget {
  // Service Data
  final Booking booking;

  // Price Data
  final double basePrice;
  final double totalPrice;
  final Map<String, bool> selectedAddons;
  final Map<String, int> addonPrices;

  // Booking Info
  final StaffMember? selectedTherapist;
  final DateTime selectedDate;
  final int startTimeHour;
  final String timePeriod;
  final int durationHour;
  final int durationMinute;
  final String personCount; // Receives data from Page One

  // Mock data to complete the view
  final String packageName = "Combo";
  final double taxAndFees = 14.80;

  const BookingPageThree({
    super.key,
    required this.booking,
    required this.basePrice,
    required this.totalPrice,
    required this.selectedAddons,
    required this.addonPrices,
    required this.selectedTherapist,
    required this.selectedDate,
    required this.startTimeHour,
    required this.timePeriod,
    required this.durationHour,
    required this.durationMinute,
    required this.personCount,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServiceHeader(),
          SizedBox(height: 3.h),

          _buildBookingDetailsCard(),
          SizedBox(height: 3.h),

          _buildTherapistSection(),
          SizedBox(height: 3.h),

          _buildPriceDetailsCard(),
          SizedBox(height: 3.h),

          // ⭐ PROMOCODE SECTION
          _buildPromocodeSection(context),
          SizedBox(height: 3.h),

          _buildPaymentMethodSection(),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  // --- UI Building Blocks ---

  Widget _buildServiceHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            booking.imageUrl,
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
              Text(
                booking.title,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
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
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Icon(Icons.check_box, color: AppColors.primary, size: 24),
      ],
    );
  }

  Widget _buildTherapistSection() {
    final selected = selectedTherapist;
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
        Container(
          padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 4.w),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
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
              Container(
                width: 1.5.h,
                height: 1.5.h,
                decoration: const BoxDecoration(
                  color: Colors.lightGreen,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingDetailsCard() {
    final List<Map<String, String>> details = [
      {"label": "Package", "value": packageName},
      {"label": "Person", "value": personCount},
      {
        "label": "Date",
        "value":
            "${_getMonthName(selectedDate.month)} ${selectedDate.day}, ${selectedDate.year}",
      },
      {
        "label": "Time",
        "value":
            "${startTimeHour.toString().padLeft(2, '0')}:00 ${timePeriod.toUpperCase()}",
      },
      {
        "label": "Duration",
        "value": durationHour == 0
            ? "$durationMinute minute"
            : "$durationHour hour",
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your booking",
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 15.sp,
          ),
        ),
        SizedBox(height: 1.5.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: details.map((detail) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 0.8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      detail["label"]!,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      detail["value"]!,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceDetailsCard() {
    double totalAddonsCost = 0;
    selectedAddons.forEach((addon, isSelected) {
      if (isSelected) {
        totalAddonsCost += addonPrices[addon]!.toDouble();
      }
    });

    final List<Map<String, dynamic>> priceItems = [
      {"label": "Package", "value": basePrice, "isTotal": false},
      {"label": "Add-ons", "value": totalAddonsCost, "isTotal": false},
      {"label": "Wallet", "value": 0.0, "isTotal": false},
      {"label": "Tax & Fees", "value": taxAndFees, "isTotal": false},
      {"label": "", "value": "", "isDivider": true},
      {"label": "Total price", "value": totalPrice, "isTotal": true},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Booking Price Details",
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 15.sp,
          ),
        ),
        SizedBox(height: 1.5.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: priceItems.map((item) {
              if (item["isDivider"] == true) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.5.h),
                  child: Divider(
                    color: AppColors.textSecondary.withOpacity(0.2),
                    height: 1.0,
                  ),
                );
              }

              bool isTotal = item["isTotal"] as bool;
              String formattedValue = item["label"] == "Wallet"
                  ? "\$0"
                  : "\$${(item["value"] as double).toStringAsFixed(2)}";

              if (item["value"] == 0.0 &&
                  item["label"] != "Wallet" &&
                  item["label"] != "Add-ons") {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 0.8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item["label"] as String,
                      style: GoogleFonts.inter(
                        fontSize: isTotal ? 16.sp : 14.sp,
                        color: isTotal
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    Text(
                      formattedValue,
                      style: GoogleFonts.inter(
                        fontSize: isTotal ? 16.sp : 14.sp,
                        color: isTotal
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ⭐ Promocode Section
  Widget _buildPromocodeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Promocode",
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
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Enter promocode",
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary.withOpacity(0.6),
                    ),
                    border: InputBorder.none,
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Promocode applied (simulated)'),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size(15.w, 4.h),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  "Apply",
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Choose payment method",
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 15.sp,
          ),
        ),
        SizedBox(height: 1.5.h),
        _buildPaymentCard(lastFour: "5656", isSelected: true),
        _buildPaymentCard(lastFour: "1234", isSelected: false),
        _buildPaymentCard(lastFour: "4887", isSelected: false),
        SizedBox(height: 2.h),
        _buildAddNewPaymentButton(),
      ],
    );
  }

  Widget _buildPaymentCard({
    required String lastFour,
    required bool isSelected,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.5.h),
      padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.credit_card, color: AppColors.textPrimary, size: 24),
          SizedBox(width: 4.w),
          Text(
            "**** $lastFour",
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Container(
            width: 2.5.h,
            height: 2.5.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 1.2.h,
                      height: 1.2.h,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildAddNewPaymentButton() {
    return Container(
      height: 6.h,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: AppColors.textPrimary, size: 24),
            SizedBox(width: 2.w),
            Text(
              "Add new payment method",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
