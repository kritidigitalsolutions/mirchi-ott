import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirchi_ott/utils/app_images.dart';
import '../../app/theme/app_colors.dart';
import '../../view_model/primium_controller/premium_controller.dart';

class RedeemVoucherPage extends StatefulWidget {
  const RedeemVoucherPage({Key? key}) : super(key: key);

  @override
  State<RedeemVoucherPage> createState() => _RedeemVoucherPageState();
}

class _RedeemVoucherPageState extends State<RedeemVoucherPage> {
  final TextEditingController voucherController = TextEditingController();
  final PremiumController controller = Get.find<PremiumController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Redeem Voucher",
          style: TextStyle(color: AppColors.white),
        ),
        centerTitle: true,
      ),

      /// 🔴 BODY
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                /// 🔹 Logo
                Image.asset(
                  AppImages.logo1,
                  height: 200,
                  width: 200,
                  fit: BoxFit.contain,
                ),

                // const SizedBox(height: 20),

                /// 🔹 Instruction Text
                const Text(
                  "Please enter the voucher code below",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 20),

                /// 🔹 TextField
                TextField(
                  controller: voucherController,
                  style: const TextStyle(color: AppColors.white),
                  decoration: const InputDecoration(
                    hintText: "Enter Voucher Code",
                    hintStyle: TextStyle(color: AppColors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.buttonColor),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// 🔴 Apply Button
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                    ),
                    onPressed: controller.isRedeeming.value
                        ? null
                        : () => controller.redeemVoucher(voucherController.text.trim()),
                    child: controller.isRedeeming.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "Apply",
                      style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            )),
          ),
        ),
      ),
    );
  }
}
