import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 850;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < 1100 &&
      MediaQuery.of(context).size.width >= 850;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    if (width >= 1100) {
      return desktop;
    } else if (width >= 850 && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }

  /// Returns a dynamic back icon based on the platform.
  static IconData? getBackIcon(BuildContext context) {
    final TargetPlatform platform = Theme.of(context).platform;
    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      return Icons.arrow_back_ios;
    }
    return Icons.arrow_back;
  }

  /// Returns a Back Button widget. 
  /// By default it shows on web now because internal navigation buttons are often expected.
  static Widget backButton(BuildContext context, {VoidCallback? onPressed, Color color = Colors.white, bool hideOnWeb = false}) {
    if (kIsWeb && hideOnWeb) return const SizedBox.shrink();
    
    final icon = getBackIcon(context) ?? Icons.arrow_back;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        color: Colors.white.withOpacity(0.05),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed ?? () => Navigator.maybePop(context),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(icon, color: color, size: 22),
          ),
        ),
      ),
    );
  }
}
