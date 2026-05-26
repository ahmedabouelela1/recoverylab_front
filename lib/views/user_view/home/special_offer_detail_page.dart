import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/models/Offer/offers.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/exception/exception_handling.dart';
import 'package:recoverylab_front/models/Branch/services/service.dart';
import 'package:recoverylab_front/models/Branch/services/service_category.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:recoverylab_front/providers/session/active_offer_provider.dart';
import 'package:recoverylab_front/views/user_view/packages/packages_details_page.dart';
import 'package:sizer/sizer.dart';
import 'package:solar_icons/solar_icons.dart';

/// Special offer detail — same fields as API (title, description, discount, image,
/// big_description). Layout and typography aligned with [ServiceDetailsPage].
class SpecialOfferDetailPage extends ConsumerStatefulWidget {
  const SpecialOfferDetailPage({required this.offerId, super.key});

  final int offerId;

  @override
  ConsumerState<SpecialOfferDetailPage> createState() =>
      _SpecialOfferDetailPageState();
}

class _SpecialOfferDetailPageState extends ConsumerState<SpecialOfferDetailPage> {
  Offers? _offer;
  bool _loading = true;
  String? _error;
  bool _showFullBigDescription = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final o = await ref.read(apiProvider).getOfferDetail(widget.offerId);
      if (mounted) setState(() => _offer = o);
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      if (mounted) setState(() => _error = msg);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loading
          ? _buildLoadingState()
          : _error != null
              ? _buildErrorState()
              : _buildBody(_offer!),
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
            'Loading offer...',
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
          _buildHeaderPlaceholder(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2.h),
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
                      Icon(
                        SolarIconsOutline.dangerCircle,
                        size: 28.sp,
                        color: AppColors.warning,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      TextButton(
                        onPressed: _load,
                        child: Text(
                          'Retry',
                          style: TextStyle(
                            color: AppColors.info,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderPlaceholder() {
    return Container(
      height: 30.h,
      width: double.infinity,
      color: AppColors.cardBackground,
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

  void _navigateCta(Offers o) {
    final target = o.targetType ?? 'ALL';

    // Carried into service or combo booking; screens validate applicability.
    ref.read(activeOfferProvider.notifier).set(o);

    switch (target) {
      case 'SERVICE':
        if (o.targetId != null) {
          // Build a minimal Service stub — ServiceDetailsPage re-fetches full data via getBranchService.
          final stub = Service(
            id: o.targetId!,
            category: ServiceCategory(id: 0, name: '', description: '', image: ''),
            name: o.title,
            description: '',
            image: o.image,
          );
          Navigator.pushNamed(context, Routes.serviceDetails, arguments: {'service': stub});
        } else {
          Navigator.pushNamed(context, Routes.categories);
        }
        break;
      case 'SERVICE_CATEGORY':
        Navigator.pushNamed(context, Routes.serviceCats);
        break;
      case 'PACKAGE':
        if (o.targetId != null) {
          _navigateToSpecificCombo(o.targetId!);
        } else {
          Navigator.pushNamed(context, Routes.packagesPage);
        }
        break;
      default: // ALL
        Navigator.pushNamed(context, Routes.categories);
    }
  }

  Future<void> _navigateToSpecificCombo(int comboId) async {
    setState(() => _loading = true);
    try {
      final combo = await ref.read(apiProvider).getPackageById(comboId);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PackageDetailsPage(
            type: PackageType.combo,
            combo: combo,
            itemId: combo.id,
            title: combo.name,
            description: combo.description ?? '',
            imagePath: combo.image ?? '',
            totalDuration: '${combo.totalDurationMinutes} min',
            price: combo.price.toStringAsFixed(0),
            inclusions: combo.rules
                .map((r) => {
                      'service': r.serviceName ?? r.serviceCategoryName ?? '',
                      'duration': '${r.durationMinutes ?? 0} min',
                    })
                .toList(),
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load offer details. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildBody(Offers o) {
    final big = o.bigDescription?.trim();
    final badge = o.discountBadge;
    final validity = o.validityLabel;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderImage(o),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2.h),
                      _buildTitleRow(o),
                      if (badge != null) ...[
                        SizedBox(height: 1.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.success.withOpacity(0.3)),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      if (validity != null) ...[
                        SizedBox(height: 0.8.h),
                        Row(
                          children: [
                            Icon(SolarIconsOutline.calendar, size: 13.sp, color: AppColors.textTertiary),
                            SizedBox(width: 1.5.w),
                            Text(
                              validity,
                              style: TextStyle(color: AppColors.textTertiary, fontSize: 11.sp),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: 2.5.h),
                      Text(
                        'OVERVIEW',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          o.description.trim().isNotEmpty
                              ? o.description
                              : 'No short description for this offer.',
                          style: TextStyle(
                            color: o.description.trim().isNotEmpty
                                ? AppColors.textSecondary
                                : AppColors.textTertiary,
                            fontSize: 13.sp,
                            height: 1.6,
                          ),
                        ),
                      ),
                      SizedBox(height: 2.5.h),
                      Text(
                        'DETAILS',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      if (big != null && big.isNotEmpty)
                        _buildBigDescriptionCard(big)
                      else
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.info.withOpacity(0.2)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                SolarIconsOutline.infoCircle,
                                color: AppColors.info,
                                size: 18.sp,
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Text(
                                  'More information may be added by your branch soon.',
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
                      SizedBox(height: 3.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // CTA button pinned to bottom
        Padding(
          padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.h),
          child: SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed: () => _navigateCta(o),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                o.ctaLabel?.isNotEmpty == true ? o.ctaLabel! : 'Book Now',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderImage(Offers o) {
    final img = o.image.trim();
    return SizedBox(
      height: 30.h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (img.isNotEmpty)
            Image.network(
              img,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context2, err, stack) => Container(
                color: AppColors.cardBackground,
                child: Center(
                  child: Icon(
                    SolarIconsOutline.gallery,
                    size: 48.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            )
          else
            Container(
              color: AppColors.cardBackground,
              child: Center(
                child: Icon(
                  SolarIconsOutline.gallery,
                  size: 48.sp,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
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

  Widget _buildTitleRow(Offers o) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            o.title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.1,
            ),
          ),
        ),
        if (o.discount != null && o.discount!.trim().isNotEmpty) ...[
          SizedBox(width: 2.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: Text(
              o.discount!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.info,
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBigDescriptionCard(String big) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            big,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13.sp,
              height: 1.6,
            ),
            maxLines: _showFullBigDescription ? null : 5,
            overflow: _showFullBigDescription
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
          ),
          if (big.length > 200 || big.split('\n').length > 5)
            GestureDetector(
              onTap: () => setState(
                () => _showFullBigDescription = !_showFullBigDescription,
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 1.h),
                child: Row(
                  children: [
                    Text(
                      _showFullBigDescription ? 'Read less' : 'Read more',
                      style: TextStyle(
                        color: AppColors.info,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 1.w),
                    Icon(
                      _showFullBigDescription
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
      ),
    );
  }
}
