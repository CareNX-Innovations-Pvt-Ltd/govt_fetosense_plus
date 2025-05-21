import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';
import 'package:basic_utils/basic_utils.dart';

class RSAEncryptionHelper {
  final RSAPublicKey _publicKey;

  RSAEncryptionHelper._(this._publicKey);

  /// Factory method to create instance from PEM formatted public key
  factory RSAEncryptionHelper.fromKey(String base64Key) {
    final RSAPublicKey key = CryptoUtils.rsaPublicKeyFromPem(toPem(base64Key));
    return RSAEncryptionHelper._(key);
  }

  /// Encrypts a string using RSA/OAEP with SHA-1
  String encrypt(String plainText) {
    final cipher = OAEPEncoding(RSAEngine())
      ..init(
        true, // true = encrypt
        PublicKeyParameter<RSAPublicKey>(_publicKey),
      );

    final inputBytes = Uint8List.fromList(utf8.encode(plainText));
    final outputBytes = cipher.process(inputBytes);

    return base64Encode(outputBytes);
  }

  static String toPem(String base64Key) {
    return '-----BEGIN PUBLIC KEY-----\n'
        '${chunk(base64Key, 64).join('\n')}\n'
        '-----END PUBLIC KEY-----';
  }

  static List<String> chunk(String str, int size) {
    return [for (var i = 0; i < str.length; i += size) str.substring(i, i + size > str.length ? str.length : i + size)];
  }

}
