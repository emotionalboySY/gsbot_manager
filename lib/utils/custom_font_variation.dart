import 'dart:ui';

class CustomFontVariation {
  CustomFontVariation._();

  static const List<FontVariation> thin = [FontVariation('wght', 100)];
  static const List<FontVariation> extraLight = [FontVariation('wght', 200)];
  static const List<FontVariation> light = [FontVariation('wght', 300)];
  static const List<FontVariation> regular = [FontVariation('wght', 400)];
  static const List<FontVariation> medium = [FontVariation('wght', 500)];
  static const List<FontVariation> semiBold = [FontVariation('wght', 600)];
  static const List<FontVariation> bold = [FontVariation('wght', 700)];
  static const List<FontVariation> extraBold = [FontVariation('wght', 800)];
  static const List<FontVariation> black = [FontVariation('wght', 900)];

  static List<FontVariation> weight(double value) {
    return [FontVariation('wght', value)];
  }

  static List<FontVariation> custom({
    double? weight,
    double? width,
    double? slant,
  }) {
    final variations = <FontVariation>[];
    if (weight != null) variations.add(FontVariation('wght', weight));
    if (width != null) variations.add(FontVariation('wdth', width));
    if (slant != null) variations.add(FontVariation('slnt', slant));
    return variations;
  }
}
