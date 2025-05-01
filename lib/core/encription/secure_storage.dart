import 'dart:convert';
import 'dart:io';
import 'package:encrypt/encrypt.dart';
import 'package:path_provider/path_provider.dart';

class SecureStorage {
  
   static final _key = Key.fromUtf8('my32lengthsupersecretnooneknows1');
  static final _iv = IV.fromLength(16); // or use a unique IV per note
  static final _encrypter = Encrypter(AES(_key));

  static String encrypt(String plainText) {
    return _encrypter.encrypt(plainText, iv: _iv).base64;
  }

  static String decrypt(String encryptedText) {
    return _encrypter.decrypt64(encryptedText, iv: _iv);
  }

  static Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/secure_notes.json');
  }

  static Future<void> saveNoteLocally(Map<String, dynamic> note) async {
    final file = await _getLocalFile();
    List<Map<String, dynamic>> notes = [];

    if (await file.exists()) {
      final content = await file.readAsString();
      final decrypted = decrypt(content);
      notes = List<Map<String, dynamic>>.from(json.decode(decrypted));
    }

    notes.add(note);
    final encrypted = encrypt(json.encode(notes));
    await file.writeAsString(encrypted);
  }

  static Future<List<Map<String, dynamic>>> loadLocalNotes() async {
    final file = await _getLocalFile();
    if (!await file.exists()) return [];

    final content = await file.readAsString();
    final decrypted = decrypt(content);
    return List<Map<String, dynamic>>.from(json.decode(decrypted));
  }
}
