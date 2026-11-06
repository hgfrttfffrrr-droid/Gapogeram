import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/i18n.dart';
import 'common.dart';
import 'emoji_panel.dart';

/// نوار ورودی صاحب کانال / پیام‌های ذخیره‌شده (7.6)
class InputBar extends StatefulWidget {
  final TextEditingController ctrl; final bool sending; final VoidCallback onSend;
  final VoidCallback onMic; final bool Function() emojiOpen; final VoidCallback toggleEmoji;
  const InputBar({super.key, required this.ctrl, required this.sending, required this.onSend, required this.onMic, required this.emojiOpen, required this.toggleEmoji});
  @override State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  bool typing = false;
  @override void initState() { super.initState(); widget.ctrl.addListener(() => setState(() => typing = widget.ctrl.text.isNotEmpty)); }
  @override Widget build(BuildContext c) => Container(color: C.strip, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7), child: Directionality(textDirection: TextDirection.rtl, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
    // راست: میکروفن ↔ ارسال
    Pressable(onTap: typing ? widget.onSend : widget.onMic, child: Padding(padding: const EdgeInsets.only(left: 4),
      child: typing ? const SendIcon(size: 42) : const Icon(Icons.mic_none_rounded, size: 23, color: C.slateIcon, weight: 300))),
    const SizedBox(width: 4),
    // وسط: textarea شفاف
    Expanded(child: ConstrainedBox(constraints: const BoxConstraints(maxHeight: 148), child: TextField(
      controller: widget.ctrl, textInputAction: TextInputAction.newline, keyboardType: TextInputType.multiline, maxLines: 6, minLines: 1,
      style: const TextStyle(fontSize: 14.5, color: Color(0xFF1c2430), height: 1.5),
      decoration: const InputDecoration(isDense: true, border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 9, horizontal: 4),
        hintText: 'پیام خود را بنویسید...', hintStyle: TextStyle(fontSize: 13.5, color: Color(0xFF9aa4b2)))))),
    const SizedBox(width: 2),
    // چپ: لبخند + плюс
    Pressable(onTap: widget.toggleEmoji, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: Icon(Icons.emoji_emotions_outlined, size: 22, color: C.slateIcon, weight: 300))),
    if (!typing) Pressable(onTap: () {}, child: const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.add_circle_outline, size: 22, color: C.slateIcon, weight: 300))),
  ]))));
}
