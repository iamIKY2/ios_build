import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/utils/storage.dart';
import 'core/api/api_client.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/reminder_service.dart';
import 'core/services/sync_service.dart';
import 'core/startup/app_bootstrap.dart';
import 'theme/app_theme.dart';
import 'app.dart';

/// Global navigator key để ApiClient có thể điều hướng về LoginScreen
/// khi refresh token hết hạn (không cần BuildContext).
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Khi sao lưu dữ liệu hoàn tất, tự động gửi thông báo đến thanh thông báo của điện thoại
  SyncService.instance.onSyncCompleted = (message) {
    PushNotificationService.showNotification(
      title: '☁️ Sao lưu dữ liệu thành công',
      body: message,
    );
  };

  // Kết nối callback: khi cả refresh token hết hạn → tự động về LoginScreen
  ApiClient.onUnauthorized = () {
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (_) => false);
  };

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.bgSurface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    AppBootstrap(
      initialize: () async {
        await StorageUtil.init();
        ApiClient.init();
      },
      builder: (_) => EnigmaApp(navigatorKey: navigatorKey),
      onReady: () {
        // Network, APNs and notification permission must never gate the first UI.
        unawaited(
          _initializeOptionalService('Sync', SyncService.instance.init),
        );
        unawaited(_initializeNotifications());
      },
    ),
  );
}

Future<void> _initializeNotifications() async {
  // These plugins share local notification initialization: keep the order.
  await _initializeOptionalService('Push', PushNotificationService.init);
  await _initializeOptionalService('Reminders', ReminderService.init);
}

Future<void> _initializeOptionalService(
  String name,
  Future<void> Function() initialize,
) async {
  try {
    await initialize().timeout(const Duration(seconds: 15));
  } catch (error, stack) {
    debugPrint('[Startup] $name unavailable: $error\n$stack');
  }
}
