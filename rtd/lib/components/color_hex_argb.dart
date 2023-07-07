import 'dart:ui';

Color hexToArgbColor(String hexColor) {
  // Remove the '#' character if present
  if (hexColor.startsWith('#')) {
    hexColor = hexColor.substring(1);
  }

  // Pad the hexadecimal color code if it's a short form
  if (hexColor.length == 6) {
    hexColor = 'FF$hexColor';
  }

  // Parse the hexadecimal color code
  int colorValue = int.parse(hexColor, radix: 16);

  // Return the ARGB color
  return Color(colorValue);
}
