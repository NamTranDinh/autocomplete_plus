import 'package:flutter/material.dart';

class AppHelpers {
  static Size getSizeByKey(GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    final size = renderBox?.size;
    return size ?? Size.zero;
  }
}
