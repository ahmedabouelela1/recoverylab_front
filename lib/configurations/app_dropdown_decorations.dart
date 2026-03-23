import 'package:dropdown_flutter/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:solar_icons/solar_icons.dart';

/// Shared [CustomDropdownDecoration] presets for [DropdownFlutter] across the app.
class AppDropdownDecorations {
  AppDropdownDecorations._();
  /// Standalone field (signup gender, etc.). Matches legacy [AnimatedContainer] stroke (1 / 1.5 on error).
  static CustomDropdownDecoration field({
    bool hasError = false,
  }) {
    final color = hasError ? AppColors.error : AppColors.borderColor;
    final w = hasError ? 1.5 : 1.0;
    return CustomDropdownDecoration(
      closedFillColor: AppColors.textFieldBackground,
      expandedFillColor: AppColors.cardBackground,
      closedBorder: Border.all(color: color, width: w),
      expandedBorder: Border.all(color: AppColors.dividerColor, width: 1),
      closedBorderRadius: BorderRadius.circular(14),
      expandedBorderRadius: BorderRadius.circular(14),
      hintStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary.withValues(alpha: 0.5),
      ),
      headerStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      listItemStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      closedSuffixIcon: Icon(
        SolarIconsBold.altArrowDown,
        size: 20,
        color: AppColors.textSecondary,
      ),
      expandedSuffixIcon: Icon(
        SolarIconsBold.altArrowUp,
        size: 20,
        color: AppColors.textSecondary,
      ),
      listItemDecoration: ListItemDecoration(
        selectedColor: AppColors.surfaceLight,
        highlightColor: AppColors.dividerColor.withValues(alpha: 0.6),
      ),
    );
  }

  /// Inside a row that already has an outer border (phone country code).
  static CustomDropdownDecoration embeddedInField() {
    return CustomDropdownDecoration(
      closedFillColor: Colors.transparent,
      expandedFillColor: AppColors.cardBackground,
      closedBorder: null,
      closedBorderRadius: BorderRadius.zero,
      expandedBorder: Border.all(color: AppColors.dividerColor, width: 1),
      expandedBorderRadius: BorderRadius.circular(12),
      hintStyle: GoogleFonts.inter(
        fontSize: 13,
        color: AppColors.textTertiary,
      ),
      headerStyle: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      listItemStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      closedSuffixIcon: Icon(
        SolarIconsOutline.altArrowDown,
        size: 18,
        color: AppColors.textSecondary,
      ),
      expandedSuffixIcon: Icon(
        SolarIconsOutline.altArrowUp,
        size: 18,
        color: AppColors.textSecondary,
      ),
      listItemDecoration: ListItemDecoration(
        selectedColor: AppColors.surfaceLight,
        highlightColor: AppColors.dividerColor,
      ),
    );
  }

  /// Combo booking: service slot inside a card.
  static CustomDropdownDecoration cardInline() {
    return CustomDropdownDecoration(
      closedFillColor: AppColors.cardBackground,
      expandedFillColor: AppColors.cardBackground,
      closedBorder: Border.all(color: AppColors.dividerColor, width: 0.8),
      expandedBorder: Border.all(color: AppColors.dividerColor, width: 1),
      closedBorderRadius: BorderRadius.circular(12),
      expandedBorderRadius: BorderRadius.circular(12),
      hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 13),
      headerStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      listItemStyle: TextStyle(color: AppColors.textPrimary, fontSize: 13),
      closedSuffixIcon: Icon(
        SolarIconsOutline.altArrowDown,
        color: AppColors.textTertiary,
        size: 18,
      ),
      expandedSuffixIcon: Icon(
        SolarIconsOutline.altArrowUp,
        color: AppColors.textTertiary,
        size: 18,
      ),
      listItemDecoration: ListItemDecoration(
        selectedColor: AppColors.info.withValues(alpha: 0.12),
        highlightColor: AppColors.surfaceLight,
      ),
    );
  }

  /// Combo booking: branch row inside bordered container.
  static CustomDropdownDecoration branchSelector() {
    return CustomDropdownDecoration(
      closedFillColor: Colors.transparent,
      expandedFillColor: AppColors.cardBackground,
      closedBorder: null,
      expandedBorder: Border.all(color: AppColors.dividerColor, width: 1),
      expandedBorderRadius: BorderRadius.circular(16),
      hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 13),
      headerStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      listItemStyle: TextStyle(fontSize: 13, color: AppColors.textPrimary),
      closedSuffixIcon: Icon(
        SolarIconsOutline.altArrowDown,
        color: AppColors.strokeBorder,
        size: 20,
      ),
      expandedSuffixIcon: Icon(
        SolarIconsOutline.altArrowUp,
        color: AppColors.strokeBorder,
        size: 20,
      ),
      listItemDecoration: ListItemDecoration(
        selectedColor: AppColors.info.withValues(alpha: 0.15),
        highlightColor: AppColors.surfaceLight,
      ),
    );
  }
}
