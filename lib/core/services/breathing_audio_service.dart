import 'dart:math' as math;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Dịch vụ phát âm thanh và phản hồi rung cho màn hình tập thở (Box Breathing)
class BreathingAudioService {
  static final BreathingAudioService _instance = BreathingAudioService._internal();
  factory BreathingAudioService() => _instance;
  BreathingAudioService._internal() {
    _initAudio();
  }

  AudioPlayer? _tickPlayer;
  AudioPlayer? _chimePlayer;
  
  Uint8List? _tickWav;
  Uint8List? _chimeWav;
  Uint8List? _completeWav;


  void _initAudio() {
    try {
      _tickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
      _chimePlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

      // Tạo trước các mẫu âm thanh chuẩn WAV trong bộ nhớ để phát ngay lập tức không có độ trễ
      _tickWav = _generateTickWav();
      _chimeWav = _generateChimeWav();
      _completeWav = _generateCompleteWav();

    } catch (e) {
      debugPrint('Error initializing BreathingAudioService: $e');
    }
  }

  /// Phát tiếng tích tắc nhẹ nhàng theo từng giây đếm ngược
  Future<void> playTick({bool enableHaptic = true}) async {
    if (enableHaptic) {
      HapticFeedback.selectionClick();
    }
    
    try {
      if (_tickWav != null && _tickPlayer != null) {
        await _tickPlayer?.stop();
        await _tickPlayer?.play(BytesSource(_tickWav!), mode: PlayerMode.lowLatency);
      } else {
        await SystemSound.play(SystemSoundType.click);
      }
    } catch (_) {
      await SystemSound.play(SystemSoundType.click);
    }
  }

  /// Phát âm thanh chuông thanh tịnh khi chuyển giai đoạn thở (Hít vào, Giữ hơi, Thở ra, Thư giãn)
  Future<void> playPhaseChange({bool enableHaptic = true}) async {
    if (enableHaptic) {
      HapticFeedback.mediumImpact();
    }

    try {
      if (_chimeWav != null && _chimePlayer != null) {
        await _chimePlayer?.stop();
        await _chimePlayer?.play(BytesSource(_chimeWav!), mode: PlayerMode.lowLatency);
      } else {
        await SystemSound.play(SystemSoundType.click);
      }
    } catch (_) {
      await SystemSound.play(SystemSoundType.click);
    }
  }

  /// Phát chuông hoàn thành buổi thở
  Future<void> playComplete({bool enableHaptic = true}) async {
    if (enableHaptic) {
      HapticFeedback.heavyImpact();
    }

    try {
      if (_completeWav != null && _chimePlayer != null) {
        await _chimePlayer?.stop();
        await _chimePlayer?.play(BytesSource(_completeWav!), mode: PlayerMode.lowLatency);
      }
    } catch (_) {}
  }

  /// Dọn dẹp tài nguyên
  void dispose() {
    _tickPlayer?.dispose();
    _chimePlayer?.dispose();
  }

  // ===================== BỘ TẠO FILE ÂM THANH SÓNG WAV (16-bit PCM Mono) =====================

  /// Tạo âm thanh 'tick' gỗ nhẹ, trầm ấm cho mỗi giây (tần số 750Hz với độ suy giảm nhanh 50ms)
  static Uint8List _generateTickWav() {
    const int sampleRate = 44100;
    const double duration = 0.06; // 60ms
    const double frequency = 750.0;
    final int numSamples = (sampleRate * duration).round();
    final Int16List samples = Int16List(numSamples);

    for (int i = 0; i < numSamples; i++) {
      final double t = i / sampleRate;
      final double envelope = math.exp(-t * 70.0);
      final double wave = math.sin(2.0 * math.pi * frequency * t);
      final double value = wave * envelope * 0.45;
      samples[i] = (value * 32767).clamp(-32768, 32767).toInt();
    }

    return _createWav(samples, sampleRate);
  }

  /// Tạo tiếng chuông thiền Solfeggio 528Hz ngân vang nhẹ nhàng khi chuyển nhịp
  static Uint8List _generateChimeWav() {
    const int sampleRate = 44100;
    const double duration = 1.2; // 1.2 giây
    final int numSamples = (sampleRate * duration).round();
    final Int16List samples = Int16List(numSamples);

    for (int i = 0; i < numSamples; i++) {
      final double t = i / sampleRate;
      // Fade in nhẹ đầu 15ms để không bị tiếng pop
      final double fadeIn = (t / 0.015).clamp(0.0, 1.0);
      final double decay = math.exp(-t * 2.8);
      
      // Tổng hợp hòa âm chuông: 528Hz + 1056Hz + 1584Hz
      final double wave = 0.65 * math.sin(2.0 * math.pi * 528.0 * t) +
          0.25 * math.sin(2.0 * math.pi * 1056.0 * t) +
          0.10 * math.sin(2.0 * math.pi * 1584.0 * t);
          
      final double value = wave * fadeIn * decay * 0.4;
      samples[i] = (value * 32767).clamp(-32768, 32767).toInt();
    }

    return _createWav(samples, sampleRate);
  }

  /// Tạo chuông hợp âm kết thúc (528Hz + 660Hz + 792Hz)
  static Uint8List _generateCompleteWav() {
    const int sampleRate = 44100;
    const double duration = 1.8;
    final int numSamples = (sampleRate * duration).round();
    final Int16List samples = Int16List(numSamples);

    for (int i = 0; i < numSamples; i++) {
      final double t = i / sampleRate;
      final double fadeIn = (t / 0.02).clamp(0.0, 1.0);
      final double decay = math.exp(-t * 2.0);
      
      final double wave = 0.45 * math.sin(2.0 * math.pi * 528.0 * t) +
          0.35 * math.sin(2.0 * math.pi * 660.0 * t) +
          0.20 * math.sin(2.0 * math.pi * 792.0 * t);

      final double value = wave * fadeIn * decay * 0.45;
      samples[i] = (value * 32767).clamp(-32768, 32767).toInt();
    }

    return _createWav(samples, sampleRate);
  }

  /// Đóng gói PCM 16-bit Mono thành định dạng WAV chuẩn (RIFF)
  static Uint8List _createWav(Int16List samples, int sampleRate) {
    final int byteRate = sampleRate * 1 * 2; // sampleRate * channels * bytesPerSample
    final int subChunk2Size = samples.length * 2;
    final int chunkSize = 36 + subChunk2Size;

    final ByteData byteData = ByteData(44 + subChunk2Size);

    // RIFF header
    byteData.setUint8(0, 0x52); // 'R'
    byteData.setUint8(1, 0x49); // 'I'
    byteData.setUint8(2, 0x46); // 'F'
    byteData.setUint8(3, 0x46); // 'F'
    byteData.setUint32(4, chunkSize, Endian.little);
    byteData.setUint8(8, 0x57);  // 'W'
    byteData.setUint8(9, 0x41);  // 'A'
    byteData.setUint8(10, 0x56); // 'V'
    byteData.setUint8(11, 0x45); // 'E'

    // fmt subchunk
    byteData.setUint8(12, 0x66); // 'f'
    byteData.setUint8(13, 0x6D); // 'm'
    byteData.setUint8(14, 0x74); // 't'
    byteData.setUint8(15, 0x20); // ' '
    byteData.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
    byteData.setUint16(20, 1, Endian.little);  // AudioFormat (1 for PCM)
    byteData.setUint16(22, 1, Endian.little);  // NumChannels (1 = Mono)
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(28, byteRate, Endian.little);
    byteData.setUint16(32, 2, Endian.little);  // BlockAlign (NumChannels * BitsPerSample / 8)
    byteData.setUint16(34, 16, Endian.little); // BitsPerSample (16 bits)

    // data subchunk
    byteData.setUint8(36, 0x64); // 'd'
    byteData.setUint8(37, 0x61); // 'a'
    byteData.setUint8(38, 0x74); // 't'
    byteData.setUint8(39, 0x61); // 'a'
    byteData.setUint32(40, subChunk2Size, Endian.little);

    // Sample payload
    int offset = 44;
    for (int i = 0; i < samples.length; i++) {
      byteData.setInt16(offset, samples[i], Endian.little);
      offset += 2;
    }

    return byteData.buffer.asUint8List();
  }
}
