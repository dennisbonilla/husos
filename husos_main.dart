import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

// ---- paleta ("cronómetro náutico") ---------------------------------------
const _bg = Color(0xFF0C1626);
const _panel = Color(0xFF13223A);
const _brass = Color(0xFFC6A15B);
const _brassLight = Color(0xFFE4C782);
const _cream = Color(0xFFEDE7D6);
const _muted = Color(0xFF7C8AA8);
const _day = Color(0xFFF0B252);
const _night = Color(0xFF6E86C8);

// ---- lista amplia de zonas (etiqueta en español + zona IANA) --------------
class Zone {
  final String tz;
  final String label;
  const Zone(this.tz, this.label);
}

const List<Zone> kZones = [
  // Centroamérica
  Zone('America/Costa_Rica', 'Costa Rica'),
  Zone('America/Guatemala', 'Guatemala'),
  Zone('America/El_Salvador', 'San Salvador'),
  Zone('America/Tegucigalpa', 'Honduras'),
  Zone('America/Managua', 'Managua'),
  Zone('America/Panama', 'Panamá'),
  Zone('America/Belize', 'Belice'),
  // México
  Zone('America/Mexico_City', 'Ciudad de México'),
  Zone('America/Cancun', 'Cancún'),
  Zone('America/Monterrey', 'Monterrey'),
  Zone('America/Tijuana', 'Tijuana'),
  // Caribe
  Zone('America/Havana', 'La Habana'),
  Zone('America/Santo_Domingo', 'Santo Domingo'),
  Zone('America/Puerto_Rico', 'San Juan'),
  Zone('America/Jamaica', 'Kingston'),
  // Sudamérica
  Zone('America/Bogota', 'Bogotá'),
  Zone('America/Lima', 'Lima'),
  Zone('America/Guayaquil', 'Quito'),
  Zone('America/Caracas', 'Caracas'),
  Zone('America/La_Paz', 'La Paz'),
  Zone('America/Asuncion', 'Asunción'),
  Zone('America/Santiago', 'Santiago de Chile'),
  Zone('America/Argentina/Buenos_Aires', 'Buenos Aires'),
  Zone('America/Montevideo', 'Montevideo'),
  Zone('America/Sao_Paulo', 'São Paulo'),
  Zone('America/Manaus', 'Manaos'),
  // EE. UU. / Canadá
  Zone('America/New_York', 'Nueva York'),
  Zone('America/Chicago', 'Chicago'),
  Zone('America/Denver', 'Denver'),
  Zone('America/Phoenix', 'Phoenix'),
  Zone('America/Los_Angeles', 'Los Ángeles'),
  Zone('America/Anchorage', 'Anchorage'),
  Zone('America/Toronto', 'Toronto'),
  Zone('America/Vancouver', 'Vancouver'),
  Zone('Pacific/Honolulu', 'Honolulú'),
  // Europa
  Zone('Europe/London', 'Londres'),
  Zone('Europe/Lisbon', 'Lisboa'),
  Zone('Europe/Madrid', 'Madrid'),
  Zone('Europe/Paris', 'París'),
  Zone('Europe/Berlin', 'Berlín'),
  Zone('Europe/Rome', 'Roma'),
  Zone('Europe/Amsterdam', 'Ámsterdam'),
  Zone('Europe/Athens', 'Atenas'),
  Zone('Europe/Istanbul', 'Estambul'),
  Zone('Europe/Moscow', 'Moscú'),
  // África / Medio Oriente
  Zone('Africa/Casablanca', 'Casablanca'),
  Zone('Africa/Lagos', 'Lagos'),
  Zone('Africa/Cairo', 'El Cairo'),
  Zone('Africa/Nairobi', 'Nairobi'),
  Zone('Africa/Johannesburg', 'Johannesburgo'),
  Zone('Asia/Jerusalem', 'Jerusalén'),
  Zone('Asia/Dubai', 'Dubái'),
  Zone('Asia/Tehran', 'Teherán'),
  // Asia
  Zone('Asia/Karachi', 'Karachi'),
  Zone('Asia/Kolkata', 'Nueva Delhi'),
  Zone('Asia/Dhaka', 'Daca'),
  Zone('Asia/Bangkok', 'Bangkok'),
  Zone('Asia/Jakarta', 'Yakarta'),
  Zone('Asia/Shanghai', 'Shanghái'),
  Zone('Asia/Hong_Kong', 'Hong Kong'),
  Zone('Asia/Singapore', 'Singapur'),
  Zone('Asia/Tokyo', 'Tokio'),
  Zone('Asia/Seoul', 'Seúl'),
  Zone('Asia/Manila', 'Manila'),
  // Oceanía
  Zone('Australia/Perth', 'Perth'),
  Zone('Australia/Sydney', 'Sídney'),
  Zone('Pacific/Auckland', 'Auckland'),
  Zone('Pacific/Fiji', 'Suva'),
];

void main() {
  tzdata.initializeTimeZones();
  runApp(const HusosApp());
}

class HusosApp extends StatelessWidget {
  const HusosApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Husos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _bg,
        canvasColor: _panel,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// ---- helpers de tiempo ----------------------------------------------------
int _nowMinutesInZone(String tzName) {
  final loc = tz.getLocation(tzName);
  final n = tz.TZDateTime.now(loc);
  return n.hour * 60 + n.minute;
}

int _offsetMinutes(String tzName) {
  final inst = DateTime.now();
  final loc = tz.getLocation(tzName);
  return tz.TZDateTime.from(inst, loc).timeZoneOffset.inMinutes;
}

String _labelFor(String tzName) =>
    kZones.firstWhere((z) => z.tz == tzName, orElse: () => Zone(tzName, tzName)).label;

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String zoneA = 'America/Costa_Rica';
  String zoneB = 'Europe/Madrid';
  late double minutesA; // minutos-del-día del reloj de arriba (0..1440)

  @override
  void initState() {
    super.initState();
    minutesA = _nowMinutesInZone(zoneA).toDouble();
  }

  int get _diff => _offsetMinutes(zoneB) - _offsetMinutes(zoneA);

  // aplica un giro (en minutos) al instante compartido
  void _wind(double dMin) {
    setState(() {
      minutesA = (minutesA + dMin) % 1440;
      if (minutesA < 0) minutesA += 1440;
    });
  }

  void _snap() => setState(() => minutesA = minutesA.roundToDouble());

  void _now() => setState(() => minutesA = _nowMinutesInZone(zoneA).toDouble());

  @override
  Widget build(BuildContext context) {
    final aMin = ((minutesA % 1440) + 1440) % 1440;
    final bAbs = aMin + _diff;
    final bMin = ((bAbs % 1440) + 1440) % 1440;
    final dayShift = (bAbs / 1440).floor();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                children: [
                  const _Header(),
                  const SizedBox(height: 22),
                  _ClockUnit(
                    zone: zoneA,
                    minutes: aMin,
                    onZoneChanged: (z) => setState(() => zoneA = z!),
                    onWind: _wind,
                    onWindEnd: _snap,
                  ),
                  _Connector(diff: _diff),
                  _ClockUnit(
                    zone: zoneB,
                    minutes: bMin,
                    dayShift: dayShift,
                    onZoneChanged: (z) => setState(() => zoneB = z!),
                    onWind: _wind,
                    onWindEnd: _snap,
                  ),
                  const SizedBox(height: 30),
                  OutlinedButton(
                    onPressed: _now,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _brassLight,
                      side: BorderSide(color: _brass.withOpacity(0.4)),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                    ),
                    child: const Text('AHORA', style: TextStyle(letterSpacing: 2, fontSize: 12)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Arrastra la aguja larga (minutos) o la corta (horas).\nAmbos relojes giran juntos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _muted, fontSize: 11.5, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Text('CONVERSOR DE HUSOS',
            style: TextStyle(color: _brass, fontSize: 11, letterSpacing: 4)),
        SizedBox(height: 8),
        Text('Dos relojes, una misma hora',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _cream, fontSize: 26, fontWeight: FontWeight.w500, height: 1.05)),
      ],
    );
  }
}

class _ClockUnit extends StatelessWidget {
  final String zone;
  final double minutes;
  final int dayShift;
  final ValueChanged<String?> onZoneChanged;
  final ValueChanged<double> onWind;
  final VoidCallback onWindEnd;

  const _ClockUnit({
    required this.zone,
    required this.minutes,
    this.dayShift = 0,
    required this.onZoneChanged,
    required this.onWind,
    required this.onWindEnd,
  });

  String _fmt(double m) {
    int h = (m ~/ 60) % 24;
    int mm = (m % 60).round();
    if (mm == 60) {
      mm = 0;
      h = (h + 1) % 24;
    }
    final ap = h < 12 ? 'AM' : 'PM';
    int h12 = h % 12;
    if (h12 == 0) h12 = 12;
    return '$h12:${mm.toString().padLeft(2, '0')} $ap';
  }

  String _dayBadge(int s) {
    if (s == 0) return '';
    if (s == 1) return 'día siguiente';
    if (s == -1) return 'día anterior';
    return '${s > 0 ? '+' : ''}$s días';
  }

  @override
  Widget build(BuildContext context) {
    final h24 = ((minutes ~/ 60) % 24);
    final badge = _dayBadge(dayShift);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _brass.withOpacity(0.22)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: zone,
                    isExpanded: true,
                    dropdownColor: _panel,
                    iconEnabledColor: _brass,
                    style: const TextStyle(color: _cream, fontSize: 14),
                    items: kZones
                        .map((z) => DropdownMenuItem(value: z.tz, child: Text(z.label)))
                        .toList(),
                    onChanged: onZoneChanged,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_fmt(minutes),
                    style: const TextStyle(
                        color: _cream, fontSize: 17, fontWeight: FontWeight.w700)),
                if (badge.isNotEmpty)
                  Text(badge, style: const TextStyle(color: _brassLight, fontSize: 10.5)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClockDial(minutes: minutes, onWind: onWind, onWindEnd: onWindEnd, hour24: h24),
      ],
    );
  }
}

class _Connector extends StatelessWidget {
  final int diff;
  const _Connector({required this.diff});
  @override
  Widget build(BuildContext context) {
    final sign = diff >= 0 ? '+' : '−';
    final ad = diff.abs();
    final dh = ad ~/ 60, dm = ad % 60;
    final txt = '$sign${dh}h${dm != 0 ? ' ${dm}m' : ''}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          const Text('DIFERENCIA',
              style: TextStyle(color: _muted, fontSize: 9.5, letterSpacing: 3)),
          const SizedBox(height: 2),
          Text(txt,
              style: const TextStyle(
                  color: _brassLight, fontSize: 24, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ---- carátula analógica con manecillas arrastrables -----------------------
class ClockDial extends StatefulWidget {
  final double minutes;
  final int hour24;
  final ValueChanged<double> onWind;
  final VoidCallback onWindEnd;
  const ClockDial({
    super.key,
    required this.minutes,
    required this.hour24,
    required this.onWind,
    required this.onWindEnd,
  });
  @override
  State<ClockDial> createState() => _ClockDialState();
}

class _ClockDialState extends State<ClockDial> {
  String _hand = 'min';
  double _lastAngle = 0;

  double _angle(Offset p, Size s) {
    final c = Offset(s.width / 2, s.height / 2);
    final d = p - c;
    final a = math.atan2(d.dx, -d.dy) * 180 / math.pi;
    return (a + 360) % 360;
  }

  double _shortest(double a, double b) => ((a - b + 540) % 360) - 180;

  @override
  Widget build(BuildContext context) {
    final isDay = widget.hour24 >= 6 && widget.hour24 < 18;
    return LayoutBuilder(
      builder: (context, c) {
        final side = math.min(c.maxWidth, 290.0);
        final size = Size(side, side);
        return GestureDetector(
          onPanStart: (d) {
            final touch = _angle(d.localPosition, size);
            final hourDeg = (widget.minutes / 60 % 12) * 30;
            final minDeg = (widget.minutes % 60) * 6;
            final dh = _shortest(touch, hourDeg).abs();
            final dm = _shortest(touch, minDeg).abs();
            _hand = dh < dm ? 'hour' : 'min';
            _lastAngle = touch;
          },
          onPanUpdate: (d) {
            final now = _angle(d.localPosition, size);
            final delta = _shortest(now, _lastAngle);
            _lastAngle = now;
            widget.onWind(_hand == 'hour' ? delta * 2 : delta / 6);
          },
          onPanEnd: (_) => widget.onWindEnd(),
          child: SizedBox(
            width: side,
            height: side,
            child: CustomPaint(painter: _DialPainter(widget.minutes, isDay)),
          ),
        );
      },
    );
  }
}

class _DialPainter extends CustomPainter {
  final double minutes;
  final bool isDay;
  _DialPainter(this.minutes, this.isDay);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 6;

    // fondo de carátula
    final faceInner = isDay ? const Color(0xFF243A5E) : const Color(0xFF172A4D);
    final faceOuter = isDay ? const Color(0xFF101F37) : const Color(0xFF0B1526);
    final facePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.2),
        radius: 0.75,
        colors: [faceInner, faceOuter],
      ).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawCircle(c, r, facePaint);

    // aro de latón
    canvas.drawCircle(
        c, r + 3, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..color = _brass.withOpacity(0.55));
    // resplandor día/noche
    canvas.drawCircle(
        c, r, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = (isDay ? _day : _night).withOpacity(0.15));

    // marcas
    for (int i = 0; i < 60; i++) {
      final a = i * 6 * math.pi / 180;
      final big = i % 5 == 0;
      final r1 = big ? r - 13 : r - 7;
      final p1 = c + Offset(r1 * math.sin(a), -r1 * math.cos(a));
      final p2 = c + Offset((r - 3) * math.sin(a), -(r - 3) * math.cos(a));
      canvas.drawLine(
          p1, p2, Paint()
        ..color = _brass.withOpacity(big ? 0.9 : 0.4)
        ..strokeWidth = big ? 1.8 : 0.8);
    }

    // números
    for (int h = 1; h <= 12; h++) {
      final a = h * 30 * math.pi / 180;
      final rr = r - 26;
      final pos = c + Offset(rr * math.sin(a), -rr * math.cos(a));
      final tp = TextPainter(
        text: TextSpan(
            text: '$h',
            style: TextStyle(color: _cream.withOpacity(0.82), fontSize: 15)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }

    // sol / luna
    _drawCelestial(canvas, c + Offset(0, r * 0.42));

    // manecillas
    final hourA = (minutes / 60 % 12) * 30 * math.pi / 180;
    final minA = (minutes % 60) * 6 * math.pi / 180;
    _hand(canvas, c, hourA, r * 0.52, 6, _brassLight);
    _hand(canvas, c, minA, r * 0.82, 3.2, _cream);

    // centro
    canvas.drawCircle(c, 6, Paint()..color = _brass);
    canvas.drawCircle(c, 2.4, Paint()..color = _bg);
  }

  void _hand(Canvas canvas, Offset c, double a, double len, double w, Color col) {
    final tail = c - Offset(len * 0.16 * math.sin(a), -len * 0.16 * math.cos(a));
    final tip = c + Offset(len * math.sin(a), -len * math.cos(a));
    canvas.drawLine(
        tail, tip, Paint()
      ..color = col
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round);
  }

  void _drawCelestial(Canvas canvas, Offset o) {
    final col = isDay ? _day : _night;
    final p = Paint()
      ..color = col
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    if (isDay) {
      canvas.drawCircle(o, 6, p);
      for (int i = 0; i < 8; i++) {
        final a = i * 45 * math.pi / 180;
        canvas.drawLine(o + Offset(9 * math.cos(a), 9 * math.sin(a)),
            o + Offset(12.5 * math.cos(a), 12.5 * math.sin(a)), p);
      }
    } else {
      final path = Path()
        ..addOval(Rect.fromCircle(center: o, radius: 7));
      canvas.drawPath(path, p);
      canvas.drawCircle(
          o + const Offset(3.5, -1.5), 6.5, Paint()..color = faceColor());
    }
  }

  Color faceColor() => isDay ? const Color(0xFF243A5E) : const Color(0xFF172A4D);

  @override
  bool shouldRepaint(_DialPainter old) =>
      old.minutes != minutes || old.isDay != isDay;
}
