import 'dart:convert';

String indexToUppercaseAlphabet(int index) {
  if (index < 26) {
    return String.fromCharCode(ascii.encode('A').first + index);
  } else {
    return '$index';
  }
}

String removeNonPrintable(String string) {
  return string.replaceAll(RegExp(r'[^A-Za-z\d().,;?]'), '');
}
