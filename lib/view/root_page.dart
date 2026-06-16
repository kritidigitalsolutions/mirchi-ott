import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mirchi_ott/view/homePages/mainHomepage.dart';
import 'package:mirchi_ott/view/splash/splashScreen.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  static bool splashShown = false;

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  late bool _isSplash;

  @override
  void initState() {
    super.initState();
    _isSplash = !RootPage.splashShown;
    if (_isSplash) {
      Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isSplash = false;
            RootPage.splashShown = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isSplash ? const SplashScreen(isWrapper: true) : const MainHomePage();
  }
}
