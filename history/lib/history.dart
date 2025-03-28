import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:just_audio/just_audio.dart';
import 'server.dart';
import 'globals.dart';

class History extends StatefulWidget {
  const History({super.key, required this.language});
  final String language;
  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  String image = "";
  int cn = 0;
  GlobalKey _key = GlobalKey();
  bool fetching = false;
  bool playing = false;
  double width = 0, height = 0;
  List<Map<String, dynamic>> narations = [];
  // VideoPlayerController? _controller;
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
        print("getting data for history");
        getData(prompt);
      }
    });
    print("listening");

    super.initState();
  }

  getData(prompt) async {
    fetching = true;
    image = "";
    narations = [];
    setState(() {});
    String result = await getRag(prompt);
    String query =
        '$result\n\nsepreate the text that has a different key idea and create an array of json using the format {"key_idea":value,"text":short explanation}. return only the json array without any text outside.';

    while (narations.isEmpty) {
      try {
        String ans = await gen(query);

        print(ans);
        narations = List<Map<String, dynamic>>.from(jsonDecode(ans));
      } catch (e) {
        print("caught");
        narations = [];
        print(e.toString());
      }
    }
    print("done");

    play();

    // get image and audios
    for (var naration in narations) {
      String query = naration["text"] +
          '\n\n create a image description that helps visualize the above text. return only the description and nothing else.';

      String ans = await gen(query);

      genImage("$ans, anime style.").then((image) {
        naration["image"] = image;
        if (naration["audio"] != null) {
          naration["ready"] = true;
        }
      });
      genSpeech(naration["text"], widget.language).then((audio) {
        naration["final_text"] = audio["text"];
        naration["audio"] = audio["audio"];
        if (naration["image"] != null) {
          naration["ready"] = true;
        }
      });
      while (naration["ready"] != true) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  play() async {
    for (var naration in narations) {
      while (naration["ready"] != true) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
      fetching = false;
      setState(() {});

      image = naration["image"];
      setState(() {});

      final _player = AudioPlayer();
      await _player.setAudioSource(AudioSource.uri(
        Uri.dataFromBytes(base64.decode(naration["audio"]), mimeType: 'audio/wav'), // Specify the MIME type
      ));

      durationStream = _player.positionStream;
      playSink.add("play");
      setState(() {});
      await _player.play();
      cn++;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (fetching) {
      return Center(key: _key, child: CircularProgressIndicator(color: Pallet.inner3));
    } else if (narations.isEmpty) {
      return Container(key: _key);
    }

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
                    if (image.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          image,
                          width: width,
                          height: height,
                          fit: BoxFit.cover,
                        ),
                      ),
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
                for (var i = 0; i < narations.length; i++)
                  if (narations[i]["final_text"] != null) Text(narations[i]["final_text"].toString())
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
                      child: Icon(playing ? Icons.pause : Icons.play_arrow),
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
