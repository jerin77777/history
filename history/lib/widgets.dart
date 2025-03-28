import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:uuid/uuid.dart';
import 'globals.dart';
import 'server.dart';

class FilePreview extends StatelessWidget {
  const FilePreview({super.key, required this.name, required this.size, required this.selected});
  final String name;
  final int size;
  final bool selected;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: (selected) ? Pallet.inner2 : Colors.transparent),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Row(
        children: [
          SizedBox(
            width: 33,
            height: 40,
            child: Stack(
              children: [
                SvgPicture.asset(
                  getFileColor(name.split(".").last.toLowerCase()),
                  width: 35,
                  height: 42,
                  fit: BoxFit.fill,
                ),
                Center(
                  child: Text(
                    name.split(".").last,
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(
                  height: 3,
                ),
                Text(
                  getSize(size),
                  style: TextStyle(fontSize: 10, color: Pallet.font1),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 8,
          ),
          Icon(
            Icons.delete,
            size: 20,
          ),
          SizedBox(
            width: 8,
          ),
        ],
      ),
    );
  }

  getSize(int size) {
    double _size = size / 1048576;
    if (_size < 1) {
      _size = _size * 1000;
      return _size.toStringAsFixed(2) + " KB";
    } else if (_size < 1000) {
      return _size.toStringAsFixed(2) + " MB";
    } else {
      _size = _size / 1000;
      return _size.toStringAsFixed(2) + " GB";
    }
  }

  getFileColor(String fileType) {
    List<String> green = ["xlsx", "xls", "csv", "py", "apk"];
    List<String> red = ["pdf", "ppt", "pptx", "odp"];
    List<String> yellow = ["html", "ipa"];
    if (green.contains(fileType)) {
      return "assets/file/green.svg";
    } else if (red.contains(fileType)) {
      return "assets/file/red.svg";
    } else if (yellow.contains(fileType)) {
      return "assets/file/yellow.svg";
    } else {
      return "assets/file/blue.svg";
    }
  }
}

class DropDown extends StatefulWidget {
  const DropDown(
      {super.key,
      required this.label,
      required this.items,
      required this.itemKey,
      required this.onPress,
      this.itemHeight = 40,
      this.menuDecoration});

  final String label;
  final List<Map> items;
  final String itemKey;
  final double itemHeight;
  final BoxDecoration? menuDecoration;
  final Function(Map) onPress;
  @override
  State<DropDown> createState() => _DropDownState();
}

class _DropDownState extends State<DropDown> {
  double height = 0, width = 0, initX = 0, initY = 0;
  GlobalKey actionKey = GlobalKey();
  OverlayEntry? dropdown;
  bool isOpen = false;
  bool selected = false;
  final ValueNotifier<int?> hoveredIdx = ValueNotifier<int?>(null);

  void findDropDownData() {
    RenderBox renderBox = actionKey.currentContext!.findRenderObject() as RenderBox;
    height = renderBox.size.height;
    width = renderBox.size.width;
    // Offset offset = renderBox.localToGlobal(Offset.zero);
    Offset offset = renderBox.localToGlobal(Offset.zero);
    initX = offset.dx;
    if (Window.width < initX + width) {
      print("went over board ${(initX + width) - Window.width}");
      initX -= ((initX + width) - Window.width);
    }
    if (Navigator.of(context).canPop()) {
      initY = offset.dy;
    } else {
      initY = offset.dy;
    }
    print(initX);
  }

  close() {
    if (isOpen) {
      dropdown!.remove();
      isOpen = false;
      setState(() {});
    }
  }

  OverlayEntry _createDropDown() {
    return OverlayEntry(builder: (context) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: GestureDetector(
          onTap: () {
            close();
          },
          child: Container(
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned(
                  left: initX,
                  width: width,
                  top: initY + height + 5,
                  height: widget.itemHeight * ((widget.items.length > 4) ? 4 : widget.items.length),
                  child: Material(
                      elevation: 0,
                      color: Colors.transparent,
                      child: ValueListenableBuilder<int?>(
                          valueListenable: hoveredIdx,
                          builder: (BuildContext context, int? _hoveredIdx, Widget? child) {
                            return Container(
                                decoration: widget.menuDecoration,
                                child: ListView(children: [
                                  for (var i = 0; i < widget.items.length; i++)
                                    MouseRegion(
                                      onEnter: (details) {
                                        hoveredIdx.value = i;
                                      },
                                      onExit: (details) {
                                        hoveredIdx.value = null;
                                      },
                                      child: InkWell(
                                        onTap: () {
                                          print("object");
                                          widget.onPress(widget.items[i]);
                                          selected = true;
                                          close();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            color: (i == _hoveredIdx) ? Pallet.inner2 : Colors.transparent,
                                          ),
                                          height: widget.itemHeight,
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(left: 8.0),
                                                child: Text(
                                                  widget.items[i][widget.itemKey],
                                                  style: TextStyle(fontSize: 12),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                ]));
                          })),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  @override
  void initState() {
    for (var item in widget.items) {
      if (item[widget.itemKey] == widget.label) {
        selected = true;
        setState(() {});
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (isOpen) {
          dropdown!.remove();
        } else {
          findDropDownData();
          dropdown = _createDropDown();
          Overlay.of(context).insert(dropdown!);
        }

        isOpen = !isOpen;
        setState(() {});
      },
      child: Container(
        key: actionKey,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(color: Pallet.inner1, borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Icon(
              Icons.language,
              size: 16,
              color: Pallet.inner3,
            ),
            SizedBox(width: 10),
            Text(
              widget.label,
              style: TextStyle(fontSize: 12, color: Pallet.inner3),
            ),
          ],
        ),
      ),
    );
  }
}


class AddController extends StatefulWidget {
  const AddController({super.key, required this.type, required this.child, required this.onPress, this.data});
  final String type;
  final Widget child;
  final Function onPress;
  final Map? data;
  // static FilePickerResult? image;
  @override
  State<AddController> createState() => _AddControllerState();
}

class _AddControllerState extends State<AddController> {
  TextEditingController name = TextEditingController();

  double height = 0, width = 0, initX = 0, initY = 0;
  GlobalKey actionKey = GlobalKey();
  OverlayEntry? dropdown;
  bool isOpen = false;
  FilePickerResult? file;
  // @override
  // void initState() {}

  close() {
    if (isOpen) {
      dropdown!.remove();
      isOpen = false;
      setState(() {});
    }
  }

  void findDropDownData() {
    RenderBox renderBox = actionKey.currentContext!.findRenderObject() as RenderBox;
    height = renderBox.size.height;
    width = renderBox.size.width;
    // Offset offset = renderBox.localToGlobal(Offset.zero);
    Offset offset = renderBox.localToGlobal(Offset.zero);
    initX = offset.dx;
    initY = offset.dy;
    print(initX);
  }

  OverlayEntry _createDropDown() {
    return OverlayEntry(builder: (context) {
      return StreamBuilder<Object>(
          stream: refreshStream,
          builder: (context, snapshot) {
            return Container(
              color: Colors.black.withOpacity(0.1),
              child: Stack(
                children: [
                  Positioned(
                    left: initX,
                    top: initY + height + 5,
                    child: Material(
                        elevation: 60,
                        color: Colors.transparent,
                        child: Container(
                          width: 220,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Pallet.inner2,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "Name",
                                style: TextStyle(fontSize: 12),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextBox(
                                controller: name,
                                onEnter: (value) {},
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              if (file == null)
                                InkWell(
                                  onTap: () async {
                                    file = await FilePicker.platform.pickFiles();
                                    // print(file?.files.first.path);
                                    refreshSink.add("");
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                    decoration:
                                        BoxDecoration(borderRadius: BorderRadius.circular(8), color: Pallet.inner1),
                                    child: Center(
                                        child: Text(
                                      "upload file",
                                      style: TextStyle(fontSize: 12),
                                    )),
                                  ),
                                )
                              else
                                FilePreview(
                                  name: file!.files.first.name,
                                  size: file!.files.first.size,
                                  selected: false,
                                ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SmallButton(
                                    label: "close",
                                    onPress: () {
                                      close();
                                    },
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  SmallButton(
                                    label: "done",
                                    onPress: () async {
                                      print("got files");
                                      if (file != null) {
                                        close();
                                        List topics = await getTopics(file!.files.first.bytes!);
                                        var filesDb = intMapStoreFactory.store("files");
                                        await filesDb.add(localDb, {
                                          "id": Uuid().v4(),
                                          "chapter": name.text,
                                          "name": file!.files.first.name,
                                          "size": file!.files.first.size,
                                          "data": base64Encode(file!.files.first.bytes!),
                                          "topics": topics,
                                        });

                                        requestSink.add("files");

                                        // server.uploadFile(
                                        //     chapter: name.text,
                                        //     fileName: file!.files.first.name,
                                        //     fileSize: file!.files.first.size,
                                        //     fileStream: file!.files.first.readStream!,
                                        //     func: (data) {
                                        //       print(data);
                                        //       // getData();
                                        //     });
                                        //       file = null;
                                        //       name.clear();
                                      }
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        )),
                  ),
                ],
              ),
            );
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          widget.onPress();
          if (isOpen) {
            dropdown!.remove();
          } else {
            findDropDownData();
            dropdown = _createDropDown();
            Overlay.of(context).insert(dropdown!);
          }

          isOpen = !isOpen;
          setState(() {});
        },
        child: Container(
          key: actionKey,
          child: widget.child,
        ));
  }
}

class TextBox extends StatefulWidget {
  const TextBox({
    super.key,
    this.controller,
    this.maxLines,
    this.onType,
    this.onEnter,
    this.hintText,
    this.focus,
    this.radius,
    this.errorText,
    this.type,
    this.isPassword = false,
  });
  final TextEditingController? controller;
  final int? maxLines;
  final Function(String)? onType;
  final Function(String)? onEnter;
  final String? hintText;
  final FocusNode? focus;
  final double? radius;
  final bool isPassword;
  final String? errorText;
  final String? type;
  @override
  State<TextBox> createState() => _TextBoxState();
}

class _TextBoxState extends State<TextBox> {
  bool hasError = false;
  @override
  void initState() {
    if (widget.errorText != null) {
      hasError = true;
      setState(() {});
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Pallet.inner1,
            borderRadius: BorderRadius.circular(widget.radius ?? 5),
            border: Border.all(color: (hasError) ? Colors.red : Colors.transparent),
          ),
          child: TextField(
              obscureText: widget.isPassword,
              focusNode: widget.focus,
              onSubmitted: widget.onEnter,
              onChanged: (value) {
                hasError = false;
                if (widget.type == "time" &&
                    !RegExp(r'^([0-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value) &&
                    value.isNotEmpty) {
                  hasError = true;
                }
                if (widget.type == "double" && !RegExp(r'^\d*\.?\d*$').hasMatch(value) && value.isNotEmpty) {
                  hasError = true;
                }
                if (widget.type == "int" && !RegExp(r'^[0-9]+$').hasMatch(value) && value.isNotEmpty) {
                  hasError = true;
                }
                setState(() {});

                if (widget.onType != null) {
                  widget.onType!(value);
                }
              },
              controller: widget.controller,
              style: const TextStyle(fontSize: 12, color: Colors.white),
              maxLines: widget.maxLines ?? 1,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(fontSize: 12, color: Pallet.font3),
                isDense: true,
                border: InputBorder.none,
              )),
        ),
        if (widget.errorText != null)
          Text(
            widget.errorText!,
            style: TextStyle(fontSize: 10, color: Colors.red),
          )
      ],
    );
  }
}

class SmallButton extends StatelessWidget {
  const SmallButton({super.key, required this.label, required this.onPress});
  final String label;
  final Function onPress;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.all(0),
        minimumSize: Size(30, 30),
      ),
      onPressed: () {
        onPress();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Pallet.inner1,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(color: Pallet.font3, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
