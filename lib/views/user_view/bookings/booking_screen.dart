import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recoverylab_front/views/user_view/bookings/booking_page_one.dart';
import 'package:sizer/sizer.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/views/user_view/bookings/widget/booking_card.dart';
import 'package:recoverylab_front/models/booking_model.dart'; // 🔑 Refactored Import

// 🔑 MOCK DATA UPDATED with a unique ID and using the shared model
List<Booking> mockBookingsData = [
  // Upcoming
  Booking(
    id: 'b1',
    title: 'Zen Garden Spa & Retreat',
    location: 'Sheikh Zayed',
    date: 'Jun 6, 2025',
    time: '10:00 am',
    duration: '1:00 hour',
    rating: 4.8,
    imageUrl: 'lib/assets/images/spa.jpg',
    status: BookingStatus.upcoming,
    description:
        "Experience pure tranquility at Zen Garden Spa, famous for its soothing steam rooms and natural remedies. The perfect escape.",
  ),
  Booking(
    id: 'b2',
    title: 'Tranquil Garden Massage',
    location: 'New Cairo',
    date: 'Jun 6, 2025',
    time: '10:00 am',
    duration: '1:00 hour',
    rating: 4.8,
    imageUrl: 'lib/assets/images/massage.jpg',
    status: BookingStatus.upcoming,
    description:
        "Book a relaxing full-body Swedish massage in a private, tranquil garden setting.",
  ),
  // Completed
  Booking(
    id: 'b3',
    title: 'Zen Garden Spa & Retreat',
    location: 'Sheikh Zayed',
    date: 'May 1, 2025',
    time: '10:00 am',
    duration: '1:00 hour',
    rating: 4.8,
    imageUrl: 'lib/assets/images/spa.jpg',
    status: BookingStatus.completed,
    description:
        "A past visit to the renowned Zen Garden Spa. Highly rated by users.",
  ),
  // Cancelled
  Booking(
    id: 'b4',
    title: 'Golden Glow IV Lounge',
    location: 'Sheikh Zayed',
    date: 'Apr 10, 2025',
    time: '1:00 pm',
    duration: '1:00 hour',
    rating: 4.8,
    imageUrl: 'lib/assets/images/haven.jpg',
    status: BookingStatus.cancelled,
    description:
        "IV Drip session was cancelled. You can easily reschedule via the Book Again button.",
  ),
];

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String selectedTab = 'Upcoming';
  // 🔑 Use a mutable list for state
  List<Booking> _bookings = mockBookingsData;

  @override
  Widget build(BuildContext context) {
    final Map<String, Widget> tabViews = {
      'Upcoming': _buildBookingList(BookingStatus.upcoming),
      'Completed': _buildBookingList(BookingStatus.completed),
      'Cancelled': _buildBookingList(BookingStatus.cancelled),
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "Bookings",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          // Custom Tab Buttons Row (The segmented control)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTabButton('Upcoming'),
                  _buildTabButton('Completed'),
                  _buildTabButton('Cancelled'),
                ],
              ),
            ),
          ),

          // Active tab content
          Expanded(child: tabViews[selectedTab]!),
        ],
      ),
    );
  }

  // 🔑 NEW: Function to handle the cancellation logic
  void _cancelAppointment(Booking booking) {
    setState(() {
      // 1. Remove the old booking (by ID)
      _bookings.removeWhere((b) => b.id == booking.id);

      // 2. Create a new copy with the Cancelled status
      final cancelledBooking = booking.copyWith(
        status: BookingStatus.cancelled,
      );

      // 3. Add the cancelled booking to the list
      _bookings.add(cancelledBooking);

      // 4. Switch the view to the Cancelled tab
      selectedTab = 'Cancelled';
    });
    // Close the dialog after cancellation
    Navigator.pop(context);
  }

  // 🔑 NEW: Function to show the confirmation dialog
  void _showCancelConfirmationDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: EdgeInsets.fromLTRB(20, 20, 20, 10),
          contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 20),
          title: Text(
            "Cancel Appointment",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            "Are you sure you want to cancel your appointment for "
            "${booking.title} on ${booking.date} at ${booking.time}?",
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              child: Text(
                "Keep",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 13.sp,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _cancelAppointment(booking),
              child: Text(
                "Cancel Appointment",
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Build individual booking list per tab
  Widget _buildBookingList(BookingStatus status) {
    final filteredBookings = _bookings
        .where((b) => b.status == status)
        .toList();

    if (filteredBookings.isEmpty) {
      return Center(
        child: Text(
          "No ${status.name} bookings",
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: AppColors.textPrimary.withOpacity(0.6),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      itemCount: filteredBookings.length,
      itemBuilder: (context, index) {
        final booking = filteredBookings[index];

        // Determine the action based on the tab/status
        VoidCallback primaryAction;
        if (booking.status == BookingStatus.upcoming) {
          // If Upcoming, the primary action (Manage) is to open the cancel dialog
          primaryAction = () => _showCancelConfirmationDialog(booking);
        } else {
          // If Completed or Cancelled, the primary action (Book Again) is to navigate
          primaryAction = () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingPageOne(booking: booking),
              ),
            );
          };
        }

        return BookingCard(
          booking: booking,
          viewStatus: status,
          onPrimaryActionPressed: primaryAction,
        );
      },
    );
  }

  // Custom pill button (The segmented control segment)
  Widget _buildTabButton(String tabName) {
    final isSelected = selectedTab == tabName;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = tabName;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.2.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.textPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Text(
            tabName,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? AppColors.background : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
