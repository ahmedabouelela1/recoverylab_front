import 'dart:math' show min;

import 'package:dropdown_flutter/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recoverylab_front/configurations/app_dropdown_decorations.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/models/Branch/branch/branch_schedule.dart';
import 'package:recoverylab_front/models/Branch/branch/branch.dart';
import 'package:recoverylab_front/models/Branch/services/service.dart';
import 'package:recoverylab_front/models/Offer/offer_package.dart';
import 'package:recoverylab_front/models/Offer/package_rule.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/exception/snack_bar.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:recoverylab_front/views/user_view/bookings/booking_success_page.dart';
import 'package:recoverylab_front/models/User/user_points.dart';
import 'package:recoverylab_front/providers/session/active_offer_provider.dart';
import 'package:recoverylab_front/providers/session/branch_provider.dart';
import 'package:recoverylab_front/providers/session/user_session_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:solar_icons/solar_icons.dart';

class ComboBookingScreen extends ConsumerStatefulWidget {
  final int comboId;
  final String comboName;
  final String price;
  final String totalDuration;
  final List<Map<String, String>> inclusions;

  /// When provided, category-based rules will show a service picker per slot.
  final OfferPackage? combo;

  const ComboBookingScreen({
    required this.comboId,
    required this.comboName,
    required this.price,
    required this.totalDuration,
    required this.inclusions,
    this.combo,
    super.key,
  });

  @override
  ConsumerState<ComboBookingScreen> createState() => _ComboBookingScreenState();
}

class _ComboBookingScreenState extends ConsumerState<ComboBookingScreen> {
  Branch? _selectedBranch;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _participantCount = 1;
  String _notes = '';
  bool _isLoading = false;
  BranchSchedule? _schedule;

  /// For category-based rules: ruleId -> chosen serviceId.
  final Map<int, int> _serviceChoices = {};
  /// categoryId -> list of services (loaded once per category).
  final Map<int, List<Service>> _servicesByCategory = {};
  bool _loadingServices = false;
  final String _paymentMethod = 'ONLINE';
  bool _redeemPoints = false;
  UserPoints? _userPoints;

  Future<void> _loadPoints() async {
    try {
      final pts = await ref.read(apiProvider).getMyPoints();
      if (mounted) setState(() => _userPoints = pts);
    } catch (_) {}
  }

  double get _comboBasePrice =>
      double.tryParse(widget.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

  double get _comboDisplayTotal {
    var total = _comboBasePrice;
    final offer = ref.read(activeOfferProvider);
    final branchId = _selectedBranch?.id;
    if (offer != null &&
        offer.appliesToCombo(comboId: widget.comboId, branchId: branchId)) {
      total = offer.applyDiscountToAmount(total);
    }
    if (_redeemPoints && _userPoints != null && _userPoints!.redeemableNow > 0) {
      final cappedPoints = min(_userPoints!.redeemableNow, (total * 100).floor());
      final discount = cappedPoints / 100.0;
      total = (total - discount).clamp(0, total);
    }
    return total;
  }

  /// Parse totalDuration string (e.g. "150 min" or "2h 30min") to total minutes.
  int get _totalDurationMinutes {
    final s = widget.totalDuration.trim();
    // "150 min" or "90 min"
    final minMatch = RegExp(r'(\d+)\s*min').firstMatch(s);
    if (minMatch != null) return int.tryParse(minMatch.group(1) ?? '') ?? 90;
    // "2h 30min" style
    final hMatch = RegExp(r'(\d+)\s*h').firstMatch(s);
    final mMatch = RegExp(r'(\d+)\s*m').firstMatch(s);
    final h = hMatch != null ? int.tryParse(hMatch.group(1) ?? '') ?? 0 : 0;
    final m = mMatch != null ? int.tryParse(mMatch.group(1) ?? '') ?? 0 : 0;
    return h * 60 + m;
  }

  Future<void> _loadSchedule() async {
    if (_selectedBranch == null || _selectedDate == null) return;
    try {
      final schedule = await ref.read(apiProvider).getBranchSchedule(_selectedBranch!.id);
      if (mounted) setState(() => _schedule = schedule);
    } catch (_) {
      if (mounted) setState(() => _schedule = null);
    }
  }

  List<PackageRule> get _categoryChoiceRules =>
      widget.combo?.rules.where((r) => r.isCategoryChoice).toList() ?? [];

  Set<int> get _excludedServiceIds =>
      widget.combo?.excludedServiceIds.toSet() ?? {};

  List<Service> _allowedServices(List<Service> all) =>
      all.where((s) => !_excludedServiceIds.contains(s.id)).toList();

  Future<void> _loadServicesForCategory(int categoryId) async {
    if (_servicesByCategory.containsKey(categoryId)) return;
    setState(() => _loadingServices = true);
    try {
      final list = await ref.read(apiProvider).getServicesByCategory(categoryId);
      if (mounted) {
        setState(() {
          _servicesByCategory[categoryId] = list.whereType<Service>().toList();
          for (final rule in _categoryChoiceRules) {
            if (rule.serviceCategoryId == categoryId) {
              final chosen = _serviceChoices[rule.id];
              if (chosen != null && _excludedServiceIds.contains(chosen)) {
                _serviceChoices.remove(rule.id);
              }
            }
          }
          _loadingServices = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingServices = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPoints();
    final branches = ref.read(branchesProvider);
    final user = ref.read(userSessionProvider).user;
    if (branches.isNotEmpty) {
      _selectedBranch = branches.firstWhere(
        (b) => b.id == user?.branchId,
        orElse: () => branches.first,
      );
    }
    for (final rule in _categoryChoiceRules) {
      if (rule.serviceCategoryId != null) {
        _loadServicesForCategory(rule.serviceCategoryId!);
      }
    }
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
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadSchedule();
    }
  }

  Future<void> _pickTime() async {
    final date = _selectedDate;
    final branch = _selectedBranch;
    if (date == null || branch == null) {
      AppSnackBar.show(context, 'Please select date and branch first.');
      return;
    }
    await _loadSchedule();
    if (!mounted) return;
    final schedule = _schedule;
    final slots = schedule?.slotsFor(date);
    final totalMin = _totalDurationMinutes;
    final durationHours = (totalMin / 60).ceil();
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;

    if (schedule != null) {
      if (slots == null || slots.isEmpty) {
        AppSnackBar.show(
          context,
          schedule.specialDateFor(date)?.reason ?? 'Branch is closed on this date.',
        );
        return;
      }
      final closeHour = slots.last + 1;
      final validStartHours = slots
          .where((hour) => hour + durationHours <= closeHour)
          .where((hour) => !isToday || hour > now.hour)
          .toList();
      if (validStartHours.isEmpty) {
        AppSnackBar.show(
          context,
          schedule.specialDateFor(date)?.reason ?? 'No time slots available for this date (combo would end after branch closing).',
        );
        return;
      }
      showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.cardBackground,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (ctx) => Padding(
          padding: EdgeInsets.only(
            left: 4.w,
            right: 4.w,
            top: 3.w,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 4.w,
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
              SizedBox(height: 2.h),
              Text(
                'SELECT START TIME',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'Combo must end by branch closing time',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 11.sp),
              ),
              SizedBox(height: 2.h),
              Wrap(
                spacing: 2.w,
                runSpacing: 1.5.h,
                children: validStartHours.map((hour) {
                  final isSelected = _selectedTime?.hour == hour;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedTime = TimeOfDay(hour: hour, minute: 0));
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.info.withOpacity(0.15) : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.info : AppColors.dividerColor,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        _formatHour(hour),
                        style: TextStyle(
                          color: isSelected ? AppColors.info : AppColors.textPrimary,
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
        ),
      );
      return;
    }

    // No schedule: use system time picker (backend will validate)
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 10, minute: 0),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.info,
            onPrimary: AppColors.secondary,
          ),
          dialogBackgroundColor: AppColors.background,
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  String _formatHour(int hour) {
    final period = hour < 12 ? 'AM' : 'PM';
    final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$h:00 $period';
  }

  BookingSuccessArgs _buildSuccessArgs() {
    String? dateTimeLabel;
    if (_selectedDate != null && _selectedTime != null) {
      final d = _selectedDate!;
      final t = _selectedTime!;
      final hour = t.hour.toString().padLeft(2, '0');
      final minute = t.minute.toString().padLeft(2, '0');
      dateTimeLabel = '${d.day}/${d.month}/${d.year} at $hour:$minute';
    }
    return BookingSuccessArgs(
      serviceName: widget.comboName,
      dateTimeLabel: dateTimeLabel,
    );
  }

  Future<void> _book() async {
    if (_selectedDate == null || _selectedTime == null) {
      AppSnackBar.show(context, 'Please select a date and time.');
      return;
    }
    if (_selectedBranch == null) {
      AppSnackBar.show(context, 'No branch available.');
      return;
    }
    final user = ref.read(userSessionProvider).user;
    if (user == null) {
      AppSnackBar.show(context, 'Please log in to continue.');
      return;
    }
    final categoryRules = _categoryChoiceRules;
    if (categoryRules.isNotEmpty) {
      for (final rule in categoryRules) {
        if (!_serviceChoices.containsKey(rule.id) || _serviceChoices[rule.id]! == 0) {
          AppSnackBar.show(
            context,
            'Please choose a service for "${rule.serviceCategoryName ?? 'category'}"',
          );
          return;
        }
      }
    }

    final scheduled = _formatDateTime()!;
    setState(() => _isLoading = true);

    try {
      final activeOffer = ref.read(activeOfferProvider);
      final offerId = (activeOffer != null &&
              activeOffer.appliesToCombo(
                comboId: widget.comboId,
                branchId: _selectedBranch!.id,
              ))
          ? activeOffer.id
          : null;

      final response = await ref.read(apiProvider).storeComboBooking(
            comboId: widget.comboId,
            userId: user.id,
            branchId: _selectedBranch!.id,
            scheduledStart: scheduled,
            participantCount: _participantCount,
            notes: _notes.isEmpty ? null : _notes,
            serviceChoices: _serviceChoices.isEmpty ? null : _serviceChoices,
            paymentMethod: _paymentMethod,
            redeemPoints: _redeemPoints,
            offerId: offerId,
          );
      ref.read(activeOfferProvider.notifier).clear();

      if (!mounted) return;

      if (_paymentMethod == 'ONLINE') {
        final data = response['data'] as Map<String, dynamic>?;
        final rawId = data?['id'] ?? data?['booking_id'];
        if (rawId != null) {
          try {
            final bookingId = rawId is int ? rawId : int.parse(rawId.toString());
            final payResult = await ref.read(apiProvider).initiatePayment(bookingId);
            if (!mounted) return;
            final payData = payResult['data'] as Map<String, dynamic>?;
            if (payData?['already_paid'] == true) {
              Navigator.pushReplacementNamed(
                context,
                Routes.paymentStatus,
                arguments: {'isSuccess': true, 'bookingId': bookingId},
              );
              return;
            }
            final checkoutUrl = payData?['checkout_url'] as String?;
            if (checkoutUrl == null || checkoutUrl.isEmpty) {
              Navigator.pushReplacementNamed(
                context,
                Routes.bookingSuccessPage,
                arguments: _buildSuccessArgs(),
              );
              return;
            }
            Navigator.pushReplacementNamed(
              context,
              Routes.paymentScreen,
              arguments: {
                'checkoutUrl': checkoutUrl,
                'bookingId': bookingId,
              },
            );
            return;
          } catch (_) {
            if (mounted) {
              AppSnackBar.show(
                context,
                'Payment initiation failed. Your booking is saved — you can pay at the branch.',
              );
            }
          }
        }
      }

      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.bookingSuccessPage,
        (route) => route.settings.name == Routes.navbar,
        arguments: _buildSuccessArgs(),
      );
    } catch (e) {
      if (mounted) AppSnackBar.show(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final branches = ref.watch(branchesProvider);
    if (_selectedBranch == null && branches.isNotEmpty) {
      final user = ref.read(userSessionProvider).user;
      _selectedBranch = branches.firstWhere(
        (b) => b.id == user?.branchId,
        orElse: () => branches.first,
      );
    }

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
                  _detailRow(Icons.spa_outlined, 'Combo', widget.comboName),
                  _divider(),
                  _detailRow(
                      SolarIconsOutline.clockCircle, 'Duration', widget.totalDuration),
                  _divider(),
                  _detailRow(SolarIconsOutline.wallet, 'Price', 'EGP ${widget.price}'),
                ],
              ),
            ),
            SizedBox(height: 2.h),

            // Branch selector (same as settings)
            _label('YOUR BRANCH'),
            SizedBox(height: 1.2.h),
            _buildBranchSelector(branches),
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
                          Icon(SolarIconsOutline.calendar,
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
                          Icon(SolarIconsOutline.clockCircle,
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
                border: Border.all(color: AppColors.dividerColor, width: 0.8),
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
                    border: Border.all(color: AppColors.dividerColor, width: 0.8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.spa_outlined,
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

            // Category-based service pickers
            if (_categoryChoiceRules.isNotEmpty) ...[
              SizedBox(height: 2.h),
              _label('CHOOSE SERVICES'),
              SizedBox(height: 1.h),
              Text(
                'Select one service per slot from the category.',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12.sp,
                ),
              ),
              if (_excludedServiceIds.isNotEmpty) ...[
                SizedBox(height: 0.8.h),
                Text(
                  'Some services are not available for this combo.',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11.sp,
                  ),
                ),
              ],
              SizedBox(height: 1.h),
              ..._categoryChoiceRules.map((rule) {
                final catId = rule.serviceCategoryId!;
                final services = _servicesByCategory[catId] ?? [];
                final allowed = _allowedServices(services);
                final selectedId = _serviceChoices[rule.id];
                final validSelected = selectedId != null &&
                        allowed.any((s) => s.id == selectedId)
                    ? selectedId
                    : null;
                return Container(
                  margin: EdgeInsets.only(bottom: 1.5.h),
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.dividerColor, width: 0.8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${rule.serviceCategoryName ?? "Category"} — ${rule.durationMinutes} min',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.8.h),
                      if (_loadingServices && services.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 1.h),
                          child: SizedBox(
                            width: 20.w,
                            height: 2.h,
                            child: const LinearProgressIndicator(),
                          ),
                        )
                      else if (allowed.isEmpty)
                        Text(
                          'No services in this category.',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12.sp,
                          ),
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: DropdownFlutter<Service>(
                            key: ValueKey<int>(rule.id),
                            items: allowed,
                            initialItem: validSelected == null
                                ? null
                                : () {
                                    for (final s in allowed) {
                                      if (s.id == validSelected) return s;
                                    }
                                    return null;
                                  }(),
                            hintText: 'Select service',
                            excludeSelected: false,
                            validateOnChange: false,
                            closedHeaderPadding: EdgeInsets.symmetric(
                              horizontal: 3.w,
                              vertical: 1.2.h,
                            ),
                            decoration: AppDropdownDecorations.cardInline(),
                            onChanged: (s) {
                              if (s != null) {
                                setState(() => _serviceChoices[rule.id] = s.id);
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                );
              }),
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
              top: BorderSide(color: AppColors.dividerColor, width: 0.8)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Builder(
              builder: (context) {
                final offer = ref.watch(activeOfferProvider);
                if (offer == null ||
                    !offer.appliesToCombo(
                      comboId: widget.comboId,
                      branchId: _selectedBranch?.id,
                    )) {
                  return const SizedBox.shrink();
                }
                final badge = offer.discountBadge;
                if (badge == null) return const SizedBox.shrink();
                return Padding(
                  padding: EdgeInsets.only(bottom: 1.h),
                  child: Row(
                    children: [
                      Icon(SolarIconsBold.tag, size: 16.sp, color: AppColors.primary),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          '${offer.title} — $badge',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            ref.read(activeOfferProvider.notifier).clear(),
                        child: Icon(Icons.close, size: 16.sp),
                      ),
                    ],
                  ),
                );
              },
            ),
            Builder(builder: (_) {
              if (_userPoints == null) return const SizedBox.shrink();
              final cappedPoints =
                  min(_userPoints!.redeemableNow, (_comboBasePrice * 100).floor());
              if (cappedPoints <= 0) return const SizedBox.shrink();
              final cappedEgp = cappedPoints / 100.0;
              return Padding(
                padding: EdgeInsets.only(bottom: 1.h),
                child: GestureDetector(
                  onTap: () => setState(() => _redeemPoints = !_redeemPoints),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: _redeemPoints
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
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
                          size: 16.sp,
                          color: _redeemPoints
                              ? AppColors.primary
                              : AppColors.textTertiary,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            'Use $cappedPoints points '
                            '(−${cappedEgp.toStringAsFixed(2)} EGP)',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: _redeemPoints
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Icon(
                          _redeemPoints
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: AppColors.primary,
                          size: 18.sp,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            SizedBox(height: 1.5.h),
            ElevatedButton(
              onPressed: _isLoading ? null : _book,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info,
                foregroundColor: AppColors.secondary,
                minimumSize: Size(double.infinity, 6.h),
                padding: EdgeInsets.symmetric(vertical: 2.h),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                _isLoading
                    ? 'Booking…'
                    : 'Confirm Booking — EGP ${_comboDisplayTotal.toStringAsFixed(_comboDisplayTotal % 1 == 0 ? 0 : 2)}',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ],
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
        border: Border.all(color: AppColors.dividerColor, width: 0.8),
      ),
      child: child,
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12.sp,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    );
  }

  /// Branch selector — same as settings page.
  Widget _buildBranchSelector(List<Branch?> branches) {
    if (branches.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dividerColor, width: 0.8),
        ),
        child: Row(
          children: [
            Icon(
              SolarIconsOutline.mapPoint,
              color: AppColors.textTertiary,
              size: 16.sp,
            ),
            SizedBox(width: 3.w),
            Text(
              'Loading branches...',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 13.sp),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info, width: 1),
      ),
      child: Builder(
        builder: (context) {
          final branchItems = branches.whereType<Branch>().toList();
          final selected = _selectedBranch != null &&
                  branchItems.any((b) => b.id == _selectedBranch!.id)
              ? _selectedBranch
              : null;
          return SizedBox(
            width: double.infinity,
            child: DropdownFlutter<Branch>(
              key: ValueKey<int?>(selected?.id),
              items: branchItems,
              initialItem: selected,
              hintText: 'Select branch',
              excludeSelected: false,
              validateOnChange: false,
              closedHeaderPadding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 0.8.h,
              ),
              decoration: AppDropdownDecorations.branchSelector(),
              headerBuilder: (context, branch, enabled) {
                return Row(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        SolarIconsOutline.mapPoint,
                        size: 14.sp,
                        color: AppColors.info,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            branch.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            branch.address,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              listItemBuilder: (context, branch, isSelected, onItemSelect) {
                return Row(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        SolarIconsOutline.mapPoint,
                        size: 14.sp,
                        color: AppColors.info,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            branch.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            branch.address,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              onChanged: (Branch? val) {
                if (val != null) {
                  setState(() => _selectedBranch = val);
                  _loadSchedule();
                }
              },
            ),
          );
        },
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
          color: AppColors.info.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 14.sp,
          color: AppColors.info
          //  onTap != null
              // ? AppColors.primary
              // : AppColors.textTertiary,
        ),
      ),
    );
  }
}
