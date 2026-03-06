import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/models/Branch/branch/branch.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/exception/snack_bar.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:recoverylab_front/providers/session/branch_provider.dart';
import 'package:recoverylab_front/providers/session/user_session_provider.dart';
import 'package:sizer/sizer.dart';

class ComboBookingScreen extends ConsumerStatefulWidget {
  final int comboId;
  final String comboName;
  final String price;
  final String totalDuration;
  final List<Map<String, String>> inclusions;

  const ComboBookingScreen({
    required this.comboId,
    required this.comboName,
    required this.price,
    required this.totalDuration,
    required this.inclusions,
    super.key,
  });

  @override
  ConsumerState<ComboBookingScreen> createState() => _ComboBookingScreenState();
}

class _ComboBookingScreenState extends ConsumerState<ComboBookingScreen> {
  List<Branch?> _branches = [];
  int _selectedBranchIndex = 0;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _participantCount = 1;
  String _notes = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _branches = ref.read(branchesProvider);
    final user = ref.read(userSessionProvider).user;
    final idx = _branches.indexWhere((b) => b?.id == user?.branchId);
    _selectedBranchIndex = idx >= 0 ? idx : 0;
  }

  String? _formatDateTime() {
    if (_selectedDate == null || _selectedTime == null) return null;
    final dt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    return dt.toIso8601String().replaceFirst('T', ' ').substring(0, 19);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _book() async {
    if (_selectedDate == null || _selectedTime == null) {
      AppSnackBar.show(context, 'Please select a date and time.');
      return;
    }
    final branch = _branches.isNotEmpty ? _branches[_selectedBranchIndex] : null;
    if (branch == null) {
      AppSnackBar.show(context, 'No branch available.');
      return;
    }
    final user = ref.read(userSessionProvider).user;
    if (user == null) {
      AppSnackBar.show(context, 'Please log in to continue.');
      return;
    }

    final scheduled = _formatDateTime()!;
    setState(() => _isLoading = true);

    try {
      await ref.read(apiProvider).storeComboBooking(
            comboId: widget.comboId,
            userId: user.id,
            branchId: branch.id,
            scheduledStart: scheduled,
            participantCount: _participantCount,
            notes: _notes.isEmpty ? null : _notes,
          );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.bookingSuccessPage,
        (route) => route.settings.name == Routes.navbar,
      );
    } catch (e) {
      if (mounted) AppSnackBar.show(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Book ${widget.comboName}',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary card
            _sectionCard(
              child: Column(
                children: [
                  _detailRow(Icons.spa, 'Combo', widget.comboName),
                  _divider(),
                  _detailRow(
                      Icons.schedule, 'Duration', widget.totalDuration),
                  _divider(),
                  _detailRow(Icons.wallet, 'Price', 'EGP ${widget.price}'),
                ],
              ),
            ),
            SizedBox(height: 2.h),

            // Branch selector
            _label('BRANCH'),
            SizedBox(height: 1.h),
            if (_branches.isNotEmpty)
              _sectionCard(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedBranchIndex,
                    isExpanded: true,
                    dropdownColor: AppColors.cardBackground,
                    style: TextStyle(
                        color: AppColors.textPrimary, fontSize: 14.sp),
                    items: List.generate(
                      _branches.length,
                      (i) => DropdownMenuItem(
                        value: i,
                        child: Text(_branches[i]?.name ?? 'Branch $i'),
                      ),
                    ),
                    onChanged: (v) =>
                        setState(() => _selectedBranchIndex = v ?? 0),
                  ),
                ),
              ),
            SizedBox(height: 2.h),

            // Date & time
            _label('DATE & TIME'),
            SizedBox(height: 1.h),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: _sectionCard(
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              color: AppColors.textTertiary, size: 16.sp),
                          SizedBox(width: 3.w),
                          Text(
                            _selectedDate == null
                                ? 'Pick date'
                                : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                            style: TextStyle(
                              color: _selectedDate == null
                                  ? AppColors.textTertiary
                                  : AppColors.textPrimary,
                              fontSize: 14.sp,
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
                    onTap: _pickTime,
                    child: _sectionCard(
                      child: Row(
                        children: [
                          Icon(Icons.access_time,
                              color: AppColors.textTertiary, size: 16.sp),
                          SizedBox(width: 3.w),
                          Text(
                            _selectedTime == null
                                ? 'Pick time'
                                : _selectedTime!.format(context),
                            style: TextStyle(
                              color: _selectedTime == null
                                  ? AppColors.textTertiary
                                  : AppColors.textPrimary,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Participants
            _label('PARTICIPANTS'),
            SizedBox(height: 1.h),
            _sectionCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_participantCount person${_participantCount == 1 ? '' : 's'}',
                    style: TextStyle(
                        color: AppColors.textPrimary, fontSize: 14.sp),
                  ),
                  Row(
                    children: [
                      _counterBtn(
                        icon: Icons.remove,
                        onTap: _participantCount > 1
                            ? () =>
                                setState(() => _participantCount--)
                            : null,
                      ),
                      SizedBox(width: 4.w),
                      _counterBtn(
                        icon: Icons.add,
                        onTap: _participantCount < 10
                            ? () =>
                                setState(() => _participantCount++)
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),

            // Notes
            _label('NOTES (OPTIONAL)'),
            SizedBox(height: 1.h),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.dividerColor),
              ),
              child: TextField(
                style: TextStyle(
                    color: AppColors.textPrimary, fontSize: 14.sp),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Any special requests?',
                  hintStyle: TextStyle(
                      color: AppColors.textTertiary, fontSize: 13.sp),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(4.w),
                ),
                onChanged: (v) => _notes = v,
              ),
            ),

            // Included services
            if (widget.inclusions.isNotEmpty) ...[
              SizedBox(height: 2.h),
              _label("WHAT'S INCLUDED"),
              SizedBox(height: 1.h),
              ...widget.inclusions.map(
                (item) => Container(
                  margin: EdgeInsets.only(bottom: 1.h),
                  padding: EdgeInsets.symmetric(
                      horizontal: 4.w, vertical: 1.5.h),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.dividerColor),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.spa,
                          color: AppColors.info, size: 16.sp),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          item['name'] ?? '',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14.sp),
                        ),
                      ),
                      Text(
                        item['duration'] ?? '',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13.sp),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            SizedBox(height: 10.h),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border(
              top: BorderSide(color: AppColors.dividerColor, width: 0.5)),
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _book,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.secondary,
            padding: EdgeInsets.symmetric(vertical: 2.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            _isLoading ? 'Booking…' : 'Confirm Booking — EGP ${widget.price}',
            style:
                TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: child,
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11.sp,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.8.h),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textTertiary, size: 14.sp),
          SizedBox(width: 3.w),
          Text(label,
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 13.sp)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(height: 0.5, color: AppColors.dividerColor);

  Widget _counterBtn({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 8.w,
        height: 8.w,
        decoration: BoxDecoration(
          color: onTap != null
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 14.sp,
          color: onTap != null
              ? AppColors.primary
              : AppColors.textTertiary,
        ),
      ),
    );
  }
}
