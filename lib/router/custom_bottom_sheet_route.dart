import 'package:flutter/material.dart';

Future<T?> showCustomBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  String? barrierLabel,
  ShapeBorder? shape,
  Clip? clipBehavior,
  BoxConstraints? constraints,
  bool isScrollControlled = false,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
  bool useSafeArea = false,
  RouteSettings? routeSettings,
}) {
  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  final localizations = MaterialLocalizations.of(context);

  return navigator.push(
    BottomSheetRoute<T>(
      builder: builder,
      capturedThemes: InheritedTheme.capture(
        from: context,
        to: navigator.context,
      ),

      isScrollControlled: isScrollControlled,
      barrierLabel: barrierLabel ?? localizations.scrimLabel,
      barrierOnTapHint: localizations.scrimOnTapHint(
        localizations.bottomSheetLabel,
      ),

      shape: shape,
      clipBehavior: clipBehavior,
      constraints: constraints,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      settings: routeSettings,
    ),
  );
}

class BottomSheetRoute<T> extends ModalBottomSheetRoute<T> {
  BottomSheetRoute({
    required super.builder,
    required super.isScrollControlled,
    super.capturedThemes,
    super.barrierLabel,
    super.barrierOnTapHint,
    super.shape,
    super.clipBehavior,
    super.constraints,
    super.isDismissible = true,
    super.enableDrag = true,
    super.settings,
  }) : super(
         backgroundColor: Colors.transparent,
         sheetAnimationStyle: AnimationStyle(
           duration: const Duration(milliseconds: 200),
           reverseDuration: const Duration(milliseconds: 200),
         ),
       );

  @override
  Widget buildModalBarrier() {
    return Builder(
      builder: (context) {
        final barrierColor = Colors.black54;

        final color = animation!.drive(
          ColorTween(
            begin: barrierColor.withAlpha(0),
            end: barrierColor,
          ).chain(CurveTween(curve: barrierCurve)),
        );

        return AnimatedModalBarrier(
          color: color,
          dismissible: barrierDismissible,
          semanticsLabel: barrierLabel,
          barrierSemanticsDismissible: semanticsDismissible,
        );
      },
    );
  }
}
