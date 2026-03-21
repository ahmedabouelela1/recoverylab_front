import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/models/Offer/offers.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/exception/exception_handling.dart';
import 'package:recoverylab_front/providers/exception/snack_bar.dart';
import 'package:sizer/sizer.dart';
import 'package:solar_icons/solar_icons.dart';

/// Full-screen offer detail — shows [bigDescription] when present (not on home).
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
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.info),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        TextButton(
                          onPressed: _load,
                          child: Text(
                            'Retry',
                            style: TextStyle(color: AppColors.info, fontSize: 14.sp),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildContent(_offer!),
    );
  }

  Widget _buildContent(Offers o) {
    final img = o.image.isNotEmpty ? o.image : '';
    final big = o.bigDescription?.trim();
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 32.h,
          pinned: true,
          backgroundColor: AppColors.background,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (img.isNotEmpty)
                  Image.network(
                    img,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.cardBackground,
                    ),
                  )
                else
                  Container(color: AppColors.cardBackground),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.65),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 5.w,
                  right: 5.w,
                  bottom: 3.h,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (o.discount != null && o.discount!.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(bottom: 1.h),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 3.w,
                              vertical: 0.8.h,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  const Color(0xFF7B61FF),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              o.discount!,
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      Text(
                        o.title,
                        style: GoogleFonts.inter(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 4.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overview',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  o.description.isNotEmpty
                      ? o.description
                      : 'See details below.',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    height: 1.5,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (big != null && big.isNotEmpty) ...[
                  SizedBox(height: 3.h),
                  Text(
                    'Details',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    big,
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      height: 1.55,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ] else ...[
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Icon(
                        SolarIconsOutline.infoCircle,
                        size: 16.sp,
                        color: AppColors.textTertiary,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          'More information may be added by your branch soon.',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
