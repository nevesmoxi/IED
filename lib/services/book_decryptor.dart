import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;
import 'package:encrypt/encrypt.dart' as enc;

/// Decrypts the book's protected content (assets/data/book.enc) at runtime.
///
/// Content-protection rationale: shipping the raw book.json inside the APK's
/// assets would let anyone unzip the APK/AAB and read the full copyrighted
/// text of the book directly. Instead, the book is stored as AES-256-CBC
/// ciphertext (IV prefix + ciphertext) and only decrypted in memory while the
/// app runs, which prevents casual/trivial extraction of the content.
///
/// NOTE: This raises the bar significantly against casual copying (unzip
/// APK -> read assets) but, as with any on-device secret, a sufficiently
/// determined attacker with the compiled app could still recover the key
/// through reverse engineering. Combined with FLAG_SECURE (screenshot/
/// screen-recording blocking) this provides layered, reasonable protection
/// appropriate for a reading app of this kind.
class BookDecryptor {
  // Must match the passphrase used by the build-time encryption script
  // (scripts/encrypt_book.py). Do not change without re-encrypting the asset.
  static const String _passphrase =
      'IEDReader-NevesMoxi-2025-AngolaLaw-Secure';

  static String decryptToJsonString(Uint8List fileBytes) {
    if (fileBytes.length < 16) {
      throw const FormatException('Ficheiro de conteúdo inválido ou corrompido.');
    }
    final ivBytes = fileBytes.sublist(0, 16);
    final cipherBytes = fileBytes.sublist(16);

    final keyBytes = crypto.sha256.convert(utf8.encode(_passphrase)).bytes;
    final key = enc.Key(Uint8List.fromList(keyBytes));
    final iv = enc.IV(Uint8List.fromList(ivBytes));

    final encrypter = enc.Encrypter(
      enc.AES(key, mode: enc.AESMode.cbc, padding: 'PKCS7'),
    );

    final decrypted = encrypter.decryptBytes(
      enc.Encrypted(Uint8List.fromList(cipherBytes)),
      iv: iv,
    );

    return utf8.decode(decrypted);
  }
}
