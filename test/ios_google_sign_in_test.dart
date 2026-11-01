import 'package:enigma/state/auth_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('iOS without OAuth configuration stops before calling Google SDK', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    const channel = MethodChannel('enigma/ios_configuration');
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'isGoogleSignInConfigured');
      return false;
    });
    final auth = AuthState();
    addTearDown(() {
      debugDefaultTargetPlatformOverride = null;
      messenger.setMockMethodCallHandler(channel, null);
      auth.dispose();
    });

    expect(await auth.loginWithGoogle(), isFalse);
    expect(auth.isLoading, isFalse);
    expect(auth.isAuthenticated, isFalse);
    expect(auth.error, contains('chưa được cấu hình trên iOS'));
  });
}
