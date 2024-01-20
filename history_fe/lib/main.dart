// import 'package:ai_classroom_fe/teacher.dart';
import 'dart:convert';
import 'package:video_player/video_player.dart';

import 'server.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'data.dart';
import 'types.dart';
import 'package:just_audio/just_audio.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:math';
import 'package:lottie/lottie.dart';
import 'package:flutter/foundation.dart';
import 'dart:html';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(TextTheme(
          displayLarge: TextStyle(color: Pallet.font1),
          displayMedium: TextStyle(color: Pallet.font1),
          bodyMedium: TextStyle(color: Pallet.font1),
          titleMedium: TextStyle(color: Pallet.font1),
        )),
        iconTheme: IconThemeData(color: Pallet.font1),
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late ValueNotifier<double> valueNotifier;
  TextEditingController prompt = TextEditingController();
  List files = [];
  @override
  void initState() {
    valueNotifier = ValueNotifier(0.0);
    valueNotifier.value = 61;
    if (kIsWeb) {
      window.addEventListener('focus', onFocus);
      window.addEventListener('blur', onBlur);
    }
    getData();
    super.initState();
  }

  onFocus(Event e) {
    Window.loaded = true;
  }

  onBlur(Event e) {
    Window.loaded = false;
  }

  getData() async {
    final LocalStorage storage = new LocalStorage('history');
    await storage.ready;
    if (storage.getItem("sessionId") == null) {
      Random random = new Random();
      storage.setItem("sessionId", random.nextInt(100000));
    }
    sessionId = storage.getItem("sessionId");
    print("the set session id is ${sessionId}");

    files = jsonDecode(await server.httpPost(path: "get_files", query: {"sessionId": sessionId.toString()}));
    setState(() {});
  }

  @override
  void dispose() {
    valueNotifier.dispose();
    if (kIsWeb) {
      window.removeEventListener('focus', onFocus);
      window.removeEventListener('blur', onBlur);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: [0.1, 0.5, 0.7, 0.9],
            colors: [Color(0xFFfbd3ee), Color(0xFFdab9fc), Color(0xFFb7e9ff), Color(0xFFa5cdff)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            RichText(
              text: const TextSpan(
                  text: 'HI',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                  children: [
                    TextSpan(
                      text: 'S',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple,
                        letterSpacing: 2.0,
                      ),
                    ),
                    TextSpan(
                      text: 'TORY',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ]),
            ),
            // const Text(
            //   "HISTORY",
            // ),
            const SizedBox(height: 10),
            Expanded(
              child: Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 250,
                        height: 200,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Pallet.inner1),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(
                            "welcome",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "Jerin George Jacob",
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Wrap(
                                  runSpacing: 5,
                                  spacing: 5,
                                  children: [
                                    Container(
                                      width: 45,
                                      height: 45,
                                      padding: EdgeInsets.all(5),
                                      decoration:
                                          BoxDecoration(borderRadius: BorderRadius.circular(10), color: Pallet.inner3),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "time",
                                            style: TextStyle(fontSize: 8),
                                          ),
                                          Expanded(
                                              child: Center(
                                                  child: Text(
                                            "8 hrs",
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                          )))
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 45,
                                      height: 45,
                                      decoration:
                                          BoxDecoration(borderRadius: BorderRadius.circular(10), color: Pallet.inner3),
                                      child: Center(child: Icon(Icons.notifications)),
                                    ),
                                    Container(
                                      width: 45,
                                      height: 45,
                                      decoration:
                                          BoxDecoration(borderRadius: BorderRadius.circular(10), color: Pallet.inner3),
                                      child: Center(child: Icon(Icons.calendar_today)),
                                    ),
                                    Container(
                                      width: 45,
                                      height: 45,
                                      decoration:
                                          BoxDecoration(borderRadius: BorderRadius.circular(10), color: Pallet.inner3),
                                      child: Center(child: Icon(Icons.pending_actions)),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 20),
                              SizedBox(
                                width: 100,
                                height: 100,
                                child: SimpleCircularProgressBar(
                                  progressColors: [Pallet.inner3],
                                  backColor: Pallet.inner1,
                                  maxValue: 100,
                                  valueNotifier: valueNotifier,
                                  onGetText: (double value) {
                                    return Text(
                                      'performance\n${value.toInt()}%',
                                      style: TextStyle(fontSize: 10),
                                      textAlign: TextAlign.center,
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: 10)
                            ],
                          ),
                        ]),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: 250,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Pallet.inner1),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "files",
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(height: 10),
                                  InkWell(
                                    onTap: () async {
                                      FilePickerResult? file =
                                          await FilePicker.platform.pickFiles(withReadStream: true);
                                      print("got files");
                                      server.uploadFile(
                                          fileName: file!.files.first.name,
                                          fileSize: file!.files.first.size,
                                          fileStream: file!.files.first.readStream!,
                                          func: (data) {
                                            print(data);
                                            getData();
                                          });
                                      print(file!.files.first.name);
                                      print(file!.files.first.size);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                      decoration:
                                          BoxDecoration(borderRadius: BorderRadius.circular(8), color: Pallet.inner1),
                                      child: Center(
                                          child: Text(
                                        "upload files",
                                        style: TextStyle(fontSize: 12),
                                      )),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                ],
                              ),
                            ),
                            for (var file in files)
                              InkWell(
                                onTap: () {
                                  selectedFile = file["url"];
                                  print(file["url"]);
                                  setState(() {});
                                },
                                child: FilePreview(
                                  name: file["fileName"],
                                  size: int.parse(file["fileSize"]),
                                  selected: selectedFile == file["url"],
                                ),
                              )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          Expanded(
                              child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                  decoration:
                                      BoxDecoration(color: Pallet.inner1, borderRadius: BorderRadius.circular(10)),
                                  child: History())),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                  decoration:
                                      BoxDecoration(color: Pallet.inner1, borderRadius: BorderRadius.circular(10)),
                                  child: TextField(
                                      controller: prompt,
                                      onSubmitted: (text) {
                                        requestSink.add(text);
                                      },
                                      style: TextStyle(fontSize: 12, color: Colors.black),
                                      decoration: InputDecoration(
                                        hintStyle: TextStyle(fontSize: 12, color: Pallet.font1),
                                        isDense: true,
                                        border: InputBorder.none,
                                      )),
                                ),
                              ),
                              SizedBox(width: 10),
                              InkWell(
                                onTap: () async {
                                  requestSink.add(prompt.text);
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Pallet.inner3,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    Icons.done,
                                    color: Pallet.insideFont,
                                    size: 18,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class History extends StatefulWidget {
  const History({super.key});
  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  String image = "";
  int cn = 0;
  GlobalKey _key = GlobalKey();
  bool _playing = false;
  bool _loading = false;
  double width = 0, height = 0;
  List result = [];
  VideoPlayerController? _controller;
  bool _showVideo = false;
  double perc = 0;
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      RenderBox renderBox = _key.currentContext!.findRenderObject() as RenderBox;
      width = renderBox.size.width;
      height = renderBox.size.height;
      print("w $width h $height");
      print("ratio: " + (renderBox.size.width / renderBox.size.height).toString());
      setState(() {});
    });

    requestStream.listen((prompt) {
      if (selectedFile.isNotEmpty) {
        getData(prompt);
      }
    });
    server.socket.on("progress", (data) {
      print(data);
      perc = data;
      setState(() {});
    });
    super.initState();
  }

  getData(prompt) async {
    _loading = true;
    perc = 0;
    setState(() {});
    print(server.socket.id.toString());
    result = jsonDecode((await server.httpPost(
        path: "prompt", query: {"socket_id": server.socket.id.toString(), "query": prompt, "file": selectedFile})));

    image = result[0]["image"];
    print("img " + server.getAsssetUrl(image));

    _loading = false;
    setState(() {});
  }

  play() async {
    if (!_playing) {
      _playing = true;

      for (var word in result) {
        _showVideo = false;
        _controller = null;
        image = word["image"];
        setState(() {});

        _controller = VideoPlayerController.networkUrl(Uri.parse(server.getAsssetUrl(word["video"])))
          ..initialize().then((_) {
            _showVideo = true;
            setState(() {});
            _controller!.setLooping(true);
            _controller!.play();
          });
        final _player = AudioPlayer();
        await _player.setUrl(server.getAsssetUrl(word["file"]));
        print("playing " + word["key_idea"]);
        print(word["video"]);
        print("img " + server.getAsssetUrl(image));

        playSink.add("play");
        await _player.play();
        print("completed");
        playSink.add("stop");
        _controller!.pause();
        // await Future.delayed(Duration(milliseconds: 2000));
        if (cn < result.length - 2) {
          cn += 1;
        }
        print(word["image"]);

        if (_playing == false) {
          _player.pause();
          _controller!.pause();
          playSink.add("stop");
          break;
        }
        setState(() {});
      }
    } else {
      _playing = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Stack(key: _key, children: [
        Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 250, child: Lottie.asset('assets/loading.json')),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LinearPercentIndicator(
                  width: 200,
                  lineHeight: 20,
                  percent: perc / 100,
                  center: Text(
                    "loading $perc.0%",
                    style: const TextStyle(fontSize: 12.0),
                  ),
                  // trailing: const Icon(Icons.mood),
                  linearStrokeCap: LinearStrokeCap.roundAll,
                  backgroundColor: Pallet.inner1,
                  progressColor: Pallet.inner3,
                ),
              ],
            ),
          ],
        ))
      ]);
    }
    if (result.isEmpty) {
      return Container(
        key: _key,
      );
    }
    print(result.length);
    return Row(
      children: [
        Expanded(
          key: _key,
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    if (_showVideo)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: width,
                          height: height,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                                width: height * _controller!.value.aspectRatio,
                                height: height,
                                //
                                child: VideoPlayer(
                                  _controller!,
                                )),
                          ),
                        ),
                      )
                    else
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          server.getAsssetUrl(image),
                          width: width,
                          height: height,
                          fit: BoxFit.cover,
                        ),
                      ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        height: 500,
                        width: 500,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            // color: Colors.red,
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [
                                Colors.black.withOpacity(0.0),
                                Colors.black.withOpacity(0.0),
                                Colors.black.withOpacity(0.7),
                              ],
                            )),
                      ),
                    ),
                    Positioned(
                        bottom: -130,
                        child: Teacher(
                          visemes: result[cn]["word_visemes"],
                        ))
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10),
        Container(
          width: 320,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Pallet.inner1,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "notes:",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 10),
              Expanded(
                  child: ListView(children: [
                for (var i = 0; i < result.length; i++)
                  AnimatedText(text: result[i]["text"], wordTimings: result[i]["word_timings"], playing: i == cn)
              ])),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      play();
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Pallet.inner3),
                      child: Icon(_playing ? Icons.pause : Icons.play_arrow),
                    ),
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
