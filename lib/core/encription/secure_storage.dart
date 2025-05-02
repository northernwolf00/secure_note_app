import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
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

static Future<void> updateLocalNote(Map<String, dynamic> updatedNote) async {
  final file = await _getLocalFile();
  if (!await file.exists()) return;

  final content = await file.readAsString();
  final decrypted = decrypt(content);
  List<Map<String, dynamic>> notes = List<Map<String, dynamic>>.from(json.decode(decrypted));

  final index = notes.indexWhere((n) => n['id'] == updatedNote['id']);
  if (index != -1) {
    notes[index] = updatedNote;
    final encrypted = encrypt(json.encode(notes));
    await file.writeAsString(encrypted);
  }
}
static Future<void> deleteLocalNote(String id) async {
  final file = await _getLocalFile();
  if (!await file.exists()) return;

  final content = await file.readAsString();
  final decrypted = decrypt(content);
  List<Map<String, dynamic>> notes = List<Map<String, dynamic>>.from(json.decode(decrypted));

  notes.removeWhere((note) => note['id'] == id);
  final encrypted = encrypt(json.encode(notes));
  await file.writeAsString(encrypted);
}

static Future<void> syncLocalNotesToFirebase(String userId) async {
  List<Map<String, dynamic>> localNotes = [];

  try {
    localNotes = await loadLocalNotes();
  } catch (e) {
    
    return;
  }

  final unsyncedNotes = localNotes.where((n) => n['isSynced'] == false).toList();

  for (var note in unsyncedNotes) {
    try {
      final noteData = {
        'title': note['title'],
        'content': note['content'],
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
        'isBookmarked': note['isBookmarked'] ?? false,
      };

      final docId = note['id'];

      if (docId != null && docId.toString().isNotEmpty) {
        await FirebaseFirestore.instance.collection('notes').doc(docId).set(noteData);
      } else {
        final docRef = await FirebaseFirestore.instance.collection('notes').add(noteData);
        note['id'] = docRef.id;
      }

      note['isSynced'] = true;
    } catch (e) {
     
    }
  }

  try {
    final file = await _getLocalFile();
    final encrypted = encrypt(json.encode(localNotes));
    await file.writeAsString(encrypted);
  } catch (e) {
   
  }
}



}
