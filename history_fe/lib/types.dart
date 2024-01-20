import 'dart:async';

import 'package:flutter/material.dart';

StreamController<String> play = StreamController<String>.broadcast();
StreamSink<String> get playSink => play.sink;
Stream<String> get playStream => play.stream;

StreamController<String> request = StreamController<String>.broadcast();
StreamSink<String> get requestSink => request.sink;
Stream<String> get requestStream => request.stream;

StreamController<String> refresh = StreamController<String>.broadcast();
StreamSink<String> get refreshSink => refresh.sink;
Stream<String> get refreshStream => refresh.stream;

String selectedFile= "";
bool showTopics = true;
int sessionId = 0;
class Pallet {
  static bool light = false;

  static Color background = Color(0xFFf2f3f5);
  static Color insideFont = Colors.white;

  static Color font1 = Colors.white;
  static Color font2 = Color(0xFFb9bbc7);
  static Color font3 = Color(0xFF798092);

  static Color inner1 = Color.fromARGB(255, 67, 66, 66).withOpacity(0.2);
  // static Color inner2 = Color(0xFFe2fad7);
  static Color inner2 = Color(0xFFe9defe);
  // static Color inner3 = Color(0xFF4cbb17);
  static Color inner3 = Color(0xFF9971ee);
  static Color theme = Color(0xFF4cbb17);
  static darkMode() {
    Pallet.background = Color(0xFF161819);
    Pallet.insideFont = Colors.white;

    Pallet.font1 = Color(0xFFf9f9fb);
    Pallet.font2 = Color(0xFFececed);
    Pallet.font3 = Color(0xFF959aa8);

    Pallet.inner1 = Color(0xFF323337);
    Pallet.inner2 = Color(0xFF27292D);
    Pallet.inner3 = Color(0xFF1d1f20);
  }

  static lightMode() {
    Pallet.background = Color(0xFFf5f7fb);
    Pallet.insideFont = Colors.white;

    Pallet.font1 = Color(0xFF464646);
    Pallet.font2 = Color(0xFF5c5c5c);
    Pallet.font3 = Color(0xFFa2a2a2);

    Pallet.inner1 = Color(0xFFffffff);
    Pallet.inner2 = Color(0xFFe3e3e5);
    Pallet.inner3 = Color(0xFFf5f7fb);
  }
}


class Window{
  static bool loaded = false;
}