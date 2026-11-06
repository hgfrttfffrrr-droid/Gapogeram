import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'common.dart';

/// صفحه‌کلید سفارشی 3×4 — حالت انگلیسی (لاگین) یا فارسی (OTP)
class Keypad extends StatelessWidget {
  final bool persian; final void Function(String digit) onDigit; final VoidCallback onDelete;
  const Keypad({super.key, this.persian = false, required this.onDigit, required this.onDelete});

  static const _letters = ['ABC','DEF','GHI','JKL','MNO','PQRS','TUV','WXYZ'];

  @override Widget build(BuildContext c) {
    final dark = Theme.of(c).brightness == Brightness.dark;
    Widget key({required Widget child, VoidCallback? onTap}) => Pressable(onTap: onTap, child: Container(
      height: 52, width: 74, margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(color: dark ? const Color(0xFF1a1a1c) : const Color(0xFFf1f2f4), borderRadius: BorderRadius.circular(12),
        border: Border.all(color: dark ? const Color(0xFF2b2b2e) : const Color(0xFFe2e4e8), width: 0.8)),
      child: Center(child: child)));
    final rows = [
      ['1','2','3'], ['4','5','6'], ['7','8','9']];
    final cells = <Widget>[];
    for (final row in rows) for (final d in row) {
      final i = int.parse(d) - 1;
      cells.add(key(onTap: () => onDigit(d), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(persian ? C.faDigits[int.parse(d)!] : d, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: dark ? Colors.white : const Color(0xFF1c1c1e))),
        if (i > 0) Text(_letters[i - 1], style: const TextStyle(fontSize: 7.5, letterSpacing: 1, color: Color(0xFF6b6b70))),
      ])));
    }
    // ردیف آخر: خانه خالی / 0 با + کوچک / حذف
    cells.add(key(child: const SizedBox.shrink()));
    cells.add(key(onTap: () => onDigit('0'), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(persian ? '۰' : '0', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: dark ? Colors.white : const Color(0xFF1c1c1e))),
      const Text('+', style: TextStyle(fontSize: 8, color: Color(0xFF6b6b70))),
    ])));
    cells.add(key(onTap: onDelete, child: CustomPaint(size: const Size(26, 20), painter: _BackspacePainter(dark: dark))));
    return Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: dark ? const Color(0xFF141416) : const Color(0xFFeceef1), borderRadius: BorderRadius.circular(18)),
      child: GridView.count(crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: 1.42, children: cells)));
  }
}

class _BackspacePainter extends CustomPainter {
  final bool dark; _BackspacePainter({required this.dark});
  @override void paint(Canvas canvas, Size s) {
    final p = Paint()..color = dark ? const Color(0xFFc9cdd4) : const Color(0xFF3a3f47)..style = PaintingStyle.stroke..strokeWidth = 1.4..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(8, 2)..lineTo(s.width - 2, 2)..lineTo(s.width - 2, s.height - 2)..lineTo(8, s.height - 2)..lineTo(1, s.height / 2)..close();
    canvas.drawPath(path, p);
    canvas.drawLine(Offset(12, 7), Offset(19, 13), p);
    canvas.drawLine(Offset(19, 7), Offset(12, 13), p);
  }
  @override bool shouldRepaint(c) => false;
}
