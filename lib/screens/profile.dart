import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import '../core/backend.dart';
import '../core/constants.dart';
import '../core/i18n.dart';
import '../core/services.dart';
import '../core/storage.dart';
import '../widgets/common.dart';
import 'editor.dart';
import 'language.dart';
import 'main_screen.dart';

const _presets = [
  ['سبز گپروم', Color(0xFF00b894)], ['آبی کلاسیک', Color(0xFF2f80ed)], ['بنفش سلطنتی', Color(0xFF8e44ad)],
  ['نارنجی طلایی', Color(0xFFf2994a)], ['سرخابی', Color(0xFFeb5757)], ['فیروزه‌ای', Color(0xFF26c6da)],
];

class ProfileScreen extends StatefulWidget {
  final String phone; const ProfileScreen({super.key, required this.phone});
  @override State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _fn = TextEditingController(), _ln = TextEditingController();
  String? avatar; bool nameErr = false;

  Future<void> _sheet() async {
    await showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => _GallerySheet(onPicked: (p) { Navigator.pop(context); _edit(p); }, onPreset: (c) { Navigator.pop(context); setState(() => avatar = null); _preset(c); }));
  }

  void _preset(Color c) async {
    // پیش‌فرض: رنگ به‌عنوان آواتار موقت ذخیره نمی‌شود؛ مستقیم ورود با glyph رنگی
    await Storage.set('preset:${widget.phone}', c.value);
    setState(() {});
  }

  void _edit(File f) async {
    final out = await Navigator.push<File>(context, MaterialPageRoute(builder: (_) => PhotoEditor(file: f)));
    if (out != null) setState(() => avatar = out.path);
  }

  Future<void> _enter() async {
    if (_fn.text.trim().isEmpty) { setState(() => nameErr = true); await Future.delayed(const Duration(milliseconds: 500)); setState(() => nameErr = false); return; }
    final u = User(phone: widget.phone, first: _fn.text.trim(), last: _ln.text.trim(), avatarPath: avatar, verified: true, joined: DateTime.now().millisecondsSinceEpoch);
    await Backend.registerUser(u);
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainScreen()), (r) => false); // 0.6 قفل تاریخچه
  }

  @override Widget build(BuildContext c) {
    final dark = Prefs.I.dark; SystemChromeStyle.apply(dark: dark);
    return AnimatedContainer(duration: const Duration(milliseconds: 320), color: dark ? C.darkBg : Colors.white, child: Scaffold(backgroundColor: Colors.transparent,
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(14, 10, 14, 0), child: Row(children: [
          Pressable(onTap: () => Navigator.pushAndRemoveUntil(c, MaterialPageRoute(builder: (_) => const MainScreen()), (r) => false), child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF9aa4b2))),
          const Spacer(),
          Pressable(onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => const LanguageScreen())), child: Container(width: 38, height: 38, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: dark ? const Color(0xFF3a3f47) : const Color(0xFFd4d8dd), width: 1.1)), child: const Icon(Icons.translate_outlined, size: 18, color: Color(0xFF9aa4b2), weight: 300))),
        ])),
        const SizedBox(height: 26),
        Pressable(onTap: _sheet, child: UserAvatar(path: avatar, size: 96)),
        const SizedBox(height: 10),
        Pressable(onTap: _sheet, child: Text(tr('add_photo'), style: const TextStyle(fontSize: 12, color: C.green, fontWeight: FontWeight.w600))),
        const SizedBox(height: 26),
        _field(_fn, '${tr('first_name')} *', true),
        const SizedBox(height: 12),
        _field(_ln, tr('last_name'), false),
        const Spacer(),
        Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 6), child: Text(tr('terms_note'), textAlign: TextAlign.center, style: TextStyle(fontSize: 10.5, color: dark ? const Color(0xFF8b9199) : const Color(0xFF6f7a83)))),
        Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: Pressable(onTap: _enter, child: Container(height: 48, decoration: BoxDecoration(color: C.green, borderRadius: BorderRadius.circular(13), boxShadow: [BoxShadow(color: C.green.withOpacity(0.35), blurRadius: 14)]), alignment: Alignment.center, child: Text(tr('enter'), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)))),
      ]))));
  }

  Widget _field(TextEditingController c, String label, bool required) => Directionality(textDirection: TextDirection.rtl, child: AnimatedContainer(duration: const Duration(milliseconds: 200),
    margin: const EdgeInsets.symmetric(horizontal: 24), height: 50,
    decoration: BoxDecoration(color: Prefs.I.dark ? const Color(0xFF17171a) : const Color(0xFFf6f7f9), borderRadius: BorderRadius.circular(12),
      border: Border.all(color: nameErr && required ? const Color(0xFFe05252) : const Color(0xFF2c2c30), width: 1)),
    child: TextField(controller: c, style: const TextStyle(fontSize: 14, color: Color(0xFFe8eaee)),
      decoration: InputDecoration(border: InputBorder.none, isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        labelText: label, labelStyle: TextStyle(fontSize: 12.5, color: nameErr && required ? const Color(0xFFe05252) : const Color(0xFF8b9199))))));
}

/// شیت گالری: گرید بومی عکس‌های دستگاه + نمونه‌های آماده
class _GallerySheet extends StatefulWidget {
  final void Function(File) onPicked; final void Function(Color) onPreset;
  const _GallerySheet({required this.onPicked, required this.onPreset});
  @override State<_GallerySheet> createState() => _GallerySheetState();
}

class _GallerySheetState extends State<_GallerySheet> {
  List<File> photos = []; bool loaded = false;

  Future<void> _load() async {
    final st = await Permission.photos.request();
    if (!st.isGranted) await Permission.storage.request();
    final albums = await PhotoManager.getAssetPathList(type: RequestType.image);
    if (albums.isEmpty) { setState(() => loaded = true); return; }
    final assets = await albums.first.getAssetListRange(start: 0, end: 500);
    final files = <File>[];
    for (final a in assets) { final f = await a.file; if (f != null) files.add(f); }
    setState(() { photos = files; loaded = true; });
  }

  @override Widget build(BuildContext c) => Container(height: MediaQuery.of(c).size.height * 0.82, decoration: const BoxDecoration(color: Color(0xFF141416), borderRadius: BorderRadius.vertical(top: Radius.circular(22)), ),
    child: Column(children: [
      Container(margin: const EdgeInsets.only(top: 10), width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF3a3f47), borderRadius: BorderRadius.circular(2))),
      Padding(padding: const EdgeInsets.fromLTRB(16, 10, 16, 6), child: Row(children: [
        Text(tr('gallery_title'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        const Spacer(),
        Pressable(onTap: () => Navigator.pop(c), child: const Icon(Icons.close, size: 18, color: Color(0xFF9aa4b2))),
      ])),
      Pressable(onTap: _load, child: Container(margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: const Color(0xFF1d1d21), borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
          Icon(Icons.add_photo_alternate_outlined, size: 18, color: C.green), SizedBox(width: 8),
          Text('باز کردن گالری گوشی (انتخاب فایل)', style: TextStyle(fontSize: 12.5, color: Colors.white87)),
        ]))),
      Padding(padding: const EdgeInsets.fromLTRB(18, 8, 18, 6), child: Align(alignment: Alignment.centerRight, child: Text(tr('or_presets'), style: const TextStyle(fontSize: 11.5, color: Color(0xFF8b9199))))),
      GridView.count(crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: 1.15, children: [
        for (final p in _presets) Pressable(onTap: () => widget.onPreset(p[1] as Color), child: Container(margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: p[1] as Color, borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.person_rounded, color: Colors.white, size: 40)))
      ]),
      const Divider(height: 14, color: Color(0xFF26262b)),
      Expanded(child: !loaded ? const Center(child: CircularProgressIndicator(color: C.green, strokeWidth: 2)) :
        GridView.builder(padding: const EdgeInsets.all(8), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 6, mainAxisSpacing: 6),
          itemCount: photos.length, itemBuilder: (_, i) => Pressable(onTap: () => widget.onPicked(photos[i]), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(photos[i], fit: BoxFit.cover))))),
    ]));
}
