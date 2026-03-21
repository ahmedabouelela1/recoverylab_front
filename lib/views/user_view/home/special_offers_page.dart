import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/models/Offer/offers.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/exception/snack_bar.dart';
import 'package:recoverylab_front/providers/session/user_session_provider.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:sizer/sizer.dart';
import 'package:solar_icons/solar_icons.dart';

/// Full list of special offers (same data as home carousel, navigable from "Special Offers").
class SpecialOffersPage extends ConsumerStatefulWidget {
  const SpecialOffersPage({super.key});

  @override
  ConsumerState<SpecialOffersPage> createState() => _SpecialOffersPageState();
}

class _SpecialOffersPageState extends ConsumerState<SpecialOffersPage> {
  List<Offers> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final branchId = ref.read(userSessionProvider).user?.branchId;
      final list = await ref.read(apiProvider).getOffersList(branchId: branchId);
      if (mounted) setState(() => _items = list);
    } catch (e) {
      if (mounted) AppSnackBar.show(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openDetail(Offers o) {
    Navigator.pushNamed(
      context,
      Routes.specialOfferDetail,
      arguments: {'id': o.id},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Special Offers',
          style: GoogleFonts.inter(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: AppColors.info,
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.info))
            : _items.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: 20.h),
                      Icon(SolarIconsOutline.tag,
                          size: 48.sp, color: AppColors.textTertiary),
                      SizedBox(height: 2.h),
                      Center(
                        child: Text(
                          'No active offers right now',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding:
                        EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                    itemCount: _items.length,
                    itemBuilder: (context, i) {
                      final o = _items[i];
                      final img = o.image.isNotEmpty ? o.image : '';
                      return Padding(
                        padding: EdgeInsets.only(bottom: 2.h),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _openDetail(o),
                            borderRadius: BorderRadius.circular(24),
                            child: Ink(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: SizedBox(
                                  height: 22.h,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      if (img.isNotEmpty)
                                        Image.network(
                                          img,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                            color: AppColors.cardBackground,
                                            child: Icon(
                                              SolarIconsOutline.gallery,
                                              color: AppColors.textTertiary,
                                              size: 32.sp,
                                            ),
                                          ),
                                        )
                                      else
                                        Container(
                                          color: AppColors.cardBackground,
                                        ),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.black
                                                  .withValues(alpha: 0.25),
                                              Colors.black
                                                  .withValues(alpha: 0.75),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(4.w),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    o.title,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 17.sp,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Colors.white,
                                                      height: 1.15,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (o.discount != null &&
                                                    o.discount!.isNotEmpty)
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 3.w,
                                                      vertical: 1.h,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          AppColors.primary,
                                                          const Color(
                                                              0xFF7B61FF),
                                                        ],
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              14),
                                                    ),
                                                    child: Text(
                                                      o.discount!,
                                                      style:
                                                          GoogleFonts.inter(
                                                        fontSize: 12.sp,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    o.description,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12.sp,
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.92),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Icon(
                                                  SolarIconsOutline
                                                      .arrowRight,
                                                  color: Colors.white
                                                      .withValues(alpha: 0.9),
                                                  size: 20.sp,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
