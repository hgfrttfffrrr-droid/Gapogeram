import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/backend.dart';
import '../core/constants.dart';
import '../core/i18n.dart';
import '../core/services.dart';
import '../core/storage.dart';
import '../core/utils.dart';
import '../widgets/chat_widgets.dart';
import '../widgets/common.dart';
import '../widgets/emoji_panel.dart';
import '../widgets/input_bar.dart';
import 'browser.dart';
import 'main_screen.dart';

class ChatPage extends StatefulWidget {
  final String chat; // 'channel' | 'saved'
  const ChatPage({super.key, required this.chat});
  @override State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _sc = ScrollController();
  final Map<String, GlobalKey> _keys = {};
  String? flashId; Msg? replyTo; Msg? editing; bool emoji = false, showSearch = false, muted = false;
  Timer? poll; String? focusPost;
  late User me; bool get saved => widget.chat == 'saved';
  String get chatId => saved ? 'saved:${me.phone}' : 'channel';
  bool get owner => C.isOwner(me.phone);

  @override void initState() {
    super.initState();
    me = Storage.users().lastWhere((u) => u.verified);
    muted = Storage.mute(me.phone);
    poll = Timer.periodic(const Duration(seconds: 3), (_) async { await Backend.syncChannel(); _refresh(); _flushQueue(); });
    WidgetsBinding.instance.addPostFrameCallback((_) { _markRead(); _refresh(); });
  }
  @override void dispose() { poll?.cancel(); super.dispose(); }

  List<Msg> get msgs => saved ? Storage.msgs('saved').where((m) => m.chat == chatId).toList() : Storage.msgs('channel');

  void _refresh() { if (mounted) setState(() {}); }

  Future<void> _markRead() async { if (!saved) { await Storage.setLastRead(me.phone, 'channel'); } }

  /// ارسال صف آفلاین هنگام بازگشت اتصال
  Future<void> _flushQueue() async {
    if (!Conn.I.online) return;
    for (final q in List<Map<String, dynamic>>.from(Storage.queue())) {
      final m = Msg.fromJson(q);
      if (saved) { m.views.remove('pending'); m.views.add('sent'); await Storage.putMsg(m); }
      else await Backend.publish(m);
      await Storage.dequeue(m.id); await Sound.send(); _refresh();
    }
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim(); if (text.isEmpty) return;
    _ctrl.clear(); setState(() {});
    final m = Msg(id: uid(), chat: chatId, sender: me.phone, text: text, ts: DateTime.now().millisecondsSinceEpoch, views: saved ? ['sent'] : [],
      replyTo: replyTo?.id, replyName: replyTo?.replyName ?? (saved ? tr('saved_title') : tr('official_channel')), replyText: replyTo?.text);
    // نام فرستنده در نقل‌قول هنگام ارسال ذخیره می‌شود:
    m.replyName = replyTo != null ? (saved ? tr('saved_title') : tr('official_channel')) : null;
    setState(() => replyTo = null);
    if (!Conn.I.online) {
      if (saved) { m.views.clear(); m.views.add('pending'); await Storage.putMsg(m); }
      else { m.views.add('pending'); await Storage.putMsg(m); }
      await Storage.enqueue(m.toJson()); _refresh(); return;
    }
    if (saved) { await Storage.putMsg(m); await Sound.send(); }
    else { await Backend.publish(m); await Sound.send(); if (owner) Notif.post(tr('official_channel'), text, m.id); }
    _refresh();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sc.animateTo(_sc.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut));
  }

  void _menu(Msg m) async {
    final pick = await showModalBottomSheet<String>(context: context, backgroundColor: Colors.transparent, builder: (_) => MsgContextMenu(saved: saved, pinned: m.pinned, onPick: (k) => Navigator.pop(context, k)));
    if (pick == null) return;
    switch (pick) {
      case 'reply': setState(() => replyTo = m); break;
      case 'copy': await Clipboard.setData(ClipboardData(text: m.text)); break;
      case 'save': await Storage.putMsg(Msg(id: uid(), chat: 'saved:${me.phone}', sender: me.phone, text: m.text, ts: DateTime.now().millisecondsSinceEpoch, views: ['sent'])); break;
      case 'pin':
        if (m.pinned) { m.pinned = false; await Backend.update(m); pinSnackbar(context); }
        else { final ok = await pinDialog(context); if (ok == true) { m.pinned = true; await Backend.update(m); pinSnackbar(context); } }
        _refresh(); break;
      case 'edit': setState(() { editing = m; _ctrl.text = m.text; }); break;
      case 'delete': final ok = await deleteDialog(context); if (ok == true) { await Backend.remove(saved ? chatId : 'channel', m.id); _refresh(); } break;
    }
  }

  void _quoteTap(Msg m) async {
    final k = _keys[m.replyTo]; if (k?.currentContext != null) { await Scrollable.ensureVisible(k!.currentContext!, duration: const Duration(milliseconds: 300), alignment: 0.4); }
    setState(() => flashId = m.replyTo);
    await Future.delayed(const Duration(milliseconds: 900)); setState(() => flashId = null);
  }

  void _link(String type, String v) async {
    if (type == 'tel') await launchUrl(Uri(scheme: 'tel', path: v.replaceAll(RegExp(r'\s'), '')));
    else if (type == 'mail') await launchUrl(Uri(scheme: 'mailto', path: v));
    else { final url = v.startsWith('http') ? v : 'https://$v'; Navigator.push(context, MaterialPageRoute(builder: (_) => InAppBrowser(url: url))); }
  }

  void _applySendOrEdit() {
    if (editing != null) async { editing!.text = _ctrl.text; editing!.edited = true; await Backend.update(editing!); setState(() { editing = null; _ctrl.clear(); }); _refresh(); }
    else _send();
  }

  @override Widget build(BuildContext c) {
    final dark = Prefs.I.dark;
    SystemChromeStyle.apply(dark: dark, green: true); // 0.1
    final list = msgs;
    final pinnedList = list.where((m) => m.pinned).toList();
    final canPost = saved ? true : owner;
    return Scaffold(backgroundColor: dark ? C.darkBg : Colors.white, body: SafeArea(bottom: false, child: Directionality(textDirection: TextDirection.rtl, child: Column(children: [
      // هدر سبز
      Container(color: C.green, padding: const EdgeInsets.fromLTRB(10, 8, 10, 8), child: Row(children: [
        Pressable(onTap: () => Navigator.pushReplacement(c, MaterialPageRoute(builder: (_) => const MainScreen())), child: const Icon(Icons.arrow_back_ios_new, size: 17, color: Colors.white)),
        const Spacer(),
        Expanded(child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (!saved) ...[const VerifiedBadge(size: 17), const SizedBox(width: 5)],
            Flexible(child: Text(saved ? tr('saved_title') : tr('official_channel'), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white))),
          ]),
          if (!saved) (Conn.I.online
            ? FutureBuilder<int>(future: Backend.memberCount(), builder: (_, s) => Text('${fa(s.data ?? 1)} ${tr('members')}', style: const TextStyle(fontSize: 10.5, color: Colors.white70)))
            : const ConnectingText(style: TextStyle(fontSize: 10, color: Colors.white70))),
        ])),
        const SizedBox(width: 6),
        saved ? Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.18)), child: const Icon(Icons.bookmark_rounded, color: Colors.white, size: 19))
              : const ChannelAvatar(size: 40),
        const SizedBox(width: 8), const ThreeDot(color: Colors.white),
      ])),
      if (pinnedList.isNotEmpty) PinBar(m: pinnedList.last, onTap: () => _jumpTo(pinnedList.last), onClose: () async { final ok = await unpinDialog(context); if (ok == true) { for (final p in pinnedList) { p.pinned = false; await Backend.update(p); } _refresh(); } }),
      // بوم چت
      Expanded(child: Stack(children: [
        const Wallpaper(),
        ListView.builder(controller: _sc, padding: const EdgeInsets.symmetric(vertical: 8), itemCount: _streamCount(list), itemBuilder: (_, i) => _streamItem(list, i)),
      ])),
      // نوار پاسخ/ویرایش
      if (replyTo != null) ReplyStrip(name: saved ? tr('saved_title') : tr('official_channel'), snippet: replyTo!.text, onClose: () => setState(() => replyTo = null)),
      if (editing != null) ReplyStrip(name: tr('edit_msg'), snippet: editing!.text, edit: true, onClose: () => setState(() { editing = null; _ctrl.clear(); })),
      // ناحیه پایین
      if (!saved && !owner)
        Container(color: Colors.white, width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12), alignment: Alignment.center,
          child: Pressable(onTap: () async { muted = !muted; await Storage.setMute(me.phone, muted); _refresh(); }, child: Text(muted ? tr('unmute') : tr('mute'), style: const TextStyle(fontSize: 13, color: Color(0xFF33415c), fontWeight: FontWeight.w600))))
      else if (canPost)
        InputBar(ctrl: _ctrl, sending: false, onSend: _applySendOrEdit, onMic: () {}, emojiOpen: () => emoji, toggleEmoji: () => setState(() => emoji = !emoji)),
      if (emoji) SizedBox(height: 300, child: EmojiPanel(ctrl: _ctrl, showSearchBox: showSearch, toggleSearch: () => setState(() => showSearch = !showSearch))),
    ]))));
  }

  void _jumpTo(Msg m) async {
    final k = _keys[m.id]; if (k?.currentContext != null) { await Scrollable.ensureVisible(k.currentContext!, duration: const Duration(milliseconds: 300), alignment: 0.4); }
    setState(() => flashId = m.id); await Future.delayed(const Duration(milliseconds: 900)); setState(() => flashId = null);
  }

  int _streamCount(List<Msg> list) { int n = saved ? 1 : 2; String? lastDay;
    for (final m in list) { final d = sameDayKey(m.ts); if (d != lastDay) { n++; lastDay = d; } n++; } return n; }

  Widget _streamItem(List<Msg> list, int i) {
    // قرص ابتدایی + جداکننده‌های روز
    int idx = saved ? 1 : 2; String? lastDay;
    if (i == 0) return DayPill(ts: DateTime.now().millisecondsSinceEpoch);
    if (i == 1 && !saved) return DayPill(ts: DateTime.now().millisecondsSinceEpoch);
    for (final m in list) {
      final d = sameDayKey(m.ts);
      if (i == idx) { idx += 2; if (d != lastDay) { lastDay = d; _registerView(m); return DayPill(ts: m.ts); } idx--; _registerView(m); return _bubble(m); }
      if (d != lastDay) { lastDay = d; idx++; if (i == idx - 1) { _registerView(m); return DayPill(ts: m.ts); } }
      idx++;
      if (i == idx - 1) { _registerView(m); return _bubble(m); }
    }
    return const SizedBox.shrink();
  }

  void _registerView(Msg m) { if (!saved && !owner && Conn.I.online) Backend.addView(m, me.phone); }

  Widget _bubble(Msg m) {
    _keys.putIfAbsent(m.id, () => GlobalKey());
    final canMenu = m.sender == me.phone;
    return Bubble(m: m, ownerViewer: owner || saved, saved: saved, keys: _keys, flashId: flashId,
      onLongPress: canMenu ? () => _menu(m) : null, onLink: _link, onQuoteTap: _quoteTap);
  }
}
