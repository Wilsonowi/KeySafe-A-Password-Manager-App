import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

class EncryptionService {
  static final _secret = 'KeySafeAESSecretKey2024ABCDEFGH';

  static enc.Key get _key {
    final bytes = sha256.convert(utf8.encode(_secret)).bytes;
    return enc.Key(Uint8List.fromList(bytes));
  }

  // ── Encrypt ──
  static String encryptPassword(String plaintext) {
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(_key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  // ── Decrypt ──
  static String decryptPassword(String ciphertext) {
    try {
      final parts = ciphertext.split(':');
      if (parts.length != 2) return ciphertext;
      final iv = enc.IV.fromBase64(parts[0]);
      final encrypter = enc.Encrypter(enc.AES(_key, mode: enc.AESMode.cbc));
      return encrypter.decrypt64(parts[1], iv: iv);
    } catch (e) {
      return ciphertext;
    }
  }
}
