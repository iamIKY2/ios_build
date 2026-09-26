import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const IOSHelloWorldApp());
}

/// Root Cupertino Application
class IOSHelloWorldApp extends StatefulWidget {
  const IOSHelloWorldApp({super.key});

  @override
  State<IOSHelloWorldApp> createState() => _IOSHelloWorldAppState();
}

class _IOSHelloWorldAppState extends State<IOSHelloWorldApp> {
  Brightness _brightness = Brightness.light;
  bool _useIPhoneFrame = !kIsWeb && defaultTargetPlatform != TargetPlatform.iOS && defaultTargetPlatform != TargetPlatform.android;

  void _toggleTheme() {
    setState(() {
      _brightness = _brightness == Brightness.light ? Brightness.dark : Brightness.light;
    });
  }

  void _toggleFrame() {
    setState(() {
      _useIPhoneFrame = !_useIPhoneFrame;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoThemeData(
      brightness: _brightness,
      primaryColor: const Color(0xFF007AFF), // Apple System Blue
      scaffoldBackgroundColor: _brightness == Brightness.dark
          ? const Color(0xFF000000)
          : const Color(0xFFF2F2F7), // iOS Grouped Background
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          color: _brightness == Brightness.dark ? CupertinoColors.white : CupertinoColors.black,
        ),
      ),
    );

    return CupertinoApp(
      title: 'Hello World iOS',
      debugShowCheckedModeBanner: false,
      theme: cupertinoTheme,
      home: _useIPhoneFrame
          ? IPhoneFrameWrapper(
              onToggleFrame: _toggleFrame,
              child: IOSHomeScreen(
                brightness: _brightness,
                onToggleTheme: _toggleTheme,
                onToggleFrame: _toggleFrame,
                isFramed: true,
              ),
            )
          : IOSHomeScreen(
              brightness: _brightness,
              onToggleTheme: _toggleTheme,
              onToggleFrame: _toggleFrame,
              isFramed: false,
            ),
    );
  }
}

/// Simulated iPhone 16 Pro Frame for Windows / Web preview
class IPhoneFrameWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback onToggleFrame;

  const IPhoneFrameWrapper({
    super.key,
    required this.child,
    required this.onToggleFrame,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1C1C1E),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background subtle hint
          Positioned(
            top: 20,
            right: 20,
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(20),
              onPressed: onToggleFrame,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.fullscreen, size: 16, color: CupertinoColors.white),
                  SizedBox(width: 6),
                  Text('Xem toàn màn hình', style: TextStyle(fontSize: 13, color: CupertinoColors.white)),
                ],
              ),
            ),
          ),
          // iPhone Frame
          Center(
            child: Container(
              width: 393,
              height: 852,
              decoration: BoxDecoration(
                color: CupertinoColors.black,
                borderRadius: BorderRadius.circular(55),
                border: Border.all(color: const Color(0xFF3A3A3C), width: 7),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x99000000),
                    blurRadius: 40,
                    spreadRadius: 8,
                    offset: Offset(0, 15),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(48),
                child: Stack(
                  children: [
                    child,
                    // Home Indicator bar
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 140,
                          height: 5,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Primary iOS Home Screen
class IOSHomeScreen extends StatefulWidget {
  final Brightness brightness;
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleFrame;
  final bool isFramed;

  const IOSHomeScreen({
    super.key,
    required this.brightness,
    required this.onToggleTheme,
    required this.onToggleFrame,
    required this.isFramed,
  });

  @override
  State<IOSHomeScreen> createState() => _IOSHomeScreenState();
}

class _IOSHomeScreenState extends State<IOSHomeScreen> with TickerProviderStateMixin {
  int _selectedSegment = 0;
  int _currentGreetingIndex = 0;
  bool _islandExpanded = false;
  int _tapCount = 0;
  double _buttonScale = 1.0;

  // Particle explosion on tap
  final List<Particle> _particles = [];
  late AnimationController _particleController;

  final List<Map<String, String>> _greetings = [
    {
      'lang': 'Tiếng Việt',
      'flag': '🇻🇳',
      'title': 'Xin chào Thế giới!',
      'sub': 'Chào mừng bạn đến với trải nghiệm iOS tuyệt vời',
      'accent': '0xFFFF3B30', // Apple Red
    },
    {
      'lang': 'English',
      'flag': '🇺🇸',
      'title': 'Hello, World!',
      'sub': 'Crafted with Apple Human Interface Guidelines',
      'accent': '0xFF007AFF', // Apple Blue
    },
    {
      'lang': '日本語 (Japanese)',
      'flag': '🇯🇵',
      'title': 'こんにちは、世界！',
      'sub': '洗練された Cupertino デザインとアニメーション',
      'accent': '0xFFFF2D55', // Apple Pink
    },
    {
      'lang': 'Français',
      'flag': '🇫🇷',
      'title': 'Bonjour le monde !',
      'sub': 'Une élégance fluide et moderne sur iOS',
      'accent': '0xFF5856D6', // Apple Purple
    },
    {
      'lang': '한국어 (Korean)',
      'flag': '🇰🇷',
      'title': '안녕하세요, 세상!',
      'sub': '아름다운 iOS 경험에 오신 것을 환영합니다',
      'accent': '0xFF34C759', // Apple Green
    },
    {
      'lang': 'Español',
      'flag': '🇪🇸',
      'title': '¡Hola, Mundo!',
      'sub': 'Diseñado con precisión y estilo Cupertino',
      'accent': '0xFFFF9500', // Apple Orange
    },
  ];

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..addListener(() {
        setState(() {
          for (final p in _particles) {
            p.update();
          }
          _particles.removeWhere((p) => p.life <= 0);
        });
      });
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  void _triggerHaptic() {
    HapticFeedback.lightImpact();
  }

  void _spawnParticles(Offset origin) {
    _triggerHaptic();
    final random = math.Random();
    const particleColors = [
      Color(0xFF007AFF),
      Color(0xFFFF2D55),
      Color(0xFFFF9500),
      Color(0xFF34C759),
      Color(0xFFAF52DE),
      Color(0xFFFFCC00),
    ];

    for (int i = 0; i < 24; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final speed = 2.0 + random.nextDouble() * 5.0;
      final color = particleColors[random.nextInt(particleColors.length)];
      _particles.add(
        Particle(
          x: origin.dx,
          y: origin.dy,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed,
          size: 4 + random.nextDouble() * 6,
          color: color,
        ),
      );
    }

    _particleController.reset();
    _particleController.forward();
  }

  void _nextGreeting() {
    _triggerHaptic();
    setState(() {
      _currentGreetingIndex = (_currentGreetingIndex + 1) % _greetings.length;
      _tapCount++;
    });
  }

  void _showIOSActionSheet(BuildContext context) {
    _triggerHaptic();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('iOS Hello World Pro', style: TextStyle(fontWeight: FontWeight.bold)),
        message: const Text('Ứng dụng được thiết kế theo Apple Human Interface Guidelines với Flutter và Cupertino.'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
              widget.onToggleTheme();
            },
            child: Text(widget.brightness == Brightness.light ? 'Chuyển sang Giao diện Tối 🌙' : 'Chuyển sang Giao diện Sáng ☀️'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              widget.onToggleFrame();
            },
            child: Text(widget.isFramed ? 'Tắt Khung iPhone (Toàn màn hình)' : 'Bật Khung iPhone 16 Pro'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _tapCount = 0;
                _currentGreetingIndex = 0;
              });
            },
            child: const Text('Đặt lại Lượt Tương Tác'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.brightness == Brightness.dark;
    final currentGreeting = _greetings[_currentGreetingIndex];
    final accentColor = Color(int.parse(currentGreeting['accent']!));

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: (isDark ? const Color(0xCC000000) : const Color(0xCCF9F9F9)),
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0x22FFFFFF) : const Color(0x22000000),
            width: 0.5,
          ),
        ),
        middle: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.sparkles, size: 16, color: Color(0xFF007AFF)),
            SizedBox(width: 6),
            Text(
              'iOS 18 Experience',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _showIOSActionSheet(context),
          child: const Icon(CupertinoIcons.ellipsis_circle, size: 24),
        ),
      ),
      child: Stack(
        children: [
          // Dynamic gradient background orbs
          Positioned(
            top: -60,
            left: -40,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accentColor.withOpacity(isDark ? 0.35 : 0.25),
                    accentColor.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -60,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF5856D6).withOpacity(isDark ? 0.3 : 0.2),
                    const Color(0xFF5856D6).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          // Main Scrollable Area
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Dynamic Island interactive pill
                        _buildDynamicIsland(isDark),
                        const SizedBox(height: 18),

                        // Cupertino Segmented Control
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoSlidingSegmentedControl<int>(
                            groupValue: _selectedSegment,
                            thumbColor: isDark ? const Color(0xFF3A3A3C) : CupertinoColors.white,
                            backgroundColor: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFE5E5EA),
                            children: {
                              0: _buildSegmentItem('🌍 Đa ngôn ngữ', 0),
                              1: _buildSegmentItem('✨ Tương tác', 1),
                              2: _buildSegmentItem('🍎 iOS HIG', 2),
                            },
                            onValueChanged: (val) {
                              if (val != null) {
                                _triggerHaptic();
                                setState(() => _selectedSegment = val);
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Body depending on selected segment
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          child: _selectedSegment == 0
                              ? _buildMultilingualCard(currentGreeting, accentColor, isDark)
                              : _selectedSegment == 1
                                  ? _buildInteractiveLab(accentColor, isDark)
                                  : _buildIOSSpecsCard(isDark),
                        ),

                        const SizedBox(height: 24),

                        // Stats & Cupertino quick badge cards
                        _buildQuickStatsBar(isDark),
                        const SizedBox(height: 24),

                        // Quick action buttons
                        Row(
                          children: [
                            Expanded(
                              child: CupertinoButton(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                color: isDark ? const Color(0xFF2C2C2E) : CupertinoColors.white,
                                borderRadius: BorderRadius.circular(16),
                                onPressed: widget.onToggleTheme,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isDark ? CupertinoIcons.sun_max_fill : CupertinoIcons.moon_fill,
                                      size: 18,
                                      color: isDark ? const Color(0xFFFFD60A) : const Color(0xFF5856D6),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isDark ? 'Chế độ Sáng' : 'Chế độ Tối',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? CupertinoColors.white : CupertinoColors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CupertinoButton.filled(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                borderRadius: BorderRadius.circular(16),
                                onPressed: () => _showIOSActionSheet(context),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(CupertinoIcons.slider_horizontal_3, size: 18),
                                    SizedBox(width: 8),
                                    Text('Tùy chỉnh iOS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Particle canvas layer
          IgnorePointer(
            child: CustomPaint(
              size: Size.infinite,
              painter: ParticlePainter(_particles),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentItem(String title, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: _selectedSegment == index ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  /// Interactive Dynamic Island
  Widget _buildDynamicIsland(bool isDark) {
    return GestureDetector(
      onTap: () {
        _triggerHaptic();
        setState(() => _islandExpanded = !_islandExpanded);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutBack,
        width: _islandExpanded ? 340 : 190,
        height: _islandExpanded ? 84 : 36,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: CupertinoColors.black,
          borderRadius: BorderRadius.circular(_islandExpanded ? 24 : 20),
          border: Border.all(
            color: const Color(0xFF333333),
            width: 0.8,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: _islandExpanded
            ? Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                      ),
                    ),
                    child: const Icon(CupertinoIcons.globe, color: CupertinoColors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dynamic Island Active',
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Flutter Engine 3.47 • iOS 18 Design',
                          style: TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(CupertinoIcons.waveform, color: Color(0xFF34C759), size: 22),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(CupertinoIcons.sparkles, size: 14, color: Color(0xFFFF9500)),
                      SizedBox(width: 6),
                      Text(
                        'Hello, iOS!',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text('', style: TextStyle(color: CupertinoColors.white, fontSize: 14)),
                ],
              ),
      ),
    );
  }

  /// Segment 0: Multilingual Hero Card with Frosted Glass
  Widget _buildMultilingualCard(Map<String, String> greeting, Color accentColor, bool isDark) {
    return Container(
      key: ValueKey<int>(_currentGreetingIndex),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xDD1C1C1E) : const Color(0xE6FFFFFF),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: accentColor.withOpacity(0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.18),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.all(26.0),
            child: Column(
              children: [
                // Top Tag
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Text(greeting['flag']!, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            greeting['lang']!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${_currentGreetingIndex + 1} / ${_greetings.length}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF6C6C70),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Main Giant Greeting Typography
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    color: isDark ? CupertinoColors.white : CupertinoColors.black,
                  ),
                  textAlign: TextAlign.center,
                  child: Text(greeting['title']!),
                ),
                const SizedBox(height: 12),
                Text(
                  greeting['sub']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? const Color(0xFFAAAAAA) : const Color(0xFF666666),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 28),

                // Interactive iOS Spring Button
                GestureDetector(
                  onTapDown: (_) => setState(() => _buttonScale = 0.94),
                  onTapUp: (details) {
                    setState(() => _buttonScale = 1.0);
                    _spawnParticles(details.globalPosition);
                    _nextGreeting();
                  },
                  onTapCancel: () => setState(() => _buttonScale = 1.0),
                  child: AnimatedScale(
                    scale: _buttonScale,
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOutCubic,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accentColor,
                            accentColor.withBlue((accentColor.blue + 30).clamp(0, 255)),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.4),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.paperplane_fill, color: CupertinoColors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Chạm để Khám Phá Tiếp',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Segment 1: Interactive Touch Lab
  Widget _buildInteractiveLab(Color accentColor, bool isDark) {
    return Container(
      key: const ValueKey('interactive_lab'),
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xDD1C1C1E) : const Color(0xE6FFFFFF),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? const Color(0x22FFFFFF) : const Color(0x11000000),
        ),
      ),
      child: Column(
        children: [
          const Icon(CupertinoIcons.wand_stars_inverse, size: 40, color: Color(0xFFFF9500)),
          const SizedBox(height: 12),
          Text(
            'Phòng Thí Nghiệm Cảm Ứng iOS',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? CupertinoColors.white : CupertinoColors.black,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Chạm bất kỳ đâu vào ô dưới để kích hoạt hiệu ứng hạt pháo hoa (Particle Cannon) và rung phản hồi Haptic.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: CupertinoColors.systemGrey),
          ),
          const SizedBox(height: 20),

          // Interactive Touch Surface
          GestureDetector(
            onTapDown: (details) {
              _spawnParticles(details.globalPosition);
              setState(() => _tapCount++);
            },
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF2C2C2E), const Color(0xFF1C1C1E)]
                      : [const Color(0xFFE5E5EA), const Color(0xFFF2F2F7)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF007AFF).withOpacity(0.4), width: 1.5),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(CupertinoIcons.hand_point_left, size: 32, color: Color(0xFF007AFF)),
                      const SizedBox(height: 8),
                      Text(
                        'Chạm vào đây!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? CupertinoColors.white : CupertinoColors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Đã kích hoạt: $_tapCount lần',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF007AFF), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Segment 2: Apple HIG Specifications Card
  Widget _buildIOSSpecsCard(bool isDark) {
    return Container(
      key: const ValueKey('ios_specs'),
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xDD1C1C1E) : const Color(0xE6FFFFFF),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? const Color(0x22FFFFFF) : const Color(0x11000000),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(CupertinoIcons.device_phone_portrait, color: Color(0xFF007AFF), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Apple HIG Architecture',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? CupertinoColors.white : CupertinoColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSpecRow(CupertinoIcons.layers, 'Thiết kế giao diện', 'Cupertino iOS 18 Design Tokens', isDark),
          _buildSpecRow(CupertinoIcons.drop, 'Hiệu ứng Frosted Glass', 'BackdropFilter Gaussian Blur (20pt)', isDark),
          _buildSpecRow(CupertinoIcons.sparkles, 'Phản hồi xúc giác', 'UIFeedbackGenerator / Haptic Engine', isDark),
          _buildSpecRow(CupertinoIcons.rectangle_3_offgrid, 'Khung hiển thị', 'Adaptive SafeArea & Dynamic Island', isDark),
          _buildSpecRow(CupertinoIcons.bolt_horizontal, 'Công nghệ nền tảng', 'Flutter 3.47 + Swift Runner', isDark),
        ],
      ),
    );
  }

  Widget _buildSpecRow(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF007AFF)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? CupertinoColors.white : CupertinoColors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Stats bar (Total taps, language index, status)
  Widget _buildQuickStatsBar(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            title: 'Lượt Tương Tác',
            value: '$_tapCount',
            icon: CupertinoIcons.heart_fill,
            color: const Color(0xFFFF2D55),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile(
            title: 'Ngôn Ngữ',
            value: '${_greetings.length}',
            icon: CupertinoIcons.globe,
            color: const Color(0xFF007AFF),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile(
            title: 'Trạng Thái',
            value: 'Sẵn Sàng',
            icon: CupertinoIcons.checkmark_seal_fill,
            color: const Color(0xFF34C759),
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : CupertinoColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0x22FFFFFF) : const Color(0x11000000),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? CupertinoColors.white : CupertinoColors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 10, color: CupertinoColors.systemGrey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Particle model for explosion animations
class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  Color color;
  double life = 1.0;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
  });

  void update() {
    x += vx;
    y += vy;
    vy += 0.15; // Gravity
    vx *= 0.98;
    life -= 0.035;
  }
}

/// CustomPainter for particle effects
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      if (p.life > 0) {
        final paint = Paint()
          ..color = p.color.withOpacity(p.life.clamp(0.0, 1.0))
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(p.x, p.y), p.size * p.life, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}
