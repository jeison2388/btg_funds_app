import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';

/// Mensajes de feedback estandarizados (éxito, error, info, eliminación).
abstract class AppFeedback {
  AppFeedback._();

  static const Duration _duration = Duration(seconds: 5);
  static const Brightness _brightness = Brightness.light;
  static const DesktopSnackBarPosition _desktopPosition =
      DesktopSnackBarPosition.topRight;

  static const String _titleError = 'Error';
  static const String _titleSuccess = 'Acción completada';
  static const String _titleInfo = 'Información';
  static const String _titleDelete = 'Eliminado';

  static void alertToastError(
    BuildContext context,
    String message, {
    String? title,
  }) {
    AnimatedSnackBar.rectangle(
      title ?? _titleError,
      message,
      type: AnimatedSnackBarType.error,
      brightness: _brightness,
      duration: _duration,
      desktopSnackBarPosition: _desktopPosition,
    ).show(context);
  }

  static void alertToastDelete(BuildContext context, String message) {
    AnimatedSnackBar.rectangle(
      _titleDelete,
      message,
      type: AnimatedSnackBarType.error,
      brightness: _brightness,
      duration: _duration,
      desktopSnackBarPosition: _desktopPosition,
    ).show(context);
  }

  static void alertToastSuccess(BuildContext context, String message) {
    AnimatedSnackBar.rectangle(
      _titleSuccess,
      message,
      type: AnimatedSnackBarType.success,
      brightness: _brightness,
      duration: _duration,
      desktopSnackBarPosition: _desktopPosition,
    ).show(context);
  }

  static void alertToastInfo(
    BuildContext context,
    String message, {
    String? title,
  }) {
    AnimatedSnackBar.rectangle(
      title ?? _titleInfo,
      message,
      type: AnimatedSnackBarType.info,
      brightness: _brightness,
      duration: _duration,
      desktopSnackBarPosition: _desktopPosition,
    ).show(context);
  }
}
