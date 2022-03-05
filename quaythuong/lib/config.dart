import 'package:flutter/material.dart';

const apiKey = "AIzaSyDvKmjzsd_7abzbmj-1Js-_uxLjtwNQsFI";
const authDomain = "quaythuong-4ad56.firebaseapp.com";
const databaseURL = "https://quaythuong-4ad56.firebaseio.com";
const projectId = "quaythuong-4ad56";
const storageBucket = "quaythuong-4ad56.appspot.com";
const messagingSenderId = "196892446115";
const appId = "1:946756666870:web:9c68aa9ed01649da3e33d7";
const measurementId = "G-GK50QYNJ1J";

extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
