import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/constants.dart';

/// 0.9 — بازخورد فشردگی (scale) برای همه عناصر قابل لمس
class Pressable extends StatelessWidget {
  final VoidCallback? onTap; final Widget child; final bool enabled;
  const Pressable({super.key, this.onTap, required this.child, this.enabled = true});
  @override Widget build(BuildContext c) => GestureDetector(
    onTap: enabled ? onTap : null,
    child: TweenAnimationBuilder<double>(tween: Tween(begin: 1, end: 1), duration: const Duration(milliseconds: 200), builder: (_, v, ch) => ch, child: _Scale(child: child, onTap: enabled ? onTap : null));
}

class _Scale extends StatefulWidget {
  final Widget child; final VoidCallback? onTap; const _Scale({required this.child, this.onTap});
  @override State<_Scale> createState() => _ScaleState();
}
class _ScaleState extends State<_Scale> {
  double s = 1;
  @override Widget build(BuildContext c) => GestureDetector(
    onTapDown: (_) => setState(() => s = 0.93),
    onTapCancel: () => setState(() => s = 1),
    onTapUp: (_) { setState(() => s = 1); widget.onTap?.call(); },
    child: AnimatedScale(scale: s, duration: const Duration(milliseconds: 180), curve: Curves.easeOut, child: widget.child));
}

/// نشان آبی تأیید (گرادیان #3fb6ff→#0b74e0، مهر دالبردار + تیک سفید) — fallback دقیقِ تصویر پیوست
class VerifiedBadge extends StatelessWidget {
  final double size; const VerifiedBadge({super.key, this.size = 20});
  @override Widget build(BuildContext c) {
    final file = File('assets/badge.png');
    return Image.asset('assets/badge.png', width: size, height: size,
      errorBuilder: (_, __, ___) => CustomPaint(size: Size(size, size), painter: _SealPainter()));
  }
}
class _SealPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final r = size.width / 2, c = size.center(Offset.zero);
    final paint = Paint()..shader = const LinearGradient(colors: [C.badgeA, C.badgeB], begin: Alignment.topLeft, end: Alignment.bottomRight).createPaintShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final path = Path();
    const points = 12;
    for (int i = 0; i < points * 2; i++) {
      final ang = i * math.pi / points;
      final rad = i.isEven ? r : r * 0.82;
      final p = c + Offset(math.cos(ang) * rad, math.sin(ang) * rad);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close(); canvas.drawPath(path, paint);
    final ck = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = size.width * 0.11..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
    final p = Path()..moveTo(c.dx - r * 0.38, c.dy + r * 0.02)..lineTo(c.dx - r * 0.10, c.dy + r * 0.30)..lineTo(c.dx + r * 0.42, c.dy - r * 0.26);
    canvas.drawPath(p, ck);
  }
  @override bool shouldRepaint(c) => false;
}

/// دکمه ارسال: دایره #00b894 + هواپیمای کاغذی سفید (fallback تصویر send.png)
class SendIcon extends StatelessWidget {
  final double size; const SendIcon({super.key, this.size = 44});
  @override Widget build(BuildContext c) => Image.asset('assets/send.png', width: size, height: size,
    errorBuilder: (_, __, ___) => CustomPaint(size: Size(size, size), painter: _SendPainter()));
}
class _SendPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size s) {
    final r = s.width / 2;
    canvas.drawCircle(s.center(Offset.zero), r, Paint()..color = C.green);
    final p = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final c = s.center(Offset.zero);
    final path = Path()
      ..moveTo(c.dx - r * 0.42, c.dy - r * 0.05)
      ..lineTo(c.dx + r * 0.48, c.dy - r * 0.42)
      ..lineTo(c.dx + r * 0.18, c.dy + r * 0.46)
      ..lineTo(c.dx - r * 0.02, c.dy + r * 0.10)
      ..close();
    canvas.drawPath(path, p);
    final line = Paint()..color = C.green..style = PaintingStyle.stroke..strokeWidth = r * 0.10;
    canvas.drawLine(c + Offset(-r * 0.02, r * 0.10), c + Offset(r * 0.30, -r * 0.24), line);
  }
  @override bool shouldRepaint(c) => false;
}

/// والپیپر دودل روشن (کاشی‌شده، هر دو تم) — fallback تصویر wallpaper.png
class Wallpaper extends StatelessWidget {
  const Wallpaper({super.key});
  @override Widget build(BuildContext c) => Positioned.fill(child: Image.asset('assets/wallpaper.png', repeat: ImageRepeat.repeat, fit: BoxFit.none,
    errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFFeef1f4), child: CustomPaint(size: Size.infinite, painter: _DoodlePainter()))));
}
class _DoodlePainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0x14000000)..style = PaintingStyle.stroke..strokeWidth = 1.2;
    const tile = 180.0;
    for (double x = 0; x < size.width; x += tile) {
      for (double y = 0; y < size.height; y += tile) {
        canvas.drawCircle(Offset(x + 40, y + 40), 16, p);
        canvas.drawCircle(Offset(x + 40, y + 40), 8, p);
        canvas.drawRect(Rect.fromLTWH(x + 100, y + 90, 34, 22), p);
        canvas.drawLine(Offset(x + 100, y + 90), Offset(x + 117, y + 74), p);
        canvas.drawLine(Offset(x + 134, y + 90), Offset(x + 117, y + 74), p);
        canvas.drawArc(Rect.fromLTWH(x + 20, y + 120, 40, 40), 0, 5.5, false, p);
        for (int i = 0; i < 4; i++) canvas.drawCircle(Offset(x + 120 + i * 8, y + 30), 1.6, p..style = PaintingStyle.fill);
        p.style = PaintingStyle.stroke;
      }
    }
  }
  @override bool shouldRepaint(c) => false;
}

/// آواتار کانال (kanalporof) با fallback دایره مشکی + حلقه داخلی
class ChannelAvatar extends StatelessWidget {
  final double size; final bool ring; const ChannelAvatar({super.key, this.size = 48, this.ring = false});
  @override Widget build(BuildContext c) => Container(
    width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, border: ring ? Border.all(color: Colors.white24, width: 1) : null),
    child: ClipOval(child: Image.asset('assets/kanalporof.png', fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
        child: Center(child: Container(width: size * 0.72, height: size * 0.72, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF2a2a2a), width: 2)), child: const Center(child: Text('G', style: TextStyle(color: Color(0xFF26d0a8), fontSize: 18, fontWeight: FontWeight.w600))))))));
}

/// آواتار کاربر
class UserAvatar extends StatelessWidget {
  final String? path; final double size; final Color bg; final IconData glyph;
  const UserAvatar({super.key, this.path, this.size = 48, this.bg = const Color(0xFFf6e7d3), this.glyph = Icons.person_rounded});
  @override Widget build(BuildContext c) => ClipOval(child: path != null && File(path!).existsSync()
    ? Image.file(File(path!), width: size, height: size, fit: BoxFit.cover)
    : Container(width: size, height: size, color: bg, child: Icon(glyph, color: const Color(0xFFe58e3a), size: size * 0.6)));
}

/// سه‌نقطه بدون سایه و بدون عملکرد (0.8)
class ThreeDot extends StatelessWidget {
  final Color color; const ThreeDot({super.key, this.color = const Color(0xFF9aa4b2)});
  @override Widget build(BuildContext c) => Pressable(onTap: () {}, child: Container(width: 44, height: 44,
    decoration: BoxDecoration(color: Colors.grey.withOpacity(0.12), shape: BoxShape.circle),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [for (int i = 0; i < 3; i++) Container(margin: const EdgeInsets.symmetric(vertical: 1.6), width: 3.4, height: 3.4, decoration: BoxDecoration(color: color, shape: BoxShape.circle))])));
}

/// سه‌نقطه متحرک «درحال اتصال...»
class ConnectingText extends StatelessWidget {
  final TextStyle? style; const ConnectingText({super.key, this.style});
  @override Widget build(BuildContext c) => Row(mainAxisSize: MainAxisSize.min, children: [
    Text(tr0('درحال اتصال'), style: style), const _Dots()]);
  static String tr0(String s) => s;
}
class _Dots extends StatefulWidget { const _Dots(); @override State<_Dots> createState() => _DotsState(); }
class _DotsState extends State<_Dots> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext c) => AnimatedBuilder(animation: _c, builder: (_, __) {
    final n = (_c.value * 3).floor() % 4;
    return Text('.' * n, style: const TextStyle(fontSize: 14));
  });
}

/// آیکون استروک باریک
class ThinIcon extends StatelessWidget {
  final IconData icon; final double size; final Color color; final double stroke;
  const ThinIcon(this.icon, {super.key, this.size = 20, this.color = C.slateIcon, this.stroke = 1.5});
  @override Widget build(BuildContext c) => Icon(icon, size: size, color: color, weight: 300);
}
