import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/models/Voucher/api_voucher.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/exception/snack_bar.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:sizer/sizer.dart';

class VouchersPage extends ConsumerStatefulWidget {
  const VouchersPage({super.key});

  @override
  ConsumerState<VouchersPage> createState() => _VouchersPageState();
}

class _VouchersPageState extends ConsumerState<VouchersPage> {
  List<ApiVoucher> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await ref.read(apiProvider).getVouchers();
      if (!mounted) return;
      setState(() {
        _items = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      AppSnackBar.show(context, 'Failed to load vouchers.');
    }
  }

  Future<void> _cancelIfRequested(ApiVoucher v) async {
    if (v.status != 'REQUESTED') return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Cancel request?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'This will cancel your pending voucher request.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(apiProvider).cancelVoucher(v.id);
      if (!mounted) return;
      AppSnackBar.show(context, 'Request cancelled.');
      await _load();
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Vouchers', style: TextStyle(color: AppColors.textPrimary)),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () async {
              await Navigator.pushNamed(context, Routes.voucherRequest);
              _load();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _items.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: 20.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        child: Column(
                          children: [
                            Icon(Icons.card_giftcard, size: 48.sp, color: AppColors.textTertiary),
                            SizedBox(height: 2.h),
                            Text(
                              'No vouchers yet',
                              style: TextStyle(color: AppColors.textPrimary, fontSize: 16.sp, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Request a voucher for yourself or as a gift. A staff member will contact you by email or phone to confirm details and payment.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp, height: 1.4),
                            ),
                            SizedBox(height: 3.h),
                            FilledButton(
                              onPressed: () async {
                                await Navigator.pushNamed(context, Routes.voucherRequest);
                                _load();
                              },
                              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                              child: const Text('Request a voucher'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    itemCount: _items.length,
                    itemBuilder: (_, i) {
                      final v = _items[i];
                      return Card(
                        color: AppColors.cardBackground,
                        margin: EdgeInsets.only(bottom: 1.2.h),
                        child: ListTile(
                          title: Text(v.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 0.5.h),
                              Text(v.productSummary, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                              if (v.branchName != null)
                                Text(v.branchName!, style: const TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                              if (v.price != null)
                                Text('EGP ${v.price!.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.info, fontSize: 13)),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                v.statusLabel,
                                style: TextStyle(
                                  color: v.status == 'CANCELLED' ? AppColors.error : AppColors.success,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.sp,
                                ),
                              ),
                              if (v.status == 'REQUESTED')
                                TextButton(
                                  onPressed: () => _cancelIfRequested(v),
                                  child: const Text('Cancel'),
                                ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
