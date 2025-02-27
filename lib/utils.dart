import 'dart:math';

extension RandomString on Random {
  static const defaultAlphabet =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  String nextString(int length, [String alphabet = defaultAlphabet]) {
    return List.generate(
      length,
      (_) => alphabet[nextInt(alphabet.length)],
    ).join();
  }
}
