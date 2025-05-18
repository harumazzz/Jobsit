import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart'; // Required for NotificationType
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

class NotificationService {
  const NotificationService._();

  static void _showNotification({
    required BuildContext context,
    required String message,
    required NotificationType notificationType,
    required Color backgroundColor,
    required Color accentColor,
    required IconData iconData,
  }) async {
    ElegantNotification(
      height: 60.0,
      description: Text(
        message,
        style: TextStyle(color: accentColor, fontSize: 14, fontWeight: FontWeight.w500),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      icon: _CustomIcon(iconData: iconData, iconColor: Colors.white, lineColor: accentColor),
      background: backgroundColor,
      progressIndicatorColor: accentColor,
      progressIndicatorBackground: backgroundColor,
      borderRadius: BorderRadius.circular(16.0),
      toastDuration: const Duration(seconds: 5),
      border: Border.all(color: accentColor),
      closeButton:
          (onDismiss) => IconButton(
            padding: const EdgeInsets.only(right: 8.0),
            constraints: const BoxConstraints(),
            icon: Icon(Icons.close_outlined, color: accentColor, size: 20),
            onPressed: onDismiss,
          ),
      animation: AnimationType.fromTop,
      animationDuration: const Duration(milliseconds: 500),
    ).show(context);
  }

  static void success({required BuildContext context, required String message}) {
    _showNotification(
      context: context,
      message: message,
      notificationType: NotificationType.success,
      backgroundColor: const Color(0xFFDEF2ED),
      accentColor: const Color(0xFF00B074),
      iconData: IconlyLight.infoSquare,
    );
  }

  static void error({required BuildContext context, required String message}) {
    _showNotification(
      context: context,
      message: message,
      notificationType: NotificationType.error,
      backgroundColor: const Color(0xFFFCE8DB),
      accentColor: const Color(0xFFEF665B),
      iconData: IconlyLight.infoSquare,
    );
  }

  static void info({required BuildContext context, required String message}) {
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

class _CustomIcon extends StatelessWidget {
  const _CustomIcon({required this.iconData, required this.iconColor, required this.lineColor});

  final IconData iconData;

  final Color iconColor;

  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(backgroundColor: lineColor, radius: 20.0, child: Icon(iconData, color: iconColor, size: 20.0));
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<IconData>('iconData', iconData));
    properties.add(ColorProperty('iconColor', iconColor));
    properties.add(ColorProperty('lineColor', lineColor));
  }
}
