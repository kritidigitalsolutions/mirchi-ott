import 'package:flutter/widgets.dart';

import 'google_sign_in_web_button_stub.dart'
    if (dart.library.js_interop) 'google_sign_in_web_button_web.dart' as impl;

Widget buildGoogleSignInWebButton() {
  return impl.buildGoogleSignInWebButton();
}
