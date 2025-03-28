List<String> splitText(String text, int chunkSize) {
  List<String> chunks = [];

  for (int i = 0; i < text.length; i += chunkSize) {
    int end = (i + chunkSize < text.length) ? i + chunkSize : text.length;
    chunks.add(text.substring(i, end));
  }

  return chunks;
}

String cleanText(String text) {
  int cn = 0;
  int idx = 0;

  // Loop through each character to find the first digit
  for (int i = 0; i < text.length; i++) {
    cn++;
    if (RegExp(r'[0-9]').hasMatch(text[i])) {
      idx = cn;
    }
  }

  // Extract the substring starting from the first digit and remove special characters
  String cleanedText = text
      .substring(idx)
      .replaceAll(RegExp(r'[^\w\s]'), '') // Removes special characters, keeping letters, digits, and spaces
      .trim(); // Remove leading/trailing spaces

  return cleanedText;
}

String removeLastWord(String input) {
  List<String> words = input.trim().split(' ');
  if (words.length > 1) {
    words.removeLast();
    return words.join(' ');
  }
  return ''; // Return empty if there's only one word
}
