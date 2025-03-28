import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localstorage/localstorage.dart';
import 'globals.dart';

import 'history.dart';
import 'server.dart';
import 'package:sembast_web/sembast_web.dart';

import 'widgets.dart';

void main() async {
  var factory = databaseFactoryWeb;
  localDb = await factory.openDatabase('kolab');
  await initLocalStorage();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'His. Story',
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
  String language = "English";
  List<Map> languages = [
    {"name": "English"},
    {"name": "Mandrin"},
    {"name": "French"},
    {"name": "Hindi"},
    {"name": "Tamil"},
  ];
  TextEditingController prompt = TextEditingController();
  List files = [];
  String? expandFile;

  @override
  void initState() {
    ping();
    getData();
    requestStream.listen((event) {
      if (event == "files") {
        getData();
      }
    });
    super.initState();
  }

  getData() async {
    files = await getFiles();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Window.mainContext = context;
    Window.width = MediaQuery.of(context).size.width;
    Window.height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: scaffoldKey,
      body: Container(
        padding: const EdgeInsets.all(15),
        decoration: const BoxDecoration(color: Color(0xFF000000)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Icon(FontAwesomeIcons.compass),
                SizedBox(width: 10),
                Text(
                  "His. Story",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: 250,
                    child: ListView(
                      children: [
                        DropDown(
                          label: language,
                          items: languages,
                          itemKey: "name",
                          onPress: (value) {
                            language = value["name"];
                            setState(() {});
                          },
                          menuDecoration: BoxDecoration(color: Pallet.inner1, borderRadius: BorderRadius.circular(10)),
                        ),
                        SizedBox(height: 10),
                        AddController(
                          type: "",
                          onPress: () {},
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            decoration: BoxDecoration(color: Pallet.inner1, borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.file_upload_outlined,
                                  size: 16,
                                  color: Pallet.inner3,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Upload PDF",
                                  style: TextStyle(fontSize: 12, color: Pallet.inner3),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        for (var file in files) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: InkWell(
                              onTap: () {
                                setFile(file["data"]);
                                selectedFile = file["id"];
                                setState(() {});
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(color: Pallet.inner1, borderRadius: BorderRadius.circular(5)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        if (file["id"] == expandFile)
                                          InkWell(
                                              onTap: () {
                                                expandFile = null;
                                                setState(() {});
                                              },
                                              child: Icon(Icons.arrow_drop_down_rounded, color: Pallet.inner3))
                                        else
                                          InkWell(
                                              onTap: () {
                                                setFile(file["data"]);
                                                expandFile = file["id"];
                                                selectedFile = file["id"];
                                                setState(() {});
                                              },
                                              child: Icon(Icons.arrow_right, color: Pallet.inner3)),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                file["chapter"],
                                                style: TextStyle(fontSize: 10),
                                              ),
                                              SizedBox(height: 3),
                                              Text(
                                                file["name"],
                                                style: TextStyle(fontSize: 10),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                                color: (selectedFile == file["id"]) ? Pallet.inner3 : Colors.white),
                                          ),
                                          child: Center(
                                            child: Container(
                                              width: 5,
                                              height: 5,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                  color: (selectedFile == file["id"])
                                                      ? Pallet.inner3
                                                      : Colors.transparent),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10)
                                      ],
                                    ),
                                    if (file["id"] == expandFile) ...[
                                      SizedBox(height: 10),
                                      for (var topic in file["topics"])
                                        InkWell(
                                          onTap: () async {
                                            expandFile = null;
                                            prompt.text = "explain the topic ${topic}";
                                            setState(() {});

                                            await Future.delayed(Duration(seconds: 1));
                                            requestSink.add("explain the topic ${topic}");
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 30),
                                            child: Text(
                                              topic,
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        )
                                    ]
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                              decoration: BoxDecoration(color: Pallet.inner1, borderRadius: BorderRadius.circular(10)),
                              child: History(language: language),
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                  decoration:
                                      BoxDecoration(color: Pallet.inner1, borderRadius: BorderRadius.circular(10)),
                                  child: TextField(
                                      maxLines: 6,
                                      minLines: 1,
                                      controller: prompt,
                                      onSubmitted: (text) {
                                        requestSink.add(text);
                                      },
                                      style: TextStyle(fontSize: 12, color: Colors.white),
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
                                  setState(() {});
                                  await Future.delayed(const Duration(seconds: 1));
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
