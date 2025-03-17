import 'dart:math';

const _base62Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

String generateApiKey() {
  final random = Random.secure();
  final buffer = StringBuffer('sk-');
  for (int i = 0; i < 48; i++) {
    buffer.write(_base62Chars[random.nextInt(_base62Chars.length)]);
  }
  return buffer.toString();
}

void main() {
  print(generateApiKey());
}