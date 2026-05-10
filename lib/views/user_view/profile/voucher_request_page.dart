import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/models/Branch/branch/branch.dart';
import 'package:recoverylab_front/models/Branch/branchService/service_durations.dart';
import 'package:recoverylab_front/models/Branch/services/service.dart';
import 'package:recoverylab_front/models/Branch/services/service_category.dart';
import 'package:recoverylab_front/models/Offer/offer_package.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/exception/snack_bar.dart';
import 'package:recoverylab_front/providers/session/branch_provider.dart';
import 'package:recoverylab_front/providers/session/user_session_provider.dart';
import 'package:sizer/sizer.dart';

class VoucherRequestPage extends ConsumerStatefulWidget {
  const VoucherRequestPage({super.key});

  @override
  ConsumerState<VoucherRequestPage> createState() => _VoucherRequestPageState();
}

class _VoucherRequestPageState extends ConsumerState<VoucherRequestPage> {
  final _name = TextEditingController();
  final _message = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();

  List<Branch> _branches = [];
  int _branchIndex = 0;

  String _productType = 'SERVICE';

  List<ServiceCategory> _categories = [];
  int? _categoryId;
  List<Service> _services = [];
  int? _serviceId;
  List<int> _durations = [];
  int? _durationMinutes;

  List<OfferPackage> _comboPackages = [];
  List<OfferPackage> _creditPackages = [];
  int? _selectedPackageId;

  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _name.dispose();
    _message.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() => _loading = true);
    try {
      var branches = ref.read(branchesProvider);
      if (branches.isEmpty) {
        await ref.read(branchesProvider.notifier).ensureBranchesFetched();
        branches = ref.read(branchesProvider);
      }
      final user = ref.read(userSessionProvider).user;
      var idx = branches.indexWhere((b) => b.id == user?.branchId);
      if (idx < 0) idx = 0;

      final home = await ref.read(apiProvider).gethome();
      final data = home['data'] as Map<String, dynamic>? ?? {};
      final cats = (data['categories'] as List<ServiceCategory>?) ?? [];

      setState(() {
        _branches = branches;
        _branchIndex = idx >= 0 && idx < branches.length ? idx : 0;
        _categories = cats;
        _loading = false;
      });
      await _reloadCatalogForBranch();
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
        AppSnackBar.show(context, 'Failed to load form.');
      }
    }
  }

  int get _branchId => _branches.isEmpty ? 0 : _branches[_branchIndex].id;

  Future<void> _reloadCatalogForBranch() async {
    if (_branches.isEmpty) return;
    try {
      final combos = await ref.read(apiProvider).getPackages(type: 'COMBO', branchId: _branchId);
      final packs = await ref.read(apiProvider).getPackages(type: 'PACKAGE', branchId: _branchId);
      if (!mounted) return;
      setState(() {
        _comboPackages = combos;
        _creditPackages = packs;
        _selectedPackageId = null;
        _categoryId = null;
        _serviceId = null;
        _durationMinutes = null;
        _services = [];
        _durations = [];
      });
    } catch (_) {
      if (mounted) {
        AppSnackBar.show(context, 'Could not load packages for this branch.');
      }
    }
  }

  Future<void> _onCategoryChanged(int? id) async {
    setState(() {
      _categoryId = id;
      _serviceId = null;
      _durationMinutes = null;
      _services = [];
      _durations = [];
    });
    if (id == null) return;
    try {
      final list = await ref.read(apiProvider).getServicesByCategory(id);
      if (!mounted) return;
      setState(() => _services = list.whereType<Service>().toList());
    } catch (_) {
      if (mounted) AppSnackBar.show(context, 'Failed to load services.');
    }
  }

  Future<void> _onServiceChanged(int? id) async {
    setState(() {
      _serviceId = id;
      _durationMinutes = null;
      _durations = [];
    });
    if (id == null || _branches.isEmpty) return;
    try {
      final bs = await ref.read(apiProvider).getBranchService(branchId: _branchId, serviceId: id);
      if (!mounted) return;
      final List<ServiceDuration?> pricing =
          (bs != null && bs.data.isNotEmpty) ? bs.data.first.branchPricing : <ServiceDuration?>[];
      final durs = <int>[];
      for (final d in pricing) {
        final m = d?.minutes;
        if (m != null) durs.add(m);
      }
      setState(() {
        _durations = durs.toSet().toList()..sort();
        if (_durations.length == 1) _durationMinutes = _durations.first;
      });
    } catch (_) {
      if (mounted) AppSnackBar.show(context, 'Failed to load durations.');
    }
  }

  Future<void> _submit() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      AppSnackBar.show(context, 'Please enter a name for the voucher.');
      return;
    }
    if (_branches.isEmpty) {
      AppSnackBar.show(context, 'No branch available.');
      return;
    }

    if (_productType == 'SERVICE') {
      if (_serviceId == null || _durationMinutes == null) {
        AppSnackBar.show(context, 'Please select a service and duration.');
        return;
      }
    } else {
      if (_selectedPackageId == null) {
        AppSnackBar.show(context, 'Please select a package.');
        return;
      }
    }

    setState(() => _submitting = true);
    try {
      await ref.read(apiProvider).createVoucherRequest(
            branchId: _branchId,
            name: name,
            message: _message.text.trim().isEmpty ? null : _message.text.trim(),
            productType: _productType,
            serviceId: _productType == 'SERVICE' ? _serviceId : null,
            durationMinutes: _productType == 'SERVICE' ? _durationMinutes : null,
            packageId: _productType != 'SERVICE' ? _selectedPackageId : null,
            recipientEmail: _email.text.trim().isEmpty ? null : _email.text.trim(),
            recipientPhone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
          );
      if (!mounted) return;
      AppSnackBar.show(context, 'Request submitted. Our team will contact you soon.');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context, e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Request voucher', style: TextStyle(color: AppColors.textPrimary)),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withOpacity(0.25)),
                    ),
                    child: Text(
                      'After you submit this form, a staff member will reach out to you by email or phone to confirm your voucher, amount, and payment. Nothing is charged in the app until staff confirms with you.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp, height: 1.4),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text('Branch', style: _labelStyle),
                  DropdownButtonFormField<int>(
                    value: _branches.isEmpty ? null : _branches[_branchIndex].id,
                    dropdownColor: AppColors.cardBackground,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: _inputDeco(),
                    items: _branches
                        .map((b) => DropdownMenuItem(value: b.id, child: Text(b.name)))
                        .toList(),
                    onChanged: (id) {
                      if (id == null) return;
                      final i = _branches.indexWhere((b) => b.id == id);
                      setState(() => _branchIndex = i >= 0 ? i : 0);
                      _reloadCatalogForBranch();
                    },
                  ),
                  SizedBox(height: 1.5.h),
                  Text('Voucher title', style: _labelStyle),
                  TextField(
                    controller: _name,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: _inputDeco(hint: 'e.g. Birthday gift for Sara'),
                  ),
                  SizedBox(height: 1.5.h),
                  Text('Message (optional)', style: _labelStyle),
                  TextField(
                    controller: _message,
                    maxLines: 3,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: _inputDeco(hint: 'Any note for our team'),
                  ),
                  SizedBox(height: 1.5.h),
                  Text('Contact email (optional)', style: _labelStyle),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: _inputDeco(hint: 'Where we can reach you'),
                  ),
                  SizedBox(height: 1.5.h),
                  Text('Contact phone (optional)', style: _labelStyle),
                  TextField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: _inputDeco(hint: 'Mobile number'),
                  ),
                  SizedBox(height: 2.h),
                  Text('What is this voucher for?', style: _labelStyle),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'SERVICE', label: Text('Service')),
                      ButtonSegment(value: 'COMBO', label: Text('Combo')),
                      ButtonSegment(value: 'PACKAGE', label: Text('Package')),
                    ],
                    selected: {_productType},
                    onSelectionChanged: (s) {
                      setState(() => _productType = s.first);
                    },
                  ),
                  SizedBox(height: 2.h),
                  if (_productType == 'SERVICE') ...[
                    Text('Category', style: _labelStyle),
                    DropdownButtonFormField<int>(
                      value: _categoryId,
                      dropdownColor: AppColors.cardBackground,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _inputDeco(),
                      hint: const Text('Select category', style: TextStyle(color: AppColors.textTertiary)),
                      items: _categories
                          .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                          .toList(),
                      onChanged: _onCategoryChanged,
                    ),
                    SizedBox(height: 1.5.h),
                    Text('Service', style: _labelStyle),
                    DropdownButtonFormField<int>(
                      value: _serviceId,
                      dropdownColor: AppColors.cardBackground,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _inputDeco(),
                      hint: const Text('Select service'),
                      items: _services.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                      onChanged: _onServiceChanged,
                    ),
                    SizedBox(height: 1.5.h),
                    Text('Duration', style: _labelStyle),
                    DropdownButtonFormField<int>(
                      value: _durationMinutes,
                      dropdownColor: AppColors.cardBackground,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _inputDeco(),
                      hint: const Text('Select duration'),
                      items: _durations
                          .map((m) => DropdownMenuItem(value: m, child: Text('$m minutes')))
                          .toList(),
                      onChanged: (v) => setState(() => _durationMinutes = v),
                    ),
                  ] else ...[
                    Text(_productType == 'COMBO' ? 'Combo' : 'Package bundle', style: _labelStyle),
                    DropdownButtonFormField<int>(
                      value: _selectedPackageId,
                      dropdownColor: AppColors.cardBackground,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _inputDeco(),
                      hint: const Text('Select item'),
                      items: (_productType == 'COMBO' ? _comboPackages : _creditPackages)
                          .map(
                            (p) => DropdownMenuItem(
                              value: p.id,
                              child: Text('${p.name} · EGP ${p.price.toStringAsFixed(0)}'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedPackageId = v),
                    ),
                  ],
                  SizedBox(height: 3.h),
                  FilledButton(
                    onPressed: _submitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 1.6.h),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Submit request'),
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
    );
  }

  TextStyle get _labelStyle => TextStyle(color: AppColors.textSecondary, fontSize: 12.sp, fontWeight: FontWeight.w600);

  InputDecoration _inputDeco({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textTertiary),
      filled: true,
      fillColor: AppColors.cardBackground,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.dividerColor),
      ),
    );
  }
}
