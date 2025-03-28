import 'dart:convert';

import 'package:sembast/utils/value_utils.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'utils.dart';

var localDb;

// String host = "http://127.0.0.1:5000";
String host = "https://backend-pduz.onrender.com";

getFiles() async {
  var filesDb = intMapStoreFactory.store("files");
  var result = await filesDb.find(localDb);
  return getResult(result);
}

List<Map<String, dynamic>> getResult(List<RecordSnapshot> documents) {
  List<Map<String, dynamic>> result = [];

  for (var doc in documents) {
    Map<String, Object?> data = cloneMap(doc.value as Map);
    result.add(data);
  }
  return result;
}

ping() async {
  var result = await http.post(
    Uri.parse(host + "/ping"),
    headers: <String, String>{
      "Bypass-Tunnel-Reminder": "true",
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "*",
      "Access-Control-Allow-Headers": "*"
    },
    body: jsonEncode(<String, String>{"data": "hii"}),
  );
  return result.body;
}

Future<String> gen(query) async {
  final String endpoint =
      "https://tuesday-engine.openai.azure.com/openai/deployments/gpt-4o/chat/completions?api-version=2024-08-01-preview";

  final Map<String, dynamic> requestBody = {
    "messages": [
      {"role": "system", "content": "You are a helpful assistant."},
      {
        "role": "system",
        "content":
            'return the widget in the format {"name": "widget name", "child_type":"children or child", "has_positional_parameter":true or false, "parameters": [{"type": "positional or value or widget or enum","name":"parameter name", "value":"value"}],}. return only the json'
      },
      {"role": "user", "content": query}
    ],
  };
  final response = await http.post(
    Uri.parse(endpoint),
    headers: {
      "Content-Type": "application/json",
      "api-key": gptKey,
    },
    body: json.encode(requestBody),
  );

  print(json.decode(response.body));
  String result = json.decode(response.body)['choices'][0]['message']['content'];
  result = result.replaceAll("```json", "").replaceAll("```", "");
  return result;
}

Future<String> genImage(String query) async {
  String url = "";
  // query + "";
  final response = await http.post(Uri.parse("https://api.goapi.ai/api/v1/task"),
      headers: {'X-API-KEY': goKey, 'Content-Type': 'application/json'},
      body: jsonEncode({
        "model": "Qubico/flux1-schnell",
        "task_type": "txt2img",
        "input": {
          "prompt": query.replaceAll('"', ''),
          "width": 920,
          "height": 690,
        }
      }));

  String taskId = jsonDecode(response.body)["data"]["task_id"];

  print(taskId);

  while (url.trim().isEmpty) {
    final response = await http.get(
      Uri.parse("https://api.goapi.ai/api/v1/task/${taskId}"),
      headers: {'X-API-KEY': goKey, 'Content-Type': 'application/json'},
    );

    if (jsonDecode(response.body)["data"]["output"] != null) {
      url = jsonDecode(response.body)["data"]["output"]["image_url"] ?? "";
    }
    print(jsonDecode(response.body)["data"]["status"]);

    if (jsonDecode(response.body)["data"]["status"] != "pending" &&
        jsonDecode(response.body)["data"]["status"] != "processing") {
      print(response.body);
      break;
    }
    await Future.delayed(Duration(seconds: 5));
  }

  return url;
}

getImage(query) async {
  final String endpoint =
      "https://tuesday-engine.openai.azure.com/openai/deployments/dall-e-3/images/generations?api-version=2024-02-01";
  final Map<String, dynamic> requestBody = {
    "prompt": "$query realestic",
    "size": "1024x1024",
    "n": 1,
    "quality": "hd",
    "style": "vivid"
  };
  final response = await http.post(
    Uri.parse(endpoint),
    headers: {
      "Content-Type": "application/json",
      "api-key": gptKey,
    },
    body: json.encode(requestBody),
  );

  print(json.decode(response.body));

  String url = json.decode(response.body)['data'][0]['url'];
  return url;
}

getTopics(List<int> bytes) async {
  final PdfDocument document = PdfDocument(inputBytes: bytes);
//Extract the text from all the pages.
  String text = PdfTextExtractor(document).extractText();
  // print(text);
  //Dispose the document.
  document.dispose();
  // print("got text ${text}");

  List<String> texts = splitText(text, 100000);
  // print(texts);

  List<String> finalTopics = [];

  double min = double.infinity;
  double max = 0;

  // Process each chunk
  for (String text in texts) {
    for (String newLine in text.split("\n")) {
      for (String line in newLine.split(".")) {
        if (line.length > 12 && line.length < 100) {
          if (line.length < min) {
            min = line.length.toDouble();
          } else if (line.length > max) {
            max = line.length.toDouble();
          }
        }
      }
    }
  }
  double avg = (max - min) / 2;
  print(avg);

  String content = "";

  for (String text in texts) {
    for (String newLine in text.split("\n")) {
      for (String line in newLine.split(".")) {
        if (line.length > 12 && line.length < avg) {
          content += "${line} \n\n";
        }
      }
    }
  }
  print(content);

  List<String> topics = [];

  while (topics.isEmpty) {
    try {
      print("trying");
      // Call API for extracting topics
      String ans = await gen(content +
          "\n out put all the lines that sound like 'topics' or 'titles' from this. do not include subtopics. correct grammer if they are wrong. return as array of string. return only the array without any text outside.");
      print(ans);
      topics = List<String>.from(jsonDecode(ans));
    } catch (e) {
      print(e);
      topics = [];
      print("Caught exception");
    }
  }

  // // Remove duplicates
  for (String topic in topics) {
    String cleanedTopic = cleanText(topic);

    // Add to final topics list if not a duplicate
    if (!finalTopics.contains(cleanedTopic) && cleanedTopic.isNotEmpty) {
      finalTopics.add(cleanedTopic);
    }
  }

  print(finalTopics);
  return finalTopics;
}

setFile(String file) async {
  var result = await http.post(
    Uri.parse(host + "/file"),
    headers: <String, String>{
      "Bypass-Tunnel-Reminder": "true",
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "*",
      "Access-Control-Allow-Headers": "*"
    },
    body: jsonEncode(<String, String>{
      "file": file,
    }),
  );
  return result.body;
}

getRag(String query) async {
  var result = await http.post(
    Uri.parse(host + "/rag"),
    headers: <String, String>{
      "Bypass-Tunnel-Reminder": "true",
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "*",
      "Access-Control-Allow-Headers": "*"
    },
    body: jsonEncode(<String, String>{
      "query": query,
    }),
  );
  return result.body;
}

Future<Map> genSpeech(String query, String language) async {
  var result = await http.post(
    Uri.parse(host + "/speech"),
    headers: <String, String>{
      "Bypass-Tunnel-Reminder": "true",
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "*",
      "Access-Control-Allow-Headers": "*"
    },
    body: jsonEncode(<String, String>{
      "text": query,
      "language": language,
    }),
  );
  return jsonDecode(result.body);
}
