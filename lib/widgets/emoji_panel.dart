import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/i18n.dart';
import '../core/storage.dart';
import 'common.dart';

/// داده ایموجی: دسته‌ها + پایه‌های دارای تُن پوستی
const Map<String, List<String>> EMOJI_CATS = {
  'smiley': ['😀','😃','😄','😁','😆','😅','🤣','😂','🙂','🙃','😉','😊','😇','🥰','😍','🤩','😘','😗','😚','😙','🥲','😋','😛','😜','🤪','😝','','🤗','🤭','🤫','','','🤨','😐','😑','😶','😏','😒','🙄','😬','🤥','😌','😔','😪','🤤','😴','😷','🤒','','🤢','','🥵','🥶','🥴','😵','🤯','🤠','🥳','🥸','😎','🤓','🧐','','😟','','☹️','😮','😯','😲','😳','🥺','','😧','😨','😰','😥','😢','😭','😱','😖','😣','😞','😓','😩','😫','🥱','😤','😡','😠','🤬','😈','👿','💀','☠️','💩','🤡','👹','👺','👻','👽','👾','🤖','','😸','😹','😻','😼','😽','🙀','😿','😾'],
  'gesture': ['👋','🤚','️','✋','🖖','','🤌','🤏','✌️','🤞','','🤘','🤙','👈','👉','','🖕','','☝️','👍','👎','✊','','','🤜','','🙌','👐','🤲','🤝','','✍️','💅','🤳','💪','🦾','🦵','🦶','👂','🦻','','🧠','','🫁','🦷','','👀','👁️','👅','👄'],
  'animals': ['🐶','🐱','🐭','🐹','🐰','🦊','','🐼','🐨','🐯','🦁','','🐷','🐸','🐵','🙈','','🙊','','🐔','','🐦','🐤','🐣','🐥','🦆','🦅','','🦇','🐺','','🐴','🦄','','🪱','','🦋','🐌','🐞','🐜','🪰','','🪳','🦟','🦗','🕷️','🕸️','🦂','🐢','🐍','🦎','🦖','🦕','🐙','🦑','🦐','','🦀','🐡','','🐟','','🐳','🐋','','🐊','','🐆','🦓','','🦧','','🦛','🦏','🐪','','🦒','','🦬','','🐂','🐄','🐎','🐖','🐏','🐑','🦙','','🦌','🐕','🐩','','🐈','🐓','🦃','','🦜','','🦩','🕊️','🐇','','🦨','🦡','🦫','🦦','🦥','🐁','','🐿️','🦔'],
  'food': ['🍏','','🍐','🍊','','🍌','','🍇','🍓','🫐','🍈','🍒','🍑','🥭','🍍','🥥','🥝','🍅','','🥑','🥦','🥬','','🌶️','🫑','🌽','🥕','🫒','🧄','🧅','🥔','🍠','🥐','🥯','','🥖','','🧀','🥚','🍳','🧈','','🧇','🥓','','🍗','','🦴','','🍔','🍟','🍕','🫓','🥪','🥙','','🌮','🌯','🫔','🥗','','🫕','','🍝','🍜','🍲','🍛','🍣','🍱','','🦪','','🍙','🍚','🍘','🍥','🥠','🥮','🍢','🍡','🍧','🍨','🍦','🥧','','🍰','','🍮','','🍬','','🍿','🍩','🍪','🌰','','🍯','','🍼','','☕','🍵','','🥤','','🍶','','🍻','🥂','🍷','🥃','🍸','','🧉','','🧊','','🍴','️','🥣','🥡','🥢','🧂'],
  'activity': ['⚽','🏀','🏈','⚾','🥎','','🏐','🏉','🥏','🎱','🪀','🏓','🏸','🏒','🏑','🥍','🏏','🪃','🥅','⛳','🪁','🏹','🎣','🤿','🥊','','🎽','🛹','🛼','🛷','⛸️','🥌','','⛷️','🏂','','🏋️','🤼','🤸','⛹️','🤺','🤾','🏌️','🏇','🧘','','🏊','','🚣','','🚵','','🏆','🥇','','🥉','','🎖️','🏵️','🎗️','🎫','🎟️','🎪','🤹','','🩰','🎨','🎬','🎤','🎧','🎼','🎹','🥁','','🎷','🎺','🪗','','🪕','','🎲','♟️','🎯','🎳','🎮','🎰','🧩'],
  'travel': ['🚗','','🚙','🚌','🚎','️','🚓','🚑','🚒','','🛻','','🚛','🚜','🦯','🦽','🦼','🛴','🚲','','🏍️','🛺','🚨','','🚍','','🚖','','🚠','🚟','','🚋','','🚝','','🚅','','🚂','','🚇','','🚉','️','🛫','🛬','🛩️','💺','🛰️','🚀','','🚁','🛶','⛵','🚤','️','🛳️','⛴️','🚢','⚓','🪝','⛽','🚧','🚦','🚥','🚏','🗺️','🗿','🗽','🗼','🏰','🏯','🏟️','🎡','🎢','🎠','⛲','⛱️','️','🏝️','🏜️','🌋','⛰️','🏔️','🗻','🏕️','⛺','🛖','🏠','🏡','🏘️','🏚️','🏗️','🏭','🏢','🏬','','🏤','','🏦','','🏪','','🏩','💒','️','','🕌','','','🕋','⛩️','🛤️','🛣️','','','🏞️','','','🌠','🎇','','🌇','🌆','🏙️','','🌌','🌉','🌁'],
  'objects': ['⌚','','📲','💻','⌨️','🖥️','🖨️','🖱️','🖲️','🕹️','🗜️','💽','💾','💿','📀','📼','📷','📸','📹','🎥','📽️','🎞️','📞','☎️','📟','📠','📺','📻','🎙️','🎚️','🎛️','🧭','⏱️','⏲️','⏰','🕰️','⌛','⏳','📡','🔋','🔌','💡','🔦','🕯️','🪔','🧯','🛢️','💸','💵','💴','💶','💷','🪙','💰','💳','💎','⚖️','🪜','🧰','🪛','🔧','🔨','⚒️','️','️','','🔩','⚙️','🪤','🧱','⛓️','🧲','🔫','💣','🧨','🪓','🔪','🗡️','⚔️','🛡️','🚬','⚰️','🪦','⚱️','🏺','🔮','📿','🧿','💈','⚗️','🔭','🔬','🕳️','🩹','🩺','💊','💉','🩸','🧬','','🧫','🧪','🌡️','🧹','🪠','','🧻','🚽','🚰','🚿','🛁','🛀','🧼','🪥','🪒','🧽','🪣','🧴','🛎️','🔑','🗝️','','','🛋️','🛏️','🛌','🧸','','🖼️','','🪟','🛍️','🛒','🎁','🎈','🎏','🎀','🪄','','🎊','','🎎','','🎐','','✉️','','📨','📧','','📥','📤','📦','🏷️','🪧','📪','📫','📬','📭','📮','📯','📜','📃','📄','','🧾','','📈','','🗒️','🗓️','📆','','🗑️','','️','🗳️','🗄️','📋','📁','📂','🗂️','🗞️','📰','📓','','📒','','📗','','📙','📚','📖','','🧷','','📎','🖇️','📐','📏','🧮','','📍','✂️','🖊️','🖋️','️','🖌️','🖍️','📝','️','🔍','🔎','🔏','🔐','🔒',''],
  'symbols': ['❤️','🧡','💛','💚','💙','💜','🖤','🤍','🤎','💔','❣️','💕','💞','💓','💗','💖','💘','💝','💟','☮️','✝️','☪️','🕉️','☸️','✡️','🔯','🕎','☯️','☦️','🛐','⛎','♈','♉','♊','♋','♌','♍','♎','♏','♐','♑','♒','♓','🆔','⚛️','','☢️','☣️','📴','📳','','🈚','','🈺','️','✴️','🆚','💮','🉐','㊙️','㊗️','🈴','🈵','','🈲','️','️','','🆑','🅾️','🆘','❌','','🛑','⛔','📛','🚫','','💢','️','🚷','🚯','🚳','🚱','🔞','📵','','❗','','❓','❔','‼️','⁉️','🔅','🔆','〽️','⚠️','🚸','🔱','⚜️','🔰','♻️','✅','🈯','💹','❇️','✳️','❎','','💠','Ⓜ️','🌀','💤','🏧','🚾','','🅿️','🛗','🈳','🈂️','🛂','🛃','🛄','🛅','','🚺','','⚧️','🚻','🚮','🎦','📶','🈁','🔣','ℹ️','🔤','🔡','🔠','🆖','','🆙','','🆕','','0️','1️⃣','2️⃣','3️⃣','4️⃣','5️⃣','6️⃣','7️⃣','8️⃣','9️⃣','','🔢','#️⃣','*️⃣','️','▶️','️','️','⏹️','⏺️','️','️','⏩','⏪','⏫','⏬','◀️','▶️','🔼','🔽','➡️','️','️','⬇️','↗️','↘️','↙️','↖️','↕️','↔️','↪️','↩️','⤴️','⤵️','🔀','','🔂','🔄','🔃','','🎶','','➖','➗','✖️','💲','💱','™️','©️','®️','〰️','➰','➿','🔚','🔙','🔛','🔝','🔜','✔️','☑️','🔘','🔴','🟠','','🟢','','🟣','','','🟤','','🔻','','🔹','','🔷','','🔲','▪️','▫️','◾','◽','◼️','◻️','🟥','','🟨','','🟦','','⬛','⬜','🟫','','🔇','🔉','🔊','🔔','🔕','📣','📢','️‍️','💬','💭','🗯️','♠️','♣️','♥️','♦️','🃏','🎴','','🕐','🕑','','🕓','','🕕','','🕗','','🕙','','🕛'],
  'flags': ['🏳️','🏴','🏴‍️','','🏁','🎌','🏳️‍🌈','🏳️‍⚧️','🇷','🇦🇫','🇦🇱','🇩🇿','🇩','🇦🇴','🇦','🇦🇲','🇦🇺','🇦🇹','🇿','🇧🇭','🇧🇩','🇧🇾','🇧🇪','🇴','🇧🇦','🇷','🇧🇬','🇭','🇦','🇨🇱','🇳','🇨🇴','🇨','🇷','🇺','🇾','🇿','🇩🇰','🇨','🇬','🇪','🇹','🇫🇮','🇷','🇬🇪','🇪','🇬🇭','🇷','🇺','🇮🇸','🇳','🇩','🇶','🇪','🇮🇱','🇹','🇵','🇴','🇰🇿','🇰🇪','🇰🇼','🇻','🇱🇧','🇾','🇱🇹','🇾','🇻','🇲🇽','🇳','🇲🇦','🇱','🇳🇿','🇳🇬','🇰🇵','🇴','🇴🇲','🇰','🇵🇸','🇦','🇵🇾','🇵🇪','🇭','🇵🇱','🇹','🇦','🇷🇴','🇷🇺','🇸🇦','🇳','🇷🇸','🇸🇬','🇰','🇸🇮','🇦','🇰🇷','🇸','🇰','🇩','🇸🇪','🇭','🇸🇾','🇹🇯','🇹🇿','🇹🇭','🇳','🇹🇷','🇹🇲','🇺🇦','🇪','🇬🇧','🇺🇸','🇾','🇿','🇻🇪','🇳','🇾🇪','🇲'],
};

/// پایه‌هایی که ۶ تُن پوستی دارند
const List<String> TONE_BASES = ['👋','🤚','️','✋','🖖','','🤌','','✌️','','🤟','🤘','🤙','','👉','','🖕','','☝️','👍','👎','✊','','🤛','','👏','','👐','','🤝','','✍️','💅','🤳','💪','🦵','🦶','','🦻','','🧑','','👦','','👨','','🧓','','👵','','🙎','','🙆','','🙋','','🙇','🤦','','👮','️','💂','🥷','👷','🤴','👸','👳','','🧕','','👰','🤰','🤱','👼','🎅','🤶','','🦹','','🧚','','🧜','','🧞','','💆','💇','🚶','🧍','🧎','🏃','💃','','️','','🧖','','🏇','','🏌️','🏄','🚣','','⛹️','️','','🚵','','🤼','','🤾','','⛷️','🏆','🥇','','🥉','🏅'];
const List<String> TONES = ['', '🏻', '', '', '🏾', '🏿'];

const Map<String, List<String>> EMOJI_SEARCH = {
  'خنده': ['😀','😂','🤣','😄','😁','😆'], 'قلب': ['❤️','🧡','💛','💚','💙','💜','','💔','💕'],
  'پرچم': EMOJI_CATS['flags'] ?? [], 'ماشین': ['🚗','','🚙','🚌','🏎️','🚓','🚑','🚒','🚐','🚚','🚲','🏍️'],
  'حیوان': EMOJI_CATS['animals'] ?? [], 'غذا': EMOJI_CATS['food'] ?? [], 'ساعت': ['⌚','⏰','⏱️','⌛','','🕒','🕕','🕘'],
  'پول': ['💰','💵','💴','💶','💷','💳','💎','🪙','💸'], 'گل': ['🌸','🌹','🌺','🌻','🌼','🌷'],
  'ستاره': ['⭐','🌟','✨','💫'], 'آتش': ['🔥','✨','🎇','🎆'],
};

class EmojiPanel extends StatefulWidget {
  final TextEditingController ctrl; final bool showSearchBox; final VoidCallback toggleSearch;
  const EmojiPanel({super.key, required this.ctrl, required this.showSearchBox, required this.toggleSearch});
  @override State<EmojiPanel> createState() => _EmojiPanelState();
}

class _EmojiPanelState extends State<EmojiPanel> {
  String cat = 'smiley'; String q = ''; final TextEditingController _q = TextEditingController();
  OverlayEntry? _popup; int _pick = -1; bool _moved = false;

  static const _catIcons = {'recent': Icons.access_time, 'smiley': Icons.emoji_emotions_outlined, 'animals': Icons.pets_outlined,
    'food': Icons.restaurant_outlined, 'activity': Icons.sports_soccer_outlined, 'travel': Icons.directions_car_outlined,
    'objects': Icons.lightbulb_outline, 'symbols': Icons.symbol, 'flags': Icons.flag_outlined};

  List<String> get items {
    if (q.isNotEmpty) { final hits = EMOJI_SEARCH.entries.where((e) => e.key.contains(q)).expand((e) => e.value).toList(); return hits.isEmpty ? EMOJI_CATS.values.expand((e) => e).where((e) => e.contains(q)).toList() : hits; }
    if (cat == 'recent') return Storage.recents();
    if (cat == 'gesture') return EMOJI_CATS['gesture']!;
    return EMOJI_CATS[cat] ?? const [];
  }

  void _insert(String e) {
    widget.ctrl.text += e; widget.ctrl.selection = TextSelection.collapsed(offset: widget.ctrl.text.length);
    final r = Storage.recents()..remove(e)..insert(0, e); Storage.setRecents(r.take(24).toList());
    setState(() {});
  }

  void _showTones(String base, Offset global) {
    _pick = -1; _moved = false;
    _popup = OverlayEntry(builder: (_) => Positioned(left: global.dx - 110, top: global.dy - 74, child: Material(color: Colors.transparent, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: const Color(0xE6202024), borderRadius: BorderRadius.circular(14)),
      child: Row(mainAxisSize: MainAxisSize.min, children: List.generate(6, (i) => GestureDetector(
        onTap: () { _insert(TONE_BASES.contains(base) ? base + TONES[i] : base); _hide(); },
        child: Container(width: 36, height: 36, alignment: Alignment.center,
          decoration: BoxDecoration(shape: BoxShape.circle, color: _pick == i ? Colors.white24 : Colors.transparent),
          child: Text(base + TONES[i], style: const TextStyle(fontSize: 22)))))))));
    Overlay.of(context).insert(_popup!);
  }
  void _hide() { _popup?.remove(); _popup = null; }

  @override void dispose() { _hide(); _q.dispose(); super.dispose(); }

  @override Widget build(BuildContext c) {
    final recents = Storage.recents();
    return Container(color: const Color(0xFFf4f6f8), child: Column(children: [
      if (widget.showSearchBox) Padding(padding: const EdgeInsets.fromLTRB(10, 8, 10, 4), child: Directionality(textDirection: TextDirection.rtl, child: Row(children: [
        Expanded(child: Container(height: 34, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: TextField(controller: _q, onChanged: (v) => setState(() => q = v), style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(border: InputBorder.none, isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), hintText: 'جستجوی ایموجی...', hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF9aa4b2))))),
        if (q.isNotEmpty) IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () { _q.clear(); setState(() => q = ''); })]))),
      // ردیف دسته‌ها
      Directionality(textDirection: TextDirection.rtl, child: SizedBox(height: 40, child: Row(children: [
        for (final entry in {'recent': null, ..._catIcons.skip(1)}.entries)
          if (entry.key != 'recent' || recents.isNotEmpty || true)
            _catBtn(entry.key),
      ]))),
      // اخیر
      if (cat == 'recent' || (q.isEmpty && recents.isNotEmpty && false)) const SizedBox.shrink(),
      if (recents.isNotEmpty && cat != 'recent' && q.isEmpty)
        Directionality(textDirection: TextDirection.rtl, child: Align(alignment: Alignment.centerRight, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('اموجی‌های اخیر', style: const TextStyle(fontSize: 11, color: Color(0xFF8a94a3)))))),
      if (recents.isNotEmpty && cat != 'recent' && q.isEmpty)
        SizedBox(height: 40, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 10), children: [
          for (final e in recents.take(12)) _emoji(e, recent: true)])),
      // گرید
      Expanded(child: Directionality(textDirection: TextDirection.rtl, child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8, childAspectRatio: 1),
        itemCount: items.length, itemBuilder: (_, i) => _emoji(items[i])))),
      // ردیف پایین
      Directionality(textDirection: TextDirection.rtl, child: Container(height: 40, color: const Color(0xFFe9edf1), child: Row(children: [
        Pressable(onTap: () { final t = widget.ctrl.text; if (t.isNotEmpty) { widget.ctrl.text = t.substring(0, t.length - 1); widget.ctrl.selection = TextSelection.collapsed(offset: widget.ctrl.text.length); } },
          child: const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Icon(Icons.backspace_outlined, size: 19, color: Color(0xFF5a6472)))),
        const Spacer(),
        Text(tr('emoji'), style: const TextStyle(color: C.green, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(width: 14),
        Pressable(onTap: () => Navigator.pop(context), child: const Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xFF5a6472))),
        const SizedBox(width: 14),
        Pressable(onTap: widget.toggleSearch, child: Icon(Icons.search, size: 18, color: widget.showSearchBox ? C.green : const Color(0xFF5a6472))),
        const SizedBox(width: 12),
      ]))),
    ]));
  }

  Widget _catBtn(String key) {
    final active = cat == key;
    return Pressable(onTap: () => setState(() => cat = key), child: Container(width: 42, alignment: Alignment.center,
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: active ? const Color(0xFF1e88e5) : Colors.transparent, width: 2))),
      child: Icon(_catIcons[key] ?? Icons.emoji_emotions_outlined, size: 19, color: active ? const Color(0xFF1e88e5) : const Color(0xFF7b8794))));
  }

  Widget _emoji(String e, {bool recent = false}) => GestureDetector(
    onTap: () => _insert(e),
    onLongPressStart: (d) { if (TONE_BASES.contains(e)) { _moved = false; _showTones(e, d.globalPosition); } else if (recent) { _clearDialog(); } },
    onLongPressMoveUpdate: (d) { if (_popup != null) { _moved = true; final i = ((d.localPosition.dx + 110) / 36).floor().clamp(0, 5); setState(() => _pick = i); _rebuildTones(e); } },
    onLongPressEnd: (_) { if (_popup != null) { if (_pick >= 0) _insert(e + TONES[_pick]); else if (!_moved) _insert(e); _hide(); } },
    child: Container(alignment: Alignment.center, child: Text(e, style: const TextStyle(fontSize: 24))));

  void _rebuildTones(String base) { _popup?.markNeedsBuild(); }

  void _clearDialog() => showDialog(context: context, builder: (_) => AlertDialog(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    title: Text(tr('clear_emoji_title'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1d2733))),
    content: Text(tr('clear_emoji_q'), style: const TextStyle(fontSize: 12.5, color: Color(0xFF6f7a83))),
    actions: [
      TextButton(onPressed: () { Storage.setRecents([]); Navigator.pop(context); setState(() {}); },
        child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(border: Border.all(color: const Color(0xFFe05252)), borderRadius: BorderRadius.circular(8)), child: Text(tr('clear_all'), style: const TextStyle(color: Color(0xFFe05252), fontSize: 12.5)))),
      TextButton(onPressed: () => Navigator.pop(context),
        child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(border: Border.all(color: const Color(0xFFb9c1cc)), borderRadius: BorderRadius.circular(8)), child: Text(tr('cancel'), style: const TextStyle(color: Color(0xFF6f7a83), fontSize: 12.5)))),
    ]));
                                        }
