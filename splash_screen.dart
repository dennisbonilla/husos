import 'dart:math' as math;
import 'package:flutter/material.dart';

const _bg = Color(0xFF0C1626);
const _brass = Color(0xFFC6A15B);
const _brassLight = Color(0xFFE4C782);
const _cream = Color(0xFFEDE7D6);
const _muted = Color(0xFF7C8AA8);
const _night = Color(0xFF6E86C8);

/// Pantalla de bienvenida: los dos relojes giran hasta sincronizarse
/// y aparece el crédito. Dura ~2.6 s y luego entra la app.
class SplashScreen extends StatefulWidget {
  final Widget next;
  const SplashScreen({super.key, required this.next});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _spin;
  late final AnimationController _fade;

  late final Animation<double> _dialTurn;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _titleSlide;
  late final Animation<double> _creditOpacity;
  late final Animation<double> _lineWidth;

  @override
  void initState() {
    super.initState();

    _spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    _dialTurn = CurvedAnimation(
      parent: _spin,
      curve: const Interval(0.0, 0.62, curve: Curves.easeOutQuart),
    );
    _titleOpacity = CurvedAnimation(
      parent: _spin,
      curve: const Interval(0.30, 0.58, curve: Curves.easeOut),
    );
    _titleSlide = Tween<double>(begin: 14, end: 0).animate(
      CurvedAnimation(
        parent: _spin,
        curve: const Interval(0.30, 0.62, curve: Curves.easeOutCubic),
      ),
    );
    _lineWidth = CurvedAnimation(
      parent: _spin,
      curve: const Interval(0.50, 0.78, curve: Curves.easeOutCubic),
    );
    _creditOpacity = CurvedAnimation(
      parent: _spin,
      curve: const Interval(0.60, 0.88, curve: Curves.easeOut),
    );

    _spin.forward();
    _spin.addStatusListener((s) async {
      if (s == AnimationStatus.completed) {
        await Future<void>.delayed(const Duration(milliseconds: 420));
        if (!mounted) return;
        await _fade.forward();
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 420),
            pageBuilder: (_, a, __) =>
                FadeTransition(opacity: a, child: widget.next),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _spin.dispose();
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: AnimatedBuilder(
        animation: Listenable.merge([_spin, _fade]),
        builder: (context, _) {
          return Opacity(
            opacity: 1 - _fade.value,
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.35),
                  radius: 1.0,
                  colors: [Color(0xFF16294A), _bg],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 170,
                      height: 170,
                      child: CustomPaint(
                        painter: _SplashDialsPainter(_dialTurn.value),
                      ),
                    ),
                    const SizedBox(height: 34),
                    Opacity(
                      opacity: _titleOpacity.value,
                      child: Transform.translate(
                        offset: Offset(0, _titleSlide.value),
                        child: Column(
                          children: const [
                            Text(
                              'HUSOS',
                              style: TextStyle(
                                color: _cream,
                                fontSize: 30,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 10,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'dos relojes, una misma hora',
                              style: TextStyle(
                                color: _muted,
                                fontSize: 11.5,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // filete de latón que se abre
                    Container(
                      width: 130 * _lineWidth.value,
                      height: 1,
                      color: _brass.withOpacity(0.45),
                    ),
                    const SizedBox(height: 22),
                    Opacity(
                      opacity: _creditOpacity.value,
                      child: Column(
                        children: const [
                          Text(
                            'CREATED BY',
                            style: TextStyle(
                              color: _muted,
                              fontSize: 9.5,
                              letterSpacing: 4.5,
                            ),
                          ),
                          SizedBox(height: 7),
                          Text(
                            'Dennis Bonilla',
                            style: TextStyle(
                              color: _brassLight,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Dos carátulas que giran y se detienen sincronizadas (guiño al ícono).
class _SplashDialsPainter extends CustomPainter {
  final double t; // 0..1
  _SplashDialsPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.30;
    final off = size.width * 0.115;

    // dos carátulas que se sincronizan
    _dial(canvas, c + Offset(-off, -off * 0.9), r, const Color(0xFF96B0DC),
        const Color(0xFF12223E), 300 * t - 120, 110 * t - 300, _night,
        const Color(0xFFAABEE6));
    _dial(canvas, c + Offset(off, off * 0.9), r, _brass,
        const Color(0xFF0D1A30), 45 * t + 200, 200 * t + 90, _brassLight,
        _cream);
  }

  void _dial(Canvas canvas, Offset o, double r, Color ring, Color face,
      double hourDeg, double minDeg, Color hh, Color mh) {
    canvas.drawCircle(o, r, Paint()..color = face);
    canvas.drawCircle(
        o,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.055
          ..color = ring);
    for (int i = 0; i < 12; i++) {
      final a = i * 30 * math.pi / 180;
      final big = i % 3 == 0;
      final p1 = o + Offset(r * 0.78 * math.sin(a), -r * 0.78 * math.cos(a));
      final p2 = o + Offset(r * 0.90 * math.sin(a), -r * 0.90 * math.cos(a));
      canvas.drawLine(
          p1,
          p2,
          Paint()
            ..color = ring.withOpacity(big ? 0.95 : 0.55)
            ..strokeWidth = r * (big ? 0.045 : 0.026));
    }
    final ha = hourDeg * math.pi / 180;
    canvas.drawLine(
        o,
        o + Offset(r * 0.48 * math.sin(ha), -r * 0.48 * math.cos(ha)),
        Paint()
          ..color = hh
          ..strokeWidth = r * 0.085
          ..strokeCap = StrokeCap.round);
    final ma = minDeg * math.pi / 180;
    canvas.drawLine(
        o,
        o + Offset(r * 0.72 * math.sin(ma), -r * 0.72 * math.cos(ma)),
        Paint()
          ..color = mh
          ..strokeWidth = r * 0.052
          ..strokeCap = StrokeCap.round);
    canvas.drawCircle(o, r * 0.06, Paint()..color = ring);
  }

  @override
  bool shouldRepaint(_SplashDialsPainter old) => old.t != t;
}
