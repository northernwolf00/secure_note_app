import 'dart:convert';
import 'dart:io';
import 'package:encrypt/encrypt.dart';
import 'package:path_provider/path_provider.dart';

class SecureStorage {
  static final _key = Key.fromUtf8('my32lengthsupersecretnooneknows1');
  static final _encrypter = Encrypter(AES(_key, mode: AESMode.cbc));

  static String encrypt(String plainText) {
    final iv = IV.fromSecureRandom(16); 
    final encrypted = _encrypter.encrypt(plainText, iv: iv);
    return json.encode({'i': iv.base64, 'e': encrypted.base64});
  }

  static String decrypt(String encryptedText) {
    try {
      final Map<String, dynamic> jsonData = json.decode(encryptedText);
      final iv = IV.fromBase64(jsonData['i']);
      final encrypted = Encrypted.fromBase64(jsonData['e']);
      return _encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      // Legacy fallback (not secure, temporary support)
      try {
        final fallbackEncrypted = Encrypted.fromBase64(encryptedText);
        final fallbackIV = IV.fromLength(16);
        return _encrypter.decrypt(fallbackEncrypted, iv: fallbackIV);
      } catch (e2) {
        return "[Decryption Failed]";
      }
    }
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

//   static Future<List<Map<String, dynamic>>> loadLocalNotes() async {
//     final file = await _getLocalFile();
//     if (!await file.exists()) return [];
//     final content = await file.readAsString();
//     final decrypted = decrypt(content);
//     return List<Map<String, dynamic>>.from(json.decode(decrypted));
//   }

//   /// Overwrites disk with given list (encrypting as a batch).
//   static Future<void> saveAllLocalNotes(List<Map<String, dynamic>> notes) async {
//     final file = await _getLocalFile();
//     final encrypted = encrypt(json.encode(notes));
//     await file.writeAsString(encrypted);
//   }

//   /// Adds or updates one note by `id`.
//   static Future<void> saveNoteLocally(Map<String, dynamic> note) async {
//     final notes = await loadLocalNotes();
//     // remove any existing with same id
//     notes.removeWhere((n) => n['id'] == note['id']);
//     notes.add(note);
//     await saveAllLocalNotes(notes);
//   }

//   /// Deletes one note by `id`.
//   static Future<void> deleteNoteLocally(String id) async {
//     final notes = await loadLocalNotes();
//     notes.removeWhere((n) => n['id'] == id);
//     await saveAllLocalNotes(notes);
//   }

//   /// Returns only bookmarked notes.
//   static Future<List<Map<String, dynamic>>> loadBookmarked() async {
//     final notes = await loadLocalNotes();
//     return notes.where((n) => n['isBookmarked'] == true).toList();
//   }

//   /// Searches locally by title or content.
//   static Future<List<Map<String, dynamic>>> searchLocal(String query) async {
//     final q = query.toLowerCase();
//     final notes = await loadLocalNotes();
//     return notes.where((n) {
//       final title = decrypt(n['title']).toLowerCase();
//       final content = decrypt(n['content']).toLowerCase();
//       return title.contains(q) || content.contains(q);
//     }).toList();
//   }
}
