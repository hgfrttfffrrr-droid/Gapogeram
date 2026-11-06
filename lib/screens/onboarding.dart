import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/i18n.dart';
import '../core/services.dart';
import '../widgets/common.dart';
import 'login.dart';

const _slides = [
  ['به گپروم خوش آمدید', 'کنار هم؛ بر خط ارتباط'],
  ['بگو و بشنو!', 'تنوع، سرعت و کیفیت در برقراری ارتباط؛ از تماس صوتی تا تصویری'],
  ['سرت گرم و دلت خوش!', 'سرویس‌های محتوایی متنوع از ویدئو و پست‌چین تا پخش زنده'],
  ['نشود فاش کسی...', 'لایه‌های امنیتی در حریم خصوصی کاربر برای پیام‌رسانی امن و خیال راحت'],
  ['این کرکره همیشه بالاست!', 'میزبانی کسب‌وکارهای کوچک و بزرگ با امکانات مدیریت کانال و گروه'],
];

class Onboarding extends StatefulWidget { const Onboarding({super.key}); @override State<Onboarding> createState() => _OnboardingState(); }

class _OnboardingState extends State<Onboarding> {
  final PageController _pc = PageController(); int page = 0;

  @override Widget build(BuildContext c) {
    final dark = Prefs.I.dark;
    return AnimatedContainer(duration: const Duration(milliseconds: 320), color: dark ? C.darkBg : Colors.white, child: Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(child: Column(children: [
        // هدر: چپ=تم، راست=برند+لوگو
        Padding(padding: const EdgeInsets.fromLTRB(14, 10, 14, 0), child: Row(children: [
          Pressable(onTap: () => Prefs.I.setDark(!dark), child: Icon(dark ? Icons.dark_mode_outlined : Icons.light_mode_outlined, size: 21, color: dark ? Colors.white70 : const Color(0xFF3a3f47), weight: 300)),
          const Spacer(),
          Text(tr('app_name'), style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: dark ? Colors.white : Colors.black)),
          const SizedBox(width: 8),
          ClipOval(child: Image.asset('assets/logo.png', width: 30, height: 30, errorBuilder: (_, __, ___) => Container(width: 30, height: 30, color: C.green, child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 16)))),
        ])),
        Expanded(child: PageView.builder(controller: _pc, itemCount: 5, onPageChanged: (i) => setState(() => page = i),
          itemBuilder: (_, i) => _Slide(i: i, dark: dark))),
        // نقطه‌ها
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => Pressable(onTap: () => _pc.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
          child: AnimatedContainer(duration: const Duration(milliseconds: 250), margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == page ? 20 : 6, height: 6, decoration: BoxDecoration(color: i == page ? C.green : const Color(0xFF5a5f66), borderRadius: BorderRadius.circular(4)))))),
        const SizedBox(height: 10),
        // شرایط + CTA
        RichText(textDirection: TextDirection.rtl, text: TextSpan(style: TextStyle(fontSize: 10.5, color: dark ? const Color(0xFF8b9199) : const Color(0xFF6f7a83)), children: [
          const TextSpan(text: 'با ادامه، '),
          TextSpan(text: tr('privacy'), style: const TextStyle(color: C.green)),
          const TextSpan(text: ' و '),
          TextSpan(text: tr('rules'), style: const TextStyle(color: C.green)),
          const TextSpan(text: ' را می‌پذیرید.'),
        ])),
        const SizedBox(height: 10),
        Padding(padding: const EdgeInsets.fromLTRB(24, 0, 24, 16), child: Pressable(onTap: () => Navigator.pushReplacement(c, MaterialPageRoute(builder: (_) => const Login())),
          child: Container(height: 46, decoration: BoxDecoration(color: C.green, borderRadius: BorderRadius.circular(23), boxShadow: [BoxShadow(color: C.green.withOpacity(0.35), blurRadius: 14)]),
            alignment: Alignment.center, child: Text(tr('lets_go'), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700))))),
      ]))));
  }
}

class _Slide extends StatelessWidget {
  final int i; final bool dark; const _Slide({required this.i, required this.dark, super.key});
  @override Widget build(BuildContext c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 30), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    CustomPaint(size: const Size(230, 230), painter: _IsoPainter(i: i, dark: dark)),
    const SizedBox(height: 26),
    Text(_slides[i][0], textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: dark ? Colors.white : const Color(0xFF101418))),
    const SizedBox(height: 12),
    Text(_slides[i][1], textAlign: TextAlign.center, style: TextStyle(fontSize: 13, height: 1.9, color: dark ? const Color(0xFF9aa4b2) : const Color(0xFF5c6670))),
  ]));
}

/// تصویرسازی ایزومتریک خطی با لهجه سبز/زرد
class _IsoPainter extends CustomPainter {
  final int i; final bool dark; _IsoPainter({required this.i, required this.dark});
  @override void paint(Canvas canvas, Size s) {
    final line = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5..color = dark ? const Color(0xFF3a4149) : const Color(0xFFc6ccd4);
    final acc = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.8..color = C.green;
    final yel = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.8..color = const Color(0xFFf5c542);
    final c = s.center(Offset.zero);
    // مکعب ایزومتریک پایه
    void cube(Offset o, double r, Paint p) {
      final path = Path()..moveTo(o.dx, o.dy - r)..lineTo(o.dx + r, o.dy - r / 2)..lineTo(o.dx + r, o.dy + r / 2)..lineTo(o.dx, o.dy + r)..lineTo(o.dx - r, o.dy + r / 2)..lineTo(o.dx - r, o.dy - r / 2)..close()
        ..moveTo(o.dx - r, o.dy - r / 2)..lineTo(o.dx, o.dy)..lineTo(o.dx + r, o.dy - r / 2)
        ..moveTo(o.dx, o.dy)..lineTo(o.dx, o.dy + r);
      canvas.drawPath(path, p);
    }
    cube(c, 62, line); cube(c + const Offset(-40, -50), 26, line); cube(c + const Offset(46, -34), 20, acc);
    switch (i) {
      case 0: canvas.drawCircle(c + const Offset(0, -90), 16, acc); canvas.drawCircle(c + const Offset(30, -80), 10, yel); break;
      case 1: canvas.drawArc(Rect.fromCircle(center: c + const Offset(0, -84), radius: 22), 0.6, 4.6, false, acc); canvas.drawLine(c + const Offset(-14, -70), c + const Offset(14, -98), yel); break;
      case 2: canvas.drawRect(Rect.fromLTWH(c.dx - 26, c.dy - 116, 52, 34), acc); canvas.drawLine(c.dx - 18, c.dy - 105, c.dx + 18, c.dy - 105, yel); canvas.drawLine(c.dx - 18, c.dy - 96, c.dx + 8, c.dy - 96, yel); break;
      case 3: canvas.drawCircle(c + const Offset(0, -92), 18, acc); canvas.drawLine(c.dx - 6, c.dy - 92, c.dx + 6, c.dy - 92, yel); canvas.drawLine(c.dx, c.dy - 98, c.dx, c.dy - 86, yel); break;
      default: canvas.drawLine(c.dx - 26, c.dy - 110, c.dx + 26, c.dy - 110, acc); for (int k = 0; k < 4; k++) canvas.drawLine(Offset(c.dx - 20 + k * 13, c.dy - 110), Offset(c.dx - 24 + k * 13, c.dy - 88), line); canvas.drawLine(c.dx - 28, c.dy - 88, c.dx + 22, c.dy - 88, yel); break;
    }
  }
  @override bool shouldRepaint(c) => false;
}
