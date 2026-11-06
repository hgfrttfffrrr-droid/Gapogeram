import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants.dart';
import '../core/i18n.dart';
import '../core/storage.dart';
import '../core/utils.dart';
import 'common.dart';

/// قرص تاریخ (امروز/دیروز/تاریخ کامل)
class DayPill extends StatelessWidget {
  final int ts; const DayPill({super.key, required this.ts});
  @override Widget build(BuildContext c) => Center(child: Container(margin: const EdgeInsets.symmetric(vertical: 6),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), decoration: BoxDecoration(color: const Color(0x99a9b2ba), borderRadius: BorderRadius.circular(14)),
    child: Text(dayLabel(ts), style: const TextStyle(fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.w500))));
}

class QuoteBlock extends StatelessWidget {
  final Msg m; final VoidCallback onTap; const QuoteBlock({super.key, required this.m, required this.onTap});
  @override Widget build(BuildContext c) => GestureDetector(onTap: onTap, child: Container(margin: const EdgeInsets.only(bottom: 6),
    padding: const EdgeInsets.fromLTRB(8, 5, 8, 5), decoration: BoxDecoration(color: const Color(0x14000000), borderRadius: BorderRadius.circular(7)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 3, height: 30, color: const Color(0xFF26c6a6)),
      const SizedBox(width: 7),
      Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text(m.replyName ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF00a884))),
        Text(m.replyText ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, color: Color(0xFF5c6670))),
      ])),
    ])));
}

/// حباب پیام با متای درون‌خطی (چشم+تعداد+زمان) و همه حالت‌ها
class Bubble extends StatelessWidget {
  final Msg m; final bool ownerViewer; final bool saved; final VoidCallback? onLongPress;
  final void Function(String, String) onLink; final void Function(Msg) onQuoteTap;
  final Map<String, GlobalKey> keys; final String? flashId;
  const Bubble({super.key, required this.m, required this.ownerViewer, required this.saved, this.onLongPress, required this.onLink, required this.onQuoteTap, required this.keys, this.flashId});

  @override Widget build(BuildContext c) {
    final right = saved ? true : ownerViewer;
    final bg = (saved || ownerViewer) ? C.mint : Colors.white;
    final metaColor = ownerViewer ? C.ownerMeta : C.memberMeta;
    final meta = <Widget>[
      if (m.pinned) const Icon(Icons.push_pin_outlined, size: 11, color: Color(0xFF98a1ab)),
      if (m.edited) Text(' ${tr('edited')}', style: const TextStyle(fontSize: 10, color: Color(0xFF98a1ab))),
      if (!saved) ...[const Icon(Icons.remove_red_eye_outlined, size: 12.5), const SizedBox(width: 2), Text(faCount(m.views.length), style: const TextStyle(fontSize: 10.5))],
      const SizedBox(width: 5),
      if (saved) Icon(m.views.contains('pending') ? Icons.schedule : Icons.check, size: 12.5, color: const Color(0xFF98a1ab))
      else Icon(m.views.contains('sent') ? Icons.check : Icons.schedule, size: 12.5, color: const Color(0xFF98a1ab)),
      const SizedBox(width: 3),
      Text(faTime(m.ts), style: const TextStyle(fontSize: 10.5)),
    ];
    return Align(alignment: right ? Alignment.centerRight : Alignment.centerLeft, child: GestureDetector(
      onLongPress: onLongPress,
      child: AnimatedContainer(duration: const Duration(milliseconds: 250), key: keys[m.id],
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        padding: const EdgeInsets.fromLTRB(10, 7, 9, 6),
        decoration: BoxDecoration(color: flashId == m.id ? const Color(0x552196f3) : bg, borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 5, offset: const Offset(0, 2))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          if (m.replyTo != null) QuoteBlock(m: m, onTap: () => onQuoteTap(m)),
          Directionality(textDirection: TextDirection.rtl, child: RichText(textDirection: TextDirection.rtl, text: TextSpan(
            style: TextStyle(fontSize: 14.2, height: 1.55, color: const Color(0xFF141a21), fontWeight: FontWeight.w400),
            children: [
              ...linkify(m.text, onTap: onLink),
              WidgetSpan(child: Directionality(textDirection: TextDirection.rtl, child: Row(mainAxisSize: MainAxisSize.min, children: [const SizedBox(width: 8), ...meta.map((w) => DefaultTextStyle(style: TextStyle(fontSize: 10.5, color: metaColor), child: w))]))),
            ]))),
        ]))));
  }
}

/// منوی زمینه پیام (7.8 / 8.5)
class MsgContextMenu extends StatelessWidget {
  final bool saved; final bool pinned; final void Function(String) onPick;
  const MsgContextMenu({super.key, required this.saved, required this.pinned, required this.onPick});
  @override Widget build(BuildContext c) => Center(child: Directionality(textDirection: TextDirection.rtl, child: Material(color: Colors.transparent, child: Container(
    width: 300, padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: const Color(0xFFf7f9fb), borderRadius: BorderRadius.circular(16)),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      _row(Icons.reply_outlined, tr('reply'), 'reply'),
      _row(Icons.push_pin_outlined, pinned ? tr('unpin') : tr('pin'), 'pin'),
      _row(Icons.content_copy_outlined, tr('copy'), 'copy'),
      _row(Icons.send_outlined, tr('bazaar'), 'bazaar', disabled: true),
      if (!saved) _row(Icons.bookmark_outline, tr('save_msg'), 'save'),
      _row(Icons.edit_outlined, tr('edit'), 'edit'),
      _row(Icons.delete_outline, tr('delete_msg'), 'delete'),
    ])))));
  Widget _row(IconData ic, String label, String key, {bool disabled = false}) => Pressable(enabled: !disabled, onTap: () => onPick(key),
    child: Container(width: 300, padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15), color: Colors.transparent,
      child: Row(children: [
        Icon(ic, size: 20, color: disabled ? const Color(0xFFb6bdc6) : const Color(0xFF33415c), weight: 300),
        const SizedBox(width: 18),
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: disabled ? const Color(0xFFb6bdc6) : const Color(0xFF22304a))),
      ])));
}

/// دیالوگ‌های سنجاق/حذف‌سنجاق/حذف
Future<bool?> pinDialog(BuildContext c) => showDialog(context: c, builder: (_) => _Dlg(title: tr('pin_title'), q: tr('pin_q'), ok: tr('pin'), okColor: C.green));
Future<bool?> unpinDialog(BuildContext c) => showDialog(context: c, builder: (_) => _Dlg(title: tr('unpin_title'), q: tr('unpin_q'), ok: 'حذف', okColor: C.green));
Future<bool?> deleteDialog(BuildContext c) => showDialog(context: c, builder: (_) => _Dlg(title: tr('delete_title'), q: tr('delete_q'), ok: tr('delete_confirm'), okColor: const Color(0xFFe05252)));

class _Dlg extends StatelessWidget {
  final String title, q, ok; final Color okColor; const _Dlg({required this.title, required this.q, required this.ok, required this.okColor, super.key});
  @override Widget build(BuildContext c) => Dialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), backgroundColor: Colors.white, child: Directionality(textDirection: TextDirection.rtl, child: Padding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 14), child: Column(mainAxisSize: MainAxisSize.min, children: [
    Align(alignment: Alignment.centerRight, child: Text(title, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: Color(0xFF1d2733)))),
    const Divider(height: 18),
    Align(alignment: Alignment.centerRight, child: Text(q, style: const TextStyle(fontSize: 13, color: Color(0xFF5c6670), height: 1.7))),
    const SizedBox(height: 18),
    Row(children: [
      Expanded(child: TextButton(onPressed: () => Navigator.pop(c, true), child: Container(height: 38, alignment: Alignment.center, decoration: BoxDecoration(color: okColor, borderRadius: BorderRadius.circular(9)), child: Text(ok, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)))),
      const SizedBox(width: 10),
      Expanded(child: TextButton(onPressed: () => Navigator.pop(c, false), child: Container(height: 38, alignment: Alignment.center, decoration: BoxDecoration(border: Border.all(color: const Color(0xFF26c6a6)), borderRadius: BorderRadius.circular(9)), child: Text(tr('cancel'), style: const TextStyle(color: Color(0xFF26c6a6), fontSize: 13, fontWeight: FontWeight.w700)))),
    ]),
  ]))));
}

/// نوار پیام سنجاق‌شده
class PinBar extends StatelessWidget {
  final Msg m; final VoidCallback onTap; final VoidCallback onClose;
  const PinBar({super.key, required this.m, required this.onTap, required this.onClose});
  @override Widget build(BuildContext c) => Pressable(onTap: onTap, child: Container(color: const Color(0xFFf2f5f7), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), child: Directionality(textDirection: TextDirection.rtl, child: Row(children: [
    Container(width: 3.4, height: 30, color: const Color(0xFF00a884)),
    const SizedBox(width: 8),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(tr('pinned'), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF00a884))),
      Text(m.text, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, color: Color(0xFF6f7a83))),
    ])),
    Pressable(onTap: onClose, child: const Icon(Icons.close, size: 17, color: Color(0xFF6f7a83))),
  ]))));
}

/// نوار پاسخ / ویرایش بالای ورودی
class ReplyStrip extends StatelessWidget {
  final String name, snippet; final bool edit; final VoidCallback onClose;
  const ReplyStrip({super.key, required this.name, required this.snippet, this.edit = false, required this.onClose});
  @override Widget build(BuildContext c) => Container(color: const Color(0xFFf4f6f8), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), child: Directionality(textDirection: TextDirection.rtl, child: Row(children: [
    Icon(edit ? Icons.edit_outlined : Icons.reply_outlined, size: 17, color: const Color(0xFF00a884)),
    const SizedBox(width: 7),
    Text(name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF00a884))),
    const SizedBox(width: 8),
    Expanded(child: Text(snippet, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, color: Color(0xFF6f7a83)))),
    Pressable(onTap: onClose, child: const Icon(Icons.close, size: 17, color: Color(0xFF4a5561))),
  ]))));
}

/// اسنک‌بار سنجاق
void pinSnackbar(BuildContext c) {
  ScaffoldMessenger.of(c).showSnackBar(SnackBar(backgroundColor: const Color(0xFF32404f), duration: const Duration(seconds: 2),
    content: Directionality(textDirection: TextDirection.rtl, child: Row(children: const [
      Icon(Icons.push_pin_outlined, size: 15, color: Colors.white70), SizedBox(width: 8),
      Text('پیام سنجاق شد.', style: TextStyle(fontSize: 12.5, color: Colors.white))]))));
}
