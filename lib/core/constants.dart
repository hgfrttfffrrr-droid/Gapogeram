import 'package:flutter/material.dart';

class C {
  // رنگ‌ها
  static const green = Color(0xFF00b894);
  static const darkBg = Color(0xFF0d0d0d);
  static const mint = Color(0xFFdbfaf5);
  static const strip = Color(0xFFfafbfd);
  static const lightNav = Color(0xFFedf2f5);
  static const searchDark = Color(0xFF242f3d);
  static const searchLight = Color(0xFFf3f4f6);
  static const slateIcon = Color(0xFF6d7c93);
  static const ownerMeta = Color(0xFF4c9c8d);
  static const memberMeta = Color(0xFF6f7a83);
  static const badgeA = Color(0xFF3fb6ff);
  static const badgeB = Color(0xFF0b74e0);

  // صاحب کانال
  static const ownerSuffix = '9939653652';
  static bool isOwner(String phone) => phone.replaceAll(RegExp(r'\D'), '').endsWith(ownerSuffix);

  // MeliPayamak OTP
  static const otpUrl = 'https://console.melipayamak.com/api/send/otp/0b25331f57d245c48369e7ed17771951';
  static const otpKey = '10254d7b-8ae8-4dc8-bd5b-86d2267fc483';

  // سرور همگام‌سازی (خالی = حالت محلی/تک‌دستگاهی)
  static const serverBase = ''; // مثال: 'https://gaprom.ir/api'

  static const faDigits = '۰۱۲۳۴۵۶۷۸۹';
}
