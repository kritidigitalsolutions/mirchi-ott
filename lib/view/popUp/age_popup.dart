import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class AgeRestrictionPopup extends StatelessWidget {
  const AgeRestrictionPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.black,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const Text(
              "Age-Restricted : 18+",
              style: TextStyle(
                color: AppColors.error,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              "Amount of violence, sex, adult language, nudity, or substance use may be present.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.white),
            ),

            const SizedBox(height: 25),

            /// OVER 18 BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const Text("I'M OVER 18",
                    style: TextStyle(color: AppColors.white)),
              ),
            ),

            const SizedBox(height: 10),
            /// CANCEL BUTTON
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                "CANCEL",
                style: TextStyle(color: AppColors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
