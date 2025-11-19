import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kPinHashKey = 'pin_hash_v2';

String _hashPin(String pin) {
  final bytes = utf8.encode('verilock_salt::$pin');
  return sha256.convert(bytes).toString();
}

Future<String?> getStoredPinHash() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_kPinHashKey);
}

Future<void> savePin(String pin) async {
  final prefs = await SharedPreferences.getInstance();
  final hash = _hashPin(pin);
  await prefs.setString(_kPinHashKey, hash);
}

Future<bool> verifyPin(String pin) async {
  final stored = await getStoredPinHash();
  if (stored == null) return false;
  return stored == _hashPin(pin);
}

Future<bool> hasPin() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.containsKey(_kPinHashKey);
}

Future<void> resetPin() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_kPinHashKey);
}
