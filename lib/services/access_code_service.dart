import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Validates offline-generated access codes, without requiring any backend
/// server — appropriate for a small, single-author distribution model where
/// the app is distributed for free on Google Play (no in-app billing) and
/// the author sells the book directly (WhatsApp, transfer, Multicaixa
/// Express), handing each buyer a unique access code afterwards.
///
/// Code format: `IED-IDENTIFIER-CHECKSUM`
/// - IDENTIFIER: any alphanumeric string chosen by the author when issuing
///   the code (e.g. buyer's phone number, order number, or a sequential
///   id). It carries no secret information itself.
/// - CHECKSUM: the first 6 hex characters (uppercase) of
///   HMAC-SHA256(secret, IDENTIFIER). Only someone who knows `_secret` (the
///   author, via scripts/generate_access_code.py) can compute a checksum
///   that this validator will accept, so a user cannot fabricate a valid
///   code just by guessing a format.
class AccessCodeService {
  // Must match the secret used by scripts/generate_access_code.py.
  // Do not change without regenerating all previously issued codes.
  static const String _secret = 'IEDReader-NevesMoxi-2025-AccessCode-Secret';

  /// Normalizes user input: trims, removes internal whitespace, uppercases.
  static String normalize(String raw) {
    return raw.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
  }

  /// Returns true if [raw] is a well-formed code whose checksum matches.
  static bool isValid(String raw) {
    final code = normalize(raw);
    final parts = code.split('-');
    if (parts.length < 3) return false;
    if (parts.first != 'IED') return false;

    final checksum = parts.last;
    final identifier = parts.sublist(1, parts.length - 1).join('-');
    if (identifier.isEmpty || checksum.length != 6) return false;

    return _computeChecksum(identifier) == checksum;
  }

  static String _computeChecksum(String identifier) {
    final key = utf8.encode(_secret);
    final bytes = utf8.encode(identifier);
    final digest = Hmac(sha256, key).convert(bytes);
    return digest.toString().substring(0, 6).toUpperCase();
  }

  /// Generates a valid code for [identifier]. Kept here (in addition to the
  /// author's standalone Python script) for tests / potential future
  /// in-app "generate a code" admin tooling.
  static String generate(String identifier) {
    final normalizedId = identifier.trim().toUpperCase().replaceAll(
      RegExp(r'\s+'),
      '',
    );
    final checksum = _computeChecksum(normalizedId);
    return 'IED-$normalizedId-$checksum';
  }
}
