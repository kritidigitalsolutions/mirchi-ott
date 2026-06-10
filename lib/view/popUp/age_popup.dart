import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class AgeRestrictionPopup extends StatelessWidget {
  const AgeRestrictionPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    "18+",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Age-Restricted Content",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "This content may contain violence, adult language, or other mature themes. Please confirm you are over 18 to proceed.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                  ),
                ),
                const SizedBox(height: 30),
                const Divider(color: Colors.white12, height: 1),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20)),
                          ),
                        ),
                        child: const Text(
                          "CANCEL",
                          style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Container(width: 1, height: 60, color: Colors.white12),
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(bottomRight: Radius.circular(20)),
                          ),
                        ),
                        child: const Text(
                          "I'M OVER 18",
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
