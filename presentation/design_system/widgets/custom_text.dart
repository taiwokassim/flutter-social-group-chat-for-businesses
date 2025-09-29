import 'package:flutter/material.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:google_fonts/google_fonts.dart';

/// A customized Text widget that provides consistent styling across the app
///
/// This widget handles typography according to the app's design system,
/// providing defaults for colors, font weights, and sizes while allowing
/// for custom overrides when needed.
class CustomText extends StatelessWidget {
  const CustomText({
    super.key,
    required this.text,
    this.color,
    this.fontWeight,
    this.fontSize,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.letterSpacing,
    this.height,
    this.textDecoration,
  });

  /// The text to display
  final String text;

  /// The color of the text (defaults to black)
  final Color? color;

  /// The font weight (defaults to medium/w500)
  final FontWeight? fontWeight;

  /// The font size in logical pixels
  final double? fontSize;

  /// Optional custom text style that overrides all other properties
  final TextStyle? style;

  /// Text alignment
  final TextAlign? textAlign;

  /// Maximum number of lines
  final int? maxLines;

  /// How to handle overflow
  final TextOverflow? overflow;

  /// Letter spacing
  final double? letterSpacing;

  /// Line height as a multiple of the font size
  final double? height;

  /// Text decoration (underline, etc.)
  final TextDecoration? textDecoration;

  @override
  Widget build(BuildContext context) {
    // Create our custom style based on the parameters or defaults
    final TextStyle defaultStyle = GoogleFonts.roboto(
      color: color ?? black,
      fontWeight: fontWeight ?? FontWeight.w500,
      fontSize: fontSize ?? 14,
      letterSpacing: letterSpacing,
      height: height,
      decoration: textDecoration,
    );
    
    // Use style parameter if provided, otherwise use our defaultStyle
    final TextStyle effectiveStyle = style ?? defaultStyle;

    return Text(
      text,
      style: effectiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
