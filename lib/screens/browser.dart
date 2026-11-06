import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:share_plus/share_plus.dart' if (dart.library.io) 'package:flutter/services.dart';
import '../core/constants.dart';

/// مرورگر WebView درون‌برنامه‌ای با نوار ابزار سبز (هرگز مرورگر بیرونی)
class InAppBrowser extends StatefulWidget {
  final String url; const InAppBrowser({super.key, required this.url});
  @override State<InAppBrowser> createState() => _InAppBrowserState();
}

class _InAppBrowserState extends State<InAppBrowser> {
  String title = ''; double prog = 0; InAppWebViewController? ctrl; bool canBack = false;

  @override Widget build(BuildContext c) => Scaffold(body: SafeArea(child: Directionality(textDirection: TextDirection.rtl, child: Column(children: [
    Container(color: C.green, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), child: Row(children: [
      PressableX(onTap: () async { if (canBack) await ctrl?.goBack(); else Navigator.pop(c); }, child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.white)),
      const SizedBox(width: 8),
      Expanded(child: Text(title.isEmpty ? widget.url : title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600))),
      const SizedBox(width: 6),
      PressableX(onTap: () => Clipboard.setData(ClipboardData(text: widget.url)), child: const Icon(Icons.share_outlined, size: 17, color: Colors.white)),
      const SizedBox(width: 10),
      PressableX(onTap: () {}, child: const Icon(Icons.more_vert, size: 17, color: Colors.white)),
    ])),
    if (prog < 1) LinearProgressProgress(value: prog, color: Colors.white),
    Expanded(child: InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(widget.url)),
      initialSettings: InAppWebViewSettings(javaScriptEnabled: true, useShouldOverrideUrlLoading: false),
      onWebViewCreated: (c2) => ctrl = c2,
      onTitleChanged: (c2, t) => setState(() => title = t ?? ''),
      onProgressChanged: (c2, p) => setState(() => prog = p / 100),
      onUpdateVisitedHistory: (c2, u, a) async => setState(() => canBack = await c2.canGoBack()),
    )),
  ])))));
}

class PressableX extends StatelessWidget {
  final VoidCallback onTap; final Widget child; const PressableX({required this.onTap, required this.child, super.key});
  @override Widget build(BuildContext c) => GestureDetector(onTap: onTap, child: Padding(padding: const EdgeInsets.all(4), child: child));
}
class LinearProgressProgress extends StatelessWidget {
  final double value; final Color color; const LinearProgressProgress({required this.value, required this.color, super.key});
  @override Widget build(BuildContext c) => LinearProgressIndicator(value: value, minHeight: 2, backgroundColor: Colors.transparent, valueColor: AlwaysStoppedAnimation(color));
}
