import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/i18n.dart';
import '../core/services.dart';
import '../widgets/common.dart';

class LanguageScreen extends StatefulWidget { const LanguageScreen({super.key}); @override State<LanguageScreen> createState() => _LanguageScreenState(); }

class _LanguageScreenState extends State<LanguageScreen> {
  bool showBtn = true, fullTr = false; String lang = Prefs.I.lang;

  @override Widget build(BuildContext c) {
    final dark = Prefs.I.dark; SystemChromeStyle.apply(dark: dark);
    return AnimatedContainer(duration: const Duration(milliseconds: 320), color: dark ? C.darkBg : const Color(0xFFf4f6f8), child: Scaffold(backgroundColor: Colors.transparent,
      body: SafeArea(child: Directionality(textDirection: TextDirection.rtl, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(10, 8, 10, 0), child: Row(children: [
          Pressable(onTap: () => Navigator.pop(c), child: const Icon(Icons.chevron_right_rounded, size: 24, color: Color(0xFF9aa4b2))),
          const SizedBox(width: 6),
          Text(tr('language'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: dark ? Colors.white : const Color(0xFF101418))),
          const Spacer(),
          Pressable(onTap: () async { await Prefs.I.setLang(lang); Navigator.pop(c); }, child: const Icon(Icons.check_circle_outline, size: 21, color: C.green)),
        ])),
        const SizedBox(height: 14),
        _label(tr('msg_translation')),
        Container(margin: const EdgeInsets.symmetric(horizontal: 14), decoration: BoxDecoration(color: dark ? const Color(0xFF17171a) : Colors.white, borderRadius: BorderRadius.circular(14)), child: Column(children: [
          _switch(tr('show_translate_btn'), showBtn, (v) => showBtn = v),
          _switch(tr('full_translate'), fullTr, (v) => fullTr = v),
        ])),
        Padding(padding: const EdgeInsets.fromLTRB(20, 10, 20, 2), child: Text(tr('tr_help1'), style: TextStyle(fontSize: 11, height: 1.8, color: dark ? const Color(0xFF8b9199) : const Color(0xFF6f7a83)))),
        Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 8), child: Text(tr('tr_help2'), style: TextStyle(fontSize: 11, height: 1.8, color: dark ? const Color(0xFF8b9199) : const Color(0xFF6f7a83)))),
        _label(tr('default_lang')),
        Container(margin: const EdgeInsets.symmetric(horizontal: 14), decoration: BoxDecoration(color: dark ? const Color(0xFF17171a) : Colors.white, borderRadius: BorderRadius.circular(14)), child: Column(children: [
          _radio('فارسی / Persian', 'fa'), _radio('English / English', 'en'), _radio('العربية / Arabic', 'ar'),
        ])),
      ])))));
  }

  Widget _label(String t) => Padding(padding: const EdgeInsets.fromLTRB(20, 6, 20, 6), child: Text(t, style: const TextStyle(fontSize: 12, color: Color(0xFF8b9199))));
  Widget _switch(String t, bool v, void Function(bool) set) => ListTile(dense: true, title: Text(t, style: TextStyle(fontSize: 13.5, color: Prefs.I.dark ? Colors.white87 : const Color(0xFF1c2430))),
    trailing: Switch(value: v, activeColor: C.green, onChanged: (x) => setState(() => set(x))));
  Widget _radio(String t, String code) => ListTile(dense: true, title: Text(t, style: TextStyle(fontSize: 13.5, color: Prefs.I.dark ? Colors.white87 : const Color(0xFF1c2430))),
    trailing: Icon(lang == code ? Icons.check_circle : Icons.radio_button_unchecked, size: 20, color: lang == code ? const Color(0xFF1e88e5) : const Color(0xFFb9c1cc)),
    onTap: () => setState(() => lang = code));
}
