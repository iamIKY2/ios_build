import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Explicit startup logs only: do not collect HTTP bodies or credentials.
class RuntimeDiagnostics {
  static const enabled = bool.fromEnvironment('ENIGMA_DIAGNOSTICS');
  static final lines = ValueNotifier<List<String>>([]);

  static void log(String message) {
    if (!enabled) return;
    final entry = '${DateTime.now().toIso8601String()} $message';
    final updated = [...lines.value, entry];
    lines.value =
        updated.length > 200 ? updated.sublist(updated.length - 200) : updated;
    debugPrint(entry);
  }

  static void error(String stage, Object error, StackTrace? stack) {
    // The error message may contain user data. Keep its type and stack only.
    final code = error is PlatformException ? ' code=${error.code}' : '';
    log('$stage: ${error.runtimeType}$code\n${stack ?? ''}');
  }
}

/// Available even on the startup/error screen, without needing navigation.
class DiagnosticsOverlay extends StatefulWidget {
  const DiagnosticsOverlay({super.key, required this.child});
  final Widget child;

  @override
  State<DiagnosticsOverlay> createState() => _DiagnosticsOverlayState();
}

class _DiagnosticsOverlayState extends State<DiagnosticsOverlay> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    if (!RuntimeDiagnostics.enabled) return widget.child;
    return Overlay.wrap(
        child: Stack(
      children: [
        widget.child,
        Positioned(
          right: 12,
          bottom: MediaQuery.paddingOf(context).bottom + 12,
          child: _open
              ? Material(
                  elevation: 12,
                  color: const Color(0xFF202124),
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: (MediaQuery.sizeOf(context).width - 24)
                        .clamp(0.0, 600.0),
                    height: MediaQuery.sizeOf(context).height * 0.55,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text('Startup debug',
                                  style: TextStyle(color: Colors.white)),
                            ),
                            IconButton(
                              tooltip: 'Sao chép log',
                              color: Colors.white,
                              icon: const Icon(Icons.copy),
                              onPressed: () => Clipboard.setData(ClipboardData(
                                text: RuntimeDiagnostics.lines.value.join('\n'),
                              )),
                            ),
                            IconButton(
                              tooltip: 'Đóng debug',
                              color: Colors.white,
                              icon: const Icon(Icons.close),
                              onPressed: () => setState(() => _open = false),
                            ),
                          ],
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(12),
                            child: ValueListenableBuilder<List<String>>(
                              valueListenable: RuntimeDiagnostics.lines,
                              builder: (context, lines, child) =>
                                  SelectableText(
                                lines.join('\n'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : FilledButton.icon(
                  onPressed: () => setState(() => _open = true),
                  icon: const Icon(Icons.bug_report),
                  label: const Text('Debug'),
                ),
        ),
      ],
    ));
  }
}
