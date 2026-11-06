import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../core/constants.dart';
import '../core/storage.dart';
import 'common.dart' as w;

/// 4.5 — ادیتور تمام‌صفحه: تنظیم/الگو/منحنی/نقاشی/متن + کامپوزیت نهایی
class PhotoEditor extends StatefulWidget {
  final File file; const PhotoEditor({super.key, required this.file});
  @override State<PhotoEditor> createState() => _PhotoEditorState();
}

class _PhotoEditorState extends State<PhotoEditor> {
  String mode = 'main'; // main|adjust|pattern|curve|draw|text
  double smooth = 0, enhance = 0, clarity = 0;
  String pattern = 'غیرفعال'; String curveCh = 'همه';
  double brush = 6; Color brushColor = Colors.white; String tool = 'pen';
  final List<_Stroke> strokes = []; _Stroke? current;
  final List<_TextItem> texts = []; _TextItem? editing;
  final GlobalKey _boundary = GlobalKey();
  int adjustTool = 0; // 0 sliders 1 pattern 2 curve
  TextAlign align = TextAlign.center; bool outline = false;

  Future<void> _save() async {
    final b = _boundary.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (b == null) return;
    final img = await b.toImage(pixelRatio: 3);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    final f = File('${Storage.dir}/avatar_${DateTime.now().millisecondsSinceEpoch}.png');
    await f.writeAsBytes(data!.buffer.asUint8List());
    if (mounted) Navigator.pop(context, f);
  }

  @override Widget build(BuildContext c) => Scaffold(backgroundColor: Colors.black, body: SafeArea(child: Column(children: [
    Expanded(child: RepaintBoundary(key: _boundary, child: Stack(fit: Stack.expand, children: [
      Positioned.fill(child: ColorFiltered(colorFilter: ColorFilter.mode(Colors.white.withOpacity(enhance * 0.06), BlendMode.saturation), child: ImageFiltered(imageFilter: ui.ImageFilter.blur(sigmaX: smooth * 3, sigmaY: smooth * 3), child: Image.file(widget.file, fit: BoxFit.cover, opacity: AlwaysStoppedAnimation(1 - clarity * 0.0))))),
      if (clarity != 0) Positioned.fill(child: ColorFiltered(colorFilter: ColorFilter.matrix(_contrastMatrix(clarity)), child: Image.file(widget.file, fit: BoxFit.cover, opacity: const AlwaysStoppedAnimation(0.35)))),
      // الگو: مات خارج شکل
      if (pattern != 'غیرفعال') Positioned.fill(child: ClipPath(clipper: null, child: IgnorePointer(child: Container(color: Colors.transparent))),),
      if (pattern != 'غیرفعال') _patternOverlay(),
      // نقاشی
      if (mode == 'draw' || strokes.isNotEmpty) GestureDetector(
        onPanStart: mode == 'draw' ? (d) => setState(() => current = _Stroke(color: brushColor, size: brush, tool: tool, points: [d.localPosition])) : null,
        onPanUpdate: mode == 'draw' ? (d) => setState(() => current!.points.add(d.localPosition)) : null,
        onPanEnd: mode == 'draw' ? (_) => setState(() { if (current != null) strokes.add(current!); current = null; }) : null,
        child: CustomPaint(size: Size.infinite, painter: _StrokePainter(strokes: strokes, current: current))),
      // متن
      for (final t in texts) _textBox(t),
    ]))),
    _bottomBar(),
  ])));

  List<double> _contrastMatrix(double v) { final c = 1 + v * 0.5; final o = (1 - c) * 127;
    return [c,0,0,0,o, 0,c,0,0,o, 0,0,c,0,o, 0,0,0,1,0]; }

  Widget _patternOverlay() {
    final blurOut = ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10);
    return LayoutBuilder(builder: (c, con) {
      final w = con.maxWidth, h = con.maxHeight;
      if (pattern == 'دایره‌ای') return Stack(children: [
        Positioned.fill(child: ImageFiltered(imageFilter: blurOut, child: Image.file(widget.file, fit: BoxFit.cover, opacity: const AlwaysStoppedAnimation(0.55)))),
        Center(child: CustomPaint(size: Size(w, h), painter: _DashCircles())),
        Center(child: ClipOval(child: SizedBox(width: w * 0.55, height: w * 0.55, child: Image.file(widget.file, fit: BoxFit.cover)))),
      ]);
      return Stack(children: [
        Positioned.fill(child: ImageFiltered(imageFilter: blurOut, child: Image.file(widget.file, fit: BoxFit.cover, opacity: const AlwaysStoppedAnimation(0.55)))),
        CustomPaint(size: Size(w, h), painter: _DashLines()),
        for (int i = 0; i < 4; i++) Positioned(left: 0, right: 0, top: h * (0.1 + i * 0.22), height: h * 0.12, child: Image.file(widget.file, fit: BoxFit.cover)),
      ]);
    });
  }

  Widget _textBox(_TextItem t) => GestureDetector(
    onPanUpdate: (d) => setState(() { t.pos += d.delta; }),
    onTap: () => setState(() => editing = t),
    child: Positioned(left: t.pos.dx, top: t.pos.dy, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFF2196f3), width: 1, style: BorderStyle.solid)),
      child: Stack(children: [
        Text(t.text.isEmpty ? 'افزودن متن' : t.text, textAlign: align, style: TextStyle(fontSize: 20, color: t.color, fontWeight: FontWeight.w700, shadows: outline ? [const Shadow(color: Colors.black, offset: Offset(1, 1)), const Shadow(color: Colors.black, offset: Offset(-1, -1))] : null)),
        Positioned(left: -6, top: 10, child: Container(width: 8, height: 16, color: const Color(0xFF2196f3))),
        Positioned(right: -6, top: 10, child: Container(width: 8, height: 16, color: const Color(0xFF2196f3))),
      ]))));

  Widget _bottomBar() {
    switch (mode) {
      case 'draw': return _drawBar();
      case 'text': return _textBar();
      case 'adjust': return _adjustBar();
      default: return _mainBar();
    }
  }

  Widget _mainBar() => Padding(padding: const EdgeInsets.fromLTRB(14, 8, 14, 10), child: Row(children: [
    Pressable(onTap: () => setState(() => mode = 'adjust'), child: const Icon(Icons.tune_outlined, size: 21, color: Colors.white70, weight: 300)),
    const SizedBox(width: 16),
    Pressable(onTap: () => setState(() => mode = 'text'), child: const Icon(Icons.text_fields_outlined, size: 20, color: Colors.white70, weight: 300)),
    const Spacer(),
    Pressable(onTap: _save, child: Container(width: 52, height: 52, decoration: const BoxDecoration(color: C.green, shape: BoxShape.circle), child: const Icon(Icons.check, color: Colors.white, size: 26))),
  ]));

  Widget _adjustBar() => Container(color: const Color(0xFF111113), padding: const EdgeInsets.fromLTRB(12, 10, 12, 12), child: Column(children: [
    if (adjustTool == 0) ...[
      _slider('صافی پوست', smooth, (v) => smooth = v),
      _slider('بهبود', enhance, (v) => enhance = v),
      _slider('شفافیت', clarity, (v) => clarity = v),
    ],
    if (adjustTool == 1) Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      for (final p in ['غیرفعال', 'دایره‌ای', 'خطی']) Pressable(onTap: () => setState(() => pattern = p), child: Container(margin: const EdgeInsets.symmetric(horizontal: 6), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7), decoration: BoxDecoration(color: pattern == p ? C.green : const Color(0xFF232326), borderRadius: BorderRadius.circular(16)), child: Text(p, style: const TextStyle(fontSize: 12, color: Colors.white)))),
    ]),
    if (adjustTool == 2) _curveDiagram(),
    const SizedBox(height: 8),
    Row(children: [
      Pressable(onTap: () => Navigator.pop(context), child: const Text('انصراف', style: TextStyle(color: Colors.white, fontSize: 13))),
      const Spacer(),
      for (int i = 0; i < 3; i++) Pressable(onTap: () => setState(() => adjustTool = i), child: Container(margin: const EdgeInsets.symmetric(horizontal: 8), padding: const EdgeInsets.all(6), decoration: BoxDecoration(shape: BoxShape.circle, color: adjustTool == i ? C.green : Colors.transparent), child: Icon([Icons.tune, Icons.grid_on, Icons.show_chart][i], size: 17, color: Colors.white))),
      const Spacer(),
      Pressable(onTap: () => setState(() => mode = 'main'), child: const Text('ذخیره', style: TextStyle(color: C.green, fontSize: 13, fontWeight: FontWeight.w700))),
    ]),
  ]));

  Widget _curveDiagram() => SizedBox(height: 130, child: Directionality(textDirection: TextDirection.ltr, child: Row(children: [
    Expanded(child: CustomPaint(size: Size.infinite, painter: _CurvePainter(channel: curveCh))),
    Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [for (final l in ['1.00','0.75','0.50','0.25','0.00']) Text(l, style: const TextStyle(fontSize: 8.5, color: Colors.white54))]),
  ]))),

  Widget _slider(String label, double v, void Function(double) set) => Directionality(textDirection: TextDirection.rtl, child: Row(children: [
    SizedBox(width: 62, child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.white87))),
    Expanded(child: SliderTheme(data: SliderThemeData(trackHeight: 2, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6), activeTrackColor: C.green, inactiveTrackColor: const Color(0xFF3a3f47), thumbColor: Colors.white), child: Slider(value: v, onChanged: (x) => setState(() => set(x)))),
  ]));

  Widget _drawBar() => Container(color: const Color(0xFF111113), padding: const EdgeInsets.fromLTRB(10, 8, 10, 10), child: Row(children: [
    RotatedBox(quarterTurns: 1, child: SizedBox(height: 90, width: 26, child: SliderTheme(data: SliderThemeData(trackHeight: 2, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7), activeTrackColor: Colors.white54, inactiveTrackColor: const Color(0xFF3a3f47), thumbColor: Colors.white), child: Slider(value: brush, min: 1, max: 30, onChanged: (v) => setState(() => brush = v))))),
    Expanded(child: Column(children: [
      Row(children: [
        Pressable(onTap: () => setState(() => strokes.clear()), child: const Text('پاک کردن همه', style: TextStyle(fontSize: 11.5, color: Colors.white87))),
        const Spacer(),
        Pressable(onTap: () => setState(() { if (strokes.isNotEmpty) strokes.removeLast(); }), child: const Icon(Icons.undo_outlined, size: 17, color: Colors.white70)),
      ]),
      Container(margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: const Color(0xFF232326), borderRadius: BorderRadius.circular(20)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _colorDot(),
        for (final t in ['pen','arrow','marker','spray','dotted','highlight']) Pressable(onTap: () => setState(() => tool = t), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: Icon(_toolIcon(t), size: 16, color: tool == t ? C.green : Colors.white70))),
        const Icon(Icons.add, size: 16, color: Colors.white70),
      ])),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Pressable(onTap: () => setState(() => mode = 'main'), child: const Icon(Icons.check, size: 18, color: C.green)),
        const SizedBox(width: 18),
        Pressable(onTap: () => setState(() => mode = 'text'), child: const Text('متن', style: TextStyle(fontSize: 12, color: Colors.white87))),
        const SizedBox(width: 18),
        const Text('نقاشی', style: TextStyle(fontSize: 12, color: C.green)),
        const SizedBox(width: 18),
        Pressable(onTap: () => setState(() => mode = 'main'), child: const Icon(Icons.close, size: 18, color: Colors.white70)),
      ]),
    ])),
  ]));

  IconData _toolIcon(String t) => {'pen': Icons.edit_outlined, 'arrow': Icons.north_east_outlined, 'marker': Icons.mark_outlined, 'spray': Icons.air_outlined, 'dotted': Icons.more_horiz, 'highlight': Icons.highlight_alt_outlined}[t]!;

  Widget _colorDot() => Pressable(onTap: () async { final c2 = await showDialog<Color>(context: context, builder: (_) => _palette()); if (c2 != null) setState(() => brushColor = c2); },
    child: Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, color: brushColor, border: Border.all(color: Colors.white54))));

  Widget _palette() => Dialog(backgroundColor: const Color(0xFF1d1d21), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), child: Padding(padding: const EdgeInsets.all(14), child: Wrap(spacing: 8, runSpacing: 8, children: [
    for (final c in [Colors.white, Colors.black, Colors.red, Colors.orange, Colors.yellow, Colors.green, C.green, Colors.blue, Colors.purple, Colors.pink]) Pressable(onTap: () => Navigator.pop(context, c), child: Container(width: 30, height: 30, decoration: BoxDecoration(color: c, shape: BoxShape.circle)))])));

  Widget _textBar() => Container(color: const Color(0xFF111113), padding: const EdgeInsets.fromLTRB(12, 8, 12, 10), child: Column(children: [
    Row(children: [
      Pressable(onTap: () => setState(() => mode = 'main'), child: const Text('ذخیره', style: TextStyle(fontSize: 12.5, color: C.green, fontWeight: FontWeight.w700))),
      const Spacer(),
      Pressable(onTap: () => setState(() { if (texts.isNotEmpty) texts.removeLast(); }), child: const Text('پاک کردن', style: TextStyle(fontSize: 12.5, color: Colors.white87))),
    ]),
    const SizedBox(height: 6),
    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), decoration: BoxDecoration(color: const Color(0xFF232326), borderRadius: BorderRadius.circular(14)), child: const Text('راوی', style: TextStyle(fontSize: 11.5, color: Colors.white87))),
      const SizedBox(width: 10),
      Pressable(onTap: () => setState(() => texts.add(_TextItem(text: '', pos: const Offset(80, 120), color: Colors.white))), child: const Icon(Icons.add, size: 17, color: Colors.white70)),
      const SizedBox(width: 10),
      Pressable(onTap: () => setState(() => outline = !outline), child: Icon(Icons.format_bold_outlined, size: 17, color: outline ? C.green : Colors.white70)),
      const SizedBox(width: 10),
      Pressable(onTap: () => setState(() => align = align == TextAlign.center ? TextAlign.right : TextAlign.center), child: const Icon(Icons.format_align_center_outlined, size: 17, color: Colors.white70)),
      const SizedBox(width: 10), _colorDot(),
    ]),
    if (editing != null) TextField(onChanged: (v) => setState(() => editing!.text = v), autofocus: true, style: const TextStyle(color: Colors.white, fontSize: 13), decoration: const InputDecoration(hintText: 'متن...', hintStyle: TextStyle(color: Colors.white38), isDense: true)),
  ]));
}

class _Stroke { Color color; double size; String tool; List<Offset> points; _Stroke({required this.color, required this.size, required this.tool, required this.points}); }
class _TextItem { String text; Offset pos; Color color; _TextItem({required this.text, required this.pos, required this.color}); }

class _StrokePainter extends CustomPainter {
  final List<_Stroke> strokes; final _Stroke? current;
  _StrokePainter({required this.strokes, this.current});
  @override void paint(Canvas canvas, Size size) {
    for (final s in [...strokes, if (current != null) current!]) {
      final p = Paint()..color = s.tool == 'highlight' ? s.color.withOpacity(0.4) : s.color..strokeWidth = s.tool == 'highlight' ? s.size * 2.4 : s.size..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..style = PaintingStyle.stroke;
      if (s.tool == 'dotted') { p.style = PaintingStyle.stroke; }
      if (s.tool == 'spray') { for (final pt in s.points) { for (int i = 0; i < 6; i++) canvas.drawCircle(pt + Offset((i * 7 % 13) - 6, (i * 5 % 11) - 5), 0.9, p..style = PaintingStyle.fill); } continue; }
      final path = Path();
      if (s.points.isEmpty) continue;
      path.moveTo(s.points.first.dx, s.points.first.dy);
      for (final pt in s.points.skip(1)) path.lineTo(pt.dx, pt.dy);
      if (s.tool == 'arrow' && s.points.length > 1) {
        final a = s.points[s.points.length - 2], b = s.points.last;
        final ang = (b - a).direction;
        path.moveTo(b.dx, b.dy); path.lineTo(b.dx - 14 * Math_cos(ang - 0.5), b.dy - 14 * Math_sin(ang - 0.5));
        path.moveTo(b.dx, b.dy); path.lineTo(b.dx - 14 * Math_cos(ang + 0.5), b.dy - 14 * Math_sin(ang + 0.5));
      }
      canvas.drawPath(path, p);
    }
  }
  double Math_cos(double x) => _cos(x); double Math_sin(double x) => _sin(x);
  @override bool shouldRepaint(c) => true;
}
double _cos(double x) => _trig(x, true); double _sin(double x) => _trig(x, false);
double _trig(double x, bool cos) { // پیاده‌سازی ساده بدون import اضافی
  double r = x % (2 * 3.141592653589793); double s = 1, t = 1, sum = 0; final xx = cos ? 0 : 1;
  if (cos) { sum = 1; t = 1; for (int n = 1; n <= 12; n++) { t *= -x * x / (2 * n * (2 * n - 1)); sum += t; } return sum; }
  sum = x; t = x; for (int n = 1; n <= 12; n++) { t *= -x * x / (2 * n * (2 * n + 1)); sum += t; } return sum;
}

class _DashCircles extends CustomPainter {
  @override void paint(Canvas canvas, Size s) {
    final p = Paint()..color = Colors.white70..style = PaintingStyle.stroke..strokeWidth = 1.2;
    p.maskFilter = const MaskFilter.blur(BlurStyle.normal, 0);
    canvas.drawCircle(s.center(Offset.zero), s.width * 0.30, p);
    canvas.drawCircle(s.center(Offset.zero), s.width * 0.42, p);
  }
  @override bool shouldRepaint(c) => false;
}
class _DashLines extends CustomPainter {
  @override void paint(Canvas canvas, Size s) {
    final p = Paint()..color = Colors.white70..style = PaintingStyle.stroke..strokeWidth = 1.2;
    for (int i = 0; i < 4; i++) canvas.drawLine(Offset(0, s.height * (0.22 + i * 0.22)), Offset(s.width, s.height * (0.22 + i * 0.22)), p);
  }
  @override bool shouldRepaint(c) => false;
}
class _CurvePainter extends CustomPainter {
  final String channel; _CurvePainter({required this.channel});
  @override void paint(Canvas canvas, Size s) {
    final g = Paint()..color = Colors.white24..strokeWidth = 0.7;
    for (int i = 0; i <= 4; i++) { canvas.drawLine(Offset(i * s.width / 4, 0), Offset(i * s.width / 4, s.height), g); canvas.drawLine(Offset(0, i * s.height / 4), Offset(s.width, i * s.height / 4), g); }
    final p = Paint()..color = {'همه': Colors.white, 'قرمز': Colors.red, 'سبز': Colors.green, 'آبی': Colors.blue}[channel]!..strokeWidth = 1.8;
    canvas.drawLine(Offset(0, s.height), Offset(s.width, 0), p);
  }
  @override bool shouldRepaint(c) => true;
}
