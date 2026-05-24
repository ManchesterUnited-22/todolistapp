import 'dart:math' as math;

import 'package:flutter/material.dart';

enum AppFormFactor { phone, tablet, desktop }

class ResponsiveLayout {
  const ResponsiveLayout._();

  static AppFormFactor formFactorFromWidth(double width) {
    if (width >= 1024) return AppFormFactor.desktop;
    if (width >= 600) return AppFormFactor.tablet;
    return AppFormFactor.phone;
  }

  static AppFormFactor formFactor(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return formFactorFromWidth(width);
  }

  static bool isPhone(BuildContext context) =>
      formFactor(context) == AppFormFactor.phone;

  static bool isTablet(BuildContext context) =>
      formFactor(context) == AppFormFactor.tablet;

  static bool isDesktop(BuildContext context) =>
      formFactor(context) == AppFormFactor.desktop;

  static double dialogMaxWidth(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final factor = formFactor(context);
    final target = switch (factor) {
      AppFormFactor.phone => 560.0,
      AppFormFactor.tablet => 760.0,
      AppFormFactor.desktop => 960.0,
    };
    return math.min(target, size.width * 0.96);
  }

  static double dialogMaxHeight(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final factor = formFactor(context);
    final ratio = switch (factor) {
      AppFormFactor.phone => 0.92,
      AppFormFactor.tablet => 0.90,
      AppFormFactor.desktop => 0.86,
    };
    return size.height * ratio;
  }

  static EdgeInsets dialogInsetPadding(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final horizontal = math.max(12.0, size.width * 0.04);
    final vertical = math.max(12.0, size.height * 0.03);
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }

  static double adaptiveFont(
    BuildContext context,
    double base, {
    double min = 11,
    double max = 32,
  }) {
    final factor = formFactor(context);
    final scaled = switch (factor) {
      AppFormFactor.phone => base,
      AppFormFactor.tablet => base * 1.08,
      AppFormFactor.desktop => base * 1.14,
    };
    return scaled.clamp(min, max);
  }

  static Widget adaptiveDialog(
    BuildContext context, {
    required Widget child,
    Color backgroundColor = Colors.transparent,
  }) {
    return Dialog(
      backgroundColor: backgroundColor,
      insetPadding: dialogInsetPadding(context),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogMaxWidth(context),
          maxHeight: dialogMaxHeight(context),
        ),
        child: child,
      ),
    );
  }
}
