import 'package:get/get.dart';

import '../../utils/custom_snackbar.dart';

class AccountController extends GetxController {
  var isEmailVerified = false.obs;
  var isPhoneVerified = true.obs;

  void verifyEmail() {
    isEmailVerified.value = true;
    CustomSnackbar.show(
      title: 'Success',
      message: 'Email verified successfully!',
      isSuccess: true,
    );
  }
}
