import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'jalali.dart';
import 'constants.dart';

String fa(Object v) => v.toString().replaceAllMapped(RegExp(r'\d'), (m) => C.faDigits[int.parse(m[0])!]);

String faTime(int ts) {
  final d = DateTime.fromMillisecondsSinceEpoch(ts);
  final h = d.hour.toString().padLeft(2, '0'), m = d.minute.toString().padLeft(2, '0');
  return fa('$h:$m');
}

String faCount(int n) {
  if (n < 1000) return fa(n);
  final k = n / 1000;
  final s = k >= 10 ? k.toStringAsFixed(0) : k.toStringAsFixed(1);
  return '${fa(s)}K';
}

String dayLabel(int ts) {
  final now = DateTime.now(), d = DateTime.fromMillisecondsSinceEpoch(ts);
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(d.year, d.month, d.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'امروز';
  if (diff == 1) return 'دیروز';
  final j = GregorianToJalali(d.year, d.month, d.day);
  return '${fa(j.d)} ${jalaliMonthNames[j.m - 1]} ${fa(j.y)}';
}

String sameDayKey(int ts) {
  final d = DateTime.fromMillisecondsSinceEpoch(ts);
  return '${d.year}-${d.month}-${d.day}';
}

/// تجزیه خودکار پیوند/تلفن/ایمیل به اسپن‌های قابل لمس
List<InlineSpan> linkify(String text, {required void Function(String type, String value) onTap, TextStyle? base}) {
  final re = RegExp(r'(https?://[^\s]+)|((?:[\w-]+\.)+(?:ir|com|org|net|io|me|co|info)(?:/[^\s]*)?)|([+\d][\d\s\-]{8,}\d)|([\w.\-]+@[\w.\-]+\.\w{2,})');
  final spans = <InlineSpan>[];
  int last = 0;
  for (final m in re.allMatches(text)) {
    if (m.start > last) spans.add(TextSpan(text: text.substring(last, m.start)));
    final raw = m[0]!;
    String type;
    if (m[1] != null) type = 'url';
    else if (m[2] != null) type = 'url';
    else if (m[3] != null) type = 'tel';
    else type = 'mail';
    spans.add(TextSpan(
      text: raw,
      style: (base ?? const TextStyle()).copyWith(color: const Color(0xFF1e88e5), decoration: TextDecoration.underline),
      recognizer: TapGestureRecognizer()..onTap = () => onTap(type, raw),
    ));
    last = m.end;
  }
  if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
  return spans;
}

Random rnd = Random();
String uid() => '${DateTime.now().millisecondsSinceEpoch}-${rnd.nextInt(1 << 31)}';
