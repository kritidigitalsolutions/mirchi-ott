import 'dart:async';
import 'package:get/get.dart';

class OtpController extends GetxController {
  var isResendButtonDisabled = false.obs;
  var countdown = 30.obs;
  Timer? _timer;

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void startTimer() {
    isResendButtonDisabled.value = true;
    countdown.value = 30;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        _timer?.cancel();
        isResendButtonDisabled.value = false;
      }
    });
  }
}
