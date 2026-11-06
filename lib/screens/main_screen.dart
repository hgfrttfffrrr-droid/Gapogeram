import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/i18n.dart';
import '../core/services.dart';
import '../core/storage.dart';
import '../core/utils.dart';
import '../widgets/common.dart';
import 'chat.dart';

class MainScreen extends StatefulWidget { const MainScreen({super.key}); @override State<MainScreen> createState() => _MainScreenState(); }

class _MainScreenState extends State<MainScreen> {
  @override void initState() { super.initState(); Conn.I.start(); }

  @override Widget build(BuildContext c) {
    final dark = Prefs.I.dark; SystemChromeStyle.apply(dark: dark);
    final me = Storage.users().lastWhere((u) => u.verified, orElse: () => Storage.users().last);
    final posts = Storage.msgs('channel');
    final last = posts.isEmpty ? null : posts.last;
    final unread = C.isOwner(me.phone) ? 0 : posts.where((p) => p.ts > Storage.lastRead(me.phone, 'channel')).length;
    return AnimatedContainer(duration: const Duration(milliseconds: 320), color: dark ? C.darkBg : Colors.white, child: Scaffold(backgroundColor: Colors.transparent,
      body: SafeArea(child: Directionality(textDirection: TextDirection.rtl, child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(14, 10, 14, 8), child: Row(children: [
          AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: Conn.I.online
            ? Text(tr('app_name'), key: const ValueKey(1), style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: dark ? Colors.white : const Color(0xFF000000)))
            : const ConnectingText(key: ValueKey(2), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF9aa4b2)))),
          const Spacer(), const ThreeDot(),
        ])),
        Container(margin: const EdgeInsets.symmetric(horizontal: 12), height: 40,
          decoration: BoxDecoration(color: dark ? C.searchDark : C.searchLight, borderRadius: BorderRadius.circular(20)),
          child: Row(children: [
            const SizedBox(width: 12), const Icon(Icons.search, size: 18, color: Color(0xFF8b9199)),
            const SizedBox(width: 8), Text(tr('search_chats'), style: const TextStyle(fontSize: 12.5, color: Color(0xFF8b9199))),
          ])),
        const SizedBox(height: 6),
        Pressable(onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => const ChatPage(chat: 'channel'))), child: Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 8), child: Row(children: [
          const ChannelAvatar(size: 52),
          const SizedBox(width: 8),
          const VerifiedBadge(size: 20),
          const SizedBox(width: 5),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr('official_channel'), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: dark ? Colors.white : const Color(0xFF000000))),
            const SizedBox(height: 3),
            ConstrainedBox(constraints: const BoxConstraints(maxWidth: 150), child: Align(alignment: Alignment.centerRight, child: Text(last?.text ?? tr('channel_created'), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Color(0xFF8b9199))))),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(last != null ? faTime(last.ts) : '', style: const TextStyle(fontSize: 10.5, color: Color(0xFF8b9199))),
            if (unread > 0) Container(margin: const EdgeInsets.only(top: 6), padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5), decoration: const BoxDecoration(color: C.green, shape: BoxShape.circle), child: Text(fa(unread), style: const TextStyle(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.w700))),
          ]),
        ]))),
      ])))));
  }
}
