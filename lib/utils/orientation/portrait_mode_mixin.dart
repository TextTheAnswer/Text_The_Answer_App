import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// Forces portrait-only mode on a specific screen
/// Use this Mixin in the specific screen you want to
/// block to portrait only mode.
///
/// Call `super.build(context)` in the State's build() method
/// and `super.dispose();` in the State's dispose() method
mixin PortraitStatefulModeMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    _portraitModeOnly();
  }

  @override
  void dispose() {
    _enableRotation();
    super.dispose();
  }
}

/// Blocks rotation; sets orientation to: portrait
void _portraitModeOnly() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

void _enableRotation() {
  SystemChrome.setPreferredOrientations(DeviceOrientation.values);
}
