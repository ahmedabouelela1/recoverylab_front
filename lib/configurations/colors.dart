import 'package:flutter/material.dart';

/// Centralized color palette for the application
class AppColors {
  // Primary Colors
  static const primary = Color(0xFF223865); // Dark blue for primary buttons
  static const secondary = Color(0xFFFFFFFF); // White for secondary buttons

  // Background Colors
  static const background = Color(0xFF000000); // black background (dark theme)
  static const cardBackground = Color(
    0xFF1E1E24,
  ); // Dark grey for cards and containers

  // Text Colors
  static const textPrimary = Color(0xFFFFFFFF); // Main text color (white)
  static const textSecondary = Color(
    0xFFB3B3B3,
  ); // Secondary text color (light grey for hints, etc.)

  // TextField Colors
  static const textFieldBorder = Color(
    0xFF404040,
  ); // Darker grey for text field backgrounds
  static const textFieldBackground = Color(
    0xFF282828,
  ); // Background color for text fields

  // Border Colors
  static const strokeBorder = Color(
    0xFFCCCCCC,
  ); // light border color for button outlines

  // Alert and Feedback Colors
  static const success = Color(0xFF4CAF50); // Green for success state
  static const error = Color(0xFFF44336); // Red for error state
  static const warning = Color(0xFFFFC107); // Yellow for warning state
  static const info = Color(0xFF2196F3); // Blue for info state
}
