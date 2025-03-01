import 'package:flutter/material.dart';

class AppColors {
  // From your palette:
  // #0A2721, #184E45, #275D57, #75A680, #F9B024

  // 1) Dark background
  static const Color background = Color(0xFF0A2721);

  // 2) Slightly lighter surface for cards or form fields
  static const Color cardColor = Color(0xFF184E45);

  // 3) Another teal (medium) for secondary accents or input fill
  static const Color secondary = Colors.white;

  // 4) Light teal for text highlights or other accents
  static const Color accent = Color(0xFF75A680);

  // 5) Bright gold for primary buttons or important CTAs
  static const Color primary = Color(0xFFF9B024);

  // General text color (white or near-white for dark backgrounds)
  static const Color textPrimary = Colors.white;

  // Error color: you could reuse a red shade, or pick one of the teals if you want to stay strictly to these 5.
  // For demonstration, let's reuse the medium teal with a slight variation, or keep a standard red.
  static const Color error = Colors.redAccent;

  static const Color buttonPrimary = Colors.orangeAccent;

  // For an AppBar gradient, you could combine two of these colors:
  static const Color appBarStart = background; // #0A2721
  static const Color appBarEnd = secondary;    // #275D57
  static const Color appBarIcon = textPrimary; // White icons
  static const Color appBarText = textPrimary; // White text

  // For input fields, you might use cardColor or secondary:
  static const Color inputFillColor = textPrimary; // #184E45
}
