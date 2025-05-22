import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart'; // Required for NotificationType
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

/// A utility class for displaying styled notifications (toasts).
///
/// This class provides static methods to show success, error, and info
/// notifications using the `ElegantNotification` package. It is not
/// meant to be instantiated.
class NotificationService {
  /// Private constructor to prevent instantiation.
  const NotificationService._();

  /// Displays an `ElegantNotification` with the specified parameters.
  ///
  /// This is a private helper method used by the public static methods.
  static Future<void> _showNotification({
    required final BuildContext context,
    required final String message,
    required final NotificationType notificationType,
    required final Color backgroundColor,
    required final Color accentColor,
    required final IconData iconData,
  }) async {
    ElegantNotification(
      description: Text(
        message,
        style: TextStyle(color: accentColor, fontWeight: FontWeight.w500),
      ),
      icon: _CustomIcon(
        iconData: iconData,
        iconColor: Colors.white,
        lineColor: accentColor,
      ),
      background: backgroundColor,
      progressIndicatorColor: accentColor,
      progressIndicatorBackground: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      toastDuration: const Duration(seconds: 5),
      border: Border.all(color: accentColor),
      closeButton:
          (final onDismiss) => IconButton(
            padding: const EdgeInsets.only(right: 8),
            constraints: const BoxConstraints(),
            icon: Icon(Icons.close_outlined, color: accentColor, size: 20),
            onPressed: onDismiss,
          ),
      animation: AnimationType.fromTop,
      animationDuration: const Duration(milliseconds: 500),
    ).show(context);
  }

  /// Shows a success notification.
  ///
  /// [context] The build context.
  /// [message] The message to display.
  static void success({
    required final BuildContext context,
    required final String message,
  }) {
    _showNotification(
      context: context,
      message: message,
      notificationType: NotificationType.success,
      backgroundColor: const Color(0xFFDEF2ED),
      accentColor: const Color(0xFF00B074),
      iconData: IconlyLight.infoSquare,
    );
  }

  /// Shows an error notification.
  ///
  /// [context] The build context.
  /// [message] The message to display.
  static void error({
    required final BuildContext context,
    required final String message,
  }) {
    _showNotification(
      context: context,
      message: message,
      notificationType: NotificationType.error,
      backgroundColor: const Color(0xFFFCE8DB),
      accentColor: const Color(0xFFEF665B),
      iconData: IconlyLight.infoSquare,
    );
  }

  /// Shows an informational notification.
  ///
  /// [context] The build context.
  /// [message] The message to display.
  static void info({
    required final BuildContext context,
    required final String message,
  }) {
    _showNotification(
      context: context,
      message: message,
      notificationType: NotificationType.info,
      backgroundColor: const Color(0xFFD7F1FD),
      accentColor: const Color(0xFF509AF8),
      iconData: IconlyLight.infoSquare,
    );
  }
}

/// A custom icon widget used within the `ElegantNotification`.
///
/// Displays a circular avatar with an icon, styled with a specific
/// background color for the circle (lineColor) and icon color.
class _CustomIcon extends StatelessWidget {
  /// Creates a [_CustomIcon].
  ///
  /// [iconData] The icon to display.
  /// [iconColor] The color of the icon.
  /// [lineColor] The background color of the circle surrounding the icon.
  const _CustomIcon({
    required this.iconData,
    required this.iconColor,
    required this.lineColor,
  });

  /// The icon to be displayed.
  final IconData iconData;

  /// The color of the [iconData].
  final Color iconColor;

  /// The background color of the circular avatar.
  final Color lineColor;

  @override
  Widget build(final BuildContext context) => CircleAvatar(
    backgroundColor: lineColor,
    radius: 20,
    child: Icon(
      iconData,
      color: iconColor,
      size: 20,
    ),
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<IconData>('iconData', iconData))
      ..add(ColorProperty('iconColor', iconColor))
      ..add(ColorProperty('lineColor', lineColor));
  }
}
