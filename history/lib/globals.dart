import 'dart:async';

import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldKey = GlobalKey<ScaffoldMessengerState>();

StreamController<String> play = StreamController<String>.broadcast();
StreamSink<String> get playSink => play.sink;
Stream<String> get playStream => play.stream;

StreamController<String> duration = StreamController<String>.broadcast();
StreamSink<String> get durationSink => duration.sink;
late Stream<Duration> durationStream;

StreamController<String> request = StreamController<String>.broadcast();
StreamSink<String> get requestSink => request.sink;
Stream<String> get requestStream => request.stream;

StreamController<String> refresh = StreamController<String>.broadcast();
StreamSink<String> get refreshSink => refresh.sink;
Stream<String> get refreshStream => refresh.stream;

StreamController<String> route = StreamController<String>.broadcast();
StreamSink<String> get routeSink => route.sink;
Stream<String> get routeStream => route.stream;

String selectedFile = "";
bool showTopics = true;
int sessionId = 6041;

class Pallet {
  static bool light = false;

  static Color background = Color(0xFFf2f3f5);
  static Color insideFont = Colors.white;

  static Color font1 = Colors.white;
  static Color font2 = Color(0xFFb9bbc7);
  static Color font3 = Color(0xFF798092);

  static Color inner1 = Color(0xFF232227);
  static Color inner2 = Color(0xFF414044);
  static Color inner3 = Color(0xFF20b5a3);
}

class Window {
  static double width = 0;
  static double height = 0;
  static bool loaded = false;
  static double stageWidth = 0;
  static String page = "";
  static BuildContext? mainContext;
}
