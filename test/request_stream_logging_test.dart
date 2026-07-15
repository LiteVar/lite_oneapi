import 'dart:convert';

import 'package:lite_oneapi/src/adapters/request.dart';
import 'package:test/test.dart';

void main() {
  test('request SSE logging forwards split UTF-8 chunks unchanged', () async {
    final List<int> bytes = utf8.encode('data: {"content":"中文回答"}\n\n');
    final int contentStart = _indexOfBytes(bytes, utf8.encode('中文回答'));
    final List<List<int>> inputChunks = _splitBytes(bytes, <int>[
      contentStart + 1,
      contentStart + utf8.encode('中').length + 2,
    ]);

    final List<List<int>> outputChunks = await ApiClient.logSseStream(
      Stream<List<int>>.fromIterable(inputChunks),
    ).toList();

    expect(outputChunks, equals(inputChunks));
    for (int index = 0; index < inputChunks.length; index++) {
      expect(identical(outputChunks[index], inputChunks[index]), isTrue);
    }
    expect(outputChunks.expand((List<int> chunk) => chunk).toList(), bytes);
  });
}

int _indexOfBytes(List<int> bytes, List<int> pattern) {
  for (int index = 0; index <= bytes.length - pattern.length; index++) {
    bool matches = true;
    for (int patternIndex = 0; patternIndex < pattern.length; patternIndex++) {
      if (bytes[index + patternIndex] != pattern[patternIndex]) {
        matches = false;
        break;
      }
    }
    if (matches) {
      return index;
    }
  }
  throw StateError('Byte pattern not found.');
}

List<List<int>> _splitBytes(List<int> bytes, List<int> offsets) {
  final List<List<int>> chunks = <List<int>>[];
  int start = 0;
  for (final int offset in offsets) {
    chunks.add(bytes.sublist(start, offset));
    start = offset;
  }
  chunks.add(bytes.sublist(start));
  return chunks;
}
