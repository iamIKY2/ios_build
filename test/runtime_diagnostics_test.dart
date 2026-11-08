import 'package:enigma/core/startup/runtime_diagnostics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => RuntimeDiagnostics.lines.value = []);

  test('log collection follows the build flag and bounds retained entries', () {
    for (var i = 0; i < 205; i++) {
      RuntimeDiagnostics.log('step $i');
    }
    if (RuntimeDiagnostics.enabled) {
      expect(RuntimeDiagnostics.lines.value.length, 200);
      expect(RuntimeDiagnostics.lines.value.first, endsWith('step 5'));
    } else {
      expect(RuntimeDiagnostics.lines.value, isEmpty);
    }
  });

  test('records platform error code without credentials in its message', () {
    RuntimeDiagnostics.error('Storage',
        PlatformException(code: '-34018', message: 'secret-token'), null);
    final log = RuntimeDiagnostics.lines.value.join('\n');
    expect(log, isNot(contains('secret-token')));
    if (RuntimeDiagnostics.enabled) expect(log, contains('code=-34018'));
  });

  testWidgets('debug panel displays and copies startup logs', (tester) async {
    String? clipboard;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          clipboard = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    RuntimeDiagnostics.log('Storage: ready');
    await tester.pumpWidget(MaterialApp(
      builder: (_, child) => DiagnosticsOverlay(child: child!),
      home: const Scaffold(body: Text('App')),
    ));
    if (!RuntimeDiagnostics.enabled) {
      expect(find.text('Debug'), findsNothing);
      return;
    }
    await tester.tap(find.text('Debug'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Storage: ready'), findsOneWidget);
    await tester.tap(find.byTooltip('Sao chép log'));
    await tester.pump();
    expect(clipboard, contains('Storage: ready'));
    await tester.tap(find.byTooltip('Đóng debug'));
    await tester.pumpAndSettle();
    expect(find.text('Debug'), findsOneWidget);
  });
}
