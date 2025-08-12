// filepath: /Users/emirulasti/Dev/ios_dev/lchat/lib/core/extensions/context_extensions.dart
import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  // Screen dimensions
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  // Responsive helpers
  double get blockSizeHorizontal => screenWidth / 100;
  double get blockSizeVertical => screenHeight / 100;

  // Safe area
  EdgeInsets get safeArea => MediaQuery.of(this).padding;
  double get safeWidth => screenWidth - safeArea.horizontal;
  double get safeHeight => screenHeight - safeArea.vertical;

  // Responsive methods
  double widthPercent(double percent) => screenWidth * (percent / 100);
  double heightPercent(double percent) => screenHeight * (percent / 100);

  // Common responsive sizes
  double get smallSpacing => screenHeight * 0.01;
  double get mediumSpacing => screenHeight * 0.02;
  double get largeSpacing => screenHeight * 0.04;
}
