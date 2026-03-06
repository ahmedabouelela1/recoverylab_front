import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/components/app_button.dart';

class EditHealthSurveyPage extends StatefulWidget {
  const EditHealthSurveyPage({super.key});

  @override
  State<EditHealthSurveyPage> createState() => _EditHealthSurveyPageState();
}

class _EditHealthSurveyPageState extends State<EditHealthSurveyPage> {
  // ── Survey state ──────────────────────────────────────────────────────────
  final Map<String, bool> _conditions = {
    'Heart condition': false,
    'High blood pressure': false,
    'Diabetes': false,
    'Asthma or respiratory issues': false,
    'Back or spinal injury': false,
    'Pregnancy': false,
    'Skin conditions': false,
    'Recent surgery': false,
  };

  String? _fitnessLevel; // 'Beginner' | 'Intermediate' | 'Advanced'
  String?
  _primaryGoal; // 'Relaxation' | 'Recovery' | 'Performance' | 'Wellness'
  final _allergiesController = TextEditingController();
  final _medicationsController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _allergiesController.dispose();
    _medicationsController.dispose();
    super.dispose();
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 800)); // TODO: API call
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
        margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(
              SolarIconsOutline.checkCircle,
              color: Colors.white,
              size: 14.sp,
            ),
            SizedBox(width: 2.w),
            Text(
              'Health survey updated',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
              size: 16,
            ),
          ),
        ),
        title: Text(
          'Health Survey',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17.sp,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        children: [
          // Info banner
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  SolarIconsOutline.infoCircle,
                  color: AppColors.info,
                  size: 16.sp,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'This information helps our therapists provide the safest and most effective treatment for you.',
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

          // ── Medical conditions ───────────────────────────────────────
          _sectionLabel('MEDICAL CONDITIONS'),
          SizedBox(height: 1.2.h),
          Text(
            'Select any conditions that apply to you',
            style: TextStyle(color: AppColors.textTertiary, fontSize: 12.sp),
          ),
          SizedBox(height: 1.5.h),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.dividerColor, width: 0.8),
            ),
            child: Column(
              children: _conditions.keys.toList().asMap().entries.map((entry) {
                final i = entry.key;
                final key = entry.value;
                final isLast = i == _conditions.length - 1;
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () =>
                          setState(() => _conditions[key] = !_conditions[key]!),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.6.h,
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: _conditions[key]!
                                    ? AppColors.info
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _conditions[key]!
                                      ? AppColors.info
                                      : AppColors.textTertiary,
                                  width: 1.5,
                                ),
                              ),
                              child: _conditions[key]!
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 14,
                                    )
                                  : null,
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                key,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        color: AppColors.dividerColor,
                        height: 1,
                        thickness: 0.5,
                        indent: 12.w,
                        endIndent: 4.w,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 3.h),

          // ── Fitness level ────────────────────────────────────────────
          _sectionLabel('FITNESS LEVEL'),
          SizedBox(height: 1.2.h),
          Row(
            children: ['Beginner', 'Intermediate', 'Advanced'].map((level) {
              final isSelected = _fitnessLevel == level;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _fitnessLevel = level),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: EdgeInsets.only(
                      right: level != 'Advanced' ? 2.w : 0,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.info.withOpacity(0.14)
                          : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.info.withOpacity(0.4)
                            : AppColors.dividerColor,
                        width: isSelected ? 1.5 : 0.8,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        level,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.info
                              : AppColors.textSecondary,
                          fontSize: 12.5.sp,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 3.h),

          // ── Primary goal ─────────────────────────────────────────────
          _sectionLabel('PRIMARY GOAL'),
          SizedBox(height: 1.2.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: ['Relaxation', 'Recovery', 'Performance', 'Wellness'].map(
              (goal) {
                final isSelected = _primaryGoal == goal;
                return GestureDetector(
                  onTap: () => setState(() => _primaryGoal = goal),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 1.2.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.12)
                          : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.4)
                            : AppColors.dividerColor,
                        width: isSelected ? 1.5 : 0.8,
                      ),
                    ),
                    child: Text(
                      goal,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontSize: 13.sp,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
          SizedBox(height: 3.h),

          // ── Allergies ────────────────────────────────────────────────
          _sectionLabel('KNOWN ALLERGIES'),
          SizedBox(height: 1.2.h),
          _textField(
            controller: _allergiesController,
            hint: 'e.g. nuts, latex, essential oils...',
          ),
          SizedBox(height: 3.h),

          // ── Medications ──────────────────────────────────────────────
          _sectionLabel('CURRENT MEDICATIONS'),
          SizedBox(height: 1.2.h),
          _textField(
            controller: _medicationsController,
            hint: 'e.g. blood thinners, insulin...',
            maxLines: 3,
          ),
          SizedBox(height: 4.h),

          AppButton(
            label: _isSaving ? 'Saving...' : 'Save Changes',
            onPressed: _isSaving ? null : _save,
            size: AppButtonSize.large,
            width: double.infinity,
            borderRadius: 16,
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: TextStyle(
      color: AppColors.textSecondary,
      fontSize: 12.sp,
      fontWeight: FontWeight.bold,
      letterSpacing: 2,
    ),
  );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerColor, width: 0.8),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(color: AppColors.textPrimary, fontSize: 13.sp),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 13.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(4.w),
        ),
      ),
    );
  }
}
