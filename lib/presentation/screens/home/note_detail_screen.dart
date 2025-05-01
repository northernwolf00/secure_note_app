import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:secure_note_app/core/encription/secure_storage.dart';
import 'package:secure_note_app/core/utils/app_colors.dart';
import 'package:secure_note_app/data/model/note_model.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note? note;
  const NoteDetailScreen({Key? key, this.note}) : super(key: key);

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final notesRef = FirebaseFirestore.instance.collection('notes');

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      titleController.text = widget.note!.title;
      contentController.text = widget.note!.content;
    }
  }

  Future<void> saveNote() async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty || content.isEmpty) return;

    // Encrypt
    final encryptedTitle = SecureStorage.encrypt(title);
    final encryptedContent = SecureStorage.encrypt(content);

    final firestoreData = {
      'title': encryptedTitle,
      'content': encryptedContent,
      'timestamp': FieldValue.serverTimestamp(),
    };

    String noteId;

    if (widget.note == null) {
      // Create new note in Firestore
      final docRef = await notesRef.add(firestoreData);
      noteId = docRef.id;
    } else {
      // Update existing note
      noteId = widget.note!.id;
      await notesRef.doc(noteId).update(firestoreData);
    }

    // Save locally (already decrypted values)
    await SecureStorage.saveNoteLocally({
      'id': noteId,
      'title': title,
      'content': content,
    });

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveNote,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: contentController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Write your note...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
