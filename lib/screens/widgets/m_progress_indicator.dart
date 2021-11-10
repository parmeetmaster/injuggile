import 'dart:async';

import 'package:flutter/material.dart';

class MProgressIndicator {
  static bool _isVisible = false;
  static OverlayEntry _overlayEntry;
static Timer timer;
  static Widget justIndicator = Center(
    child: Container(
      color: Colors.black12,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Colors.pink),
        ),
      ),
    ),
  );

  static bool show(
    BuildContext context,
  ) {
    if (_isVisible) {
      return false;
    }
    _isVisible = true;
    var overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Scaffold(
        backgroundColor: Colors.transparent,
        body: justIndicator,
      ),
    );
    overlayState?.insert(_overlayEntry);
    Timer.periodic(Duration(seconds: 30), (mtimer) {
      timer=mtimer;
      hide();
      timer.cancel();
    });

    return true;
  }

  static void hide() {
    if (_overlayEntry != null && _isVisible) {
      _overlayEntry.remove();
      _isVisible = false;
    }
  }
}
