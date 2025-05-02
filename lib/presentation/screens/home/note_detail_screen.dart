import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      titleController.text = widget.note!.title;
      contentController.text = widget.note!.content;
    }
  }

  Future<void> saveNote() async {
    if (_isSaving) return;

    final title = titleController.text.trim();
    final content = contentController.text.trim();
    if (title.isEmpty || content.isEmpty) return;

    setState(() {
      _isSaving = true;
    });

    final encryptedTitle = SecureStorage.encrypt(title);
    final encryptedContent = SecureStorage.encrypt(content);

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in.')),
      );
      return;
    }

    final firestoreData = {
      'title': encryptedTitle,
      'content': encryptedContent,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    };

    final localNote = {
      'id': widget.note?.id ?? '',
      'title': encryptedTitle,
      'content': encryptedContent,
    };

    final connectivityResult = await Connectivity().checkConnectivity();
    final isConnected = connectivityResult != ConnectivityResult.none;

    try {
      if (isConnected) {
        // Save to Firestore
        String noteId;
        if (widget.note == null) {
          final docRef = await notesRef.add(firestoreData);
          noteId = docRef.id;
          Navigator.pop(context, true);
        } else {
          noteId = widget.note!.id;
          await notesRef.doc(noteId).update(firestoreData);
          Navigator.pop(context, true);
        }

        // Save encrypted locally as well
        await SecureStorage.saveNoteLocally({
          ...localNote,
          'id': noteId,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note saved successfully!')),
        );
        Navigator.pop(context, true);
      } else {
         Navigator.pop(context, true);
        // Offline - Save only locally
        await SecureStorage.saveNoteLocally(localNote);
       
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No internet. Saved locally only.')),
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      // On failure, still save locally
      await SecureStorage.saveNoteLocally(localNote);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to save to cloud. Saved locally.')),
      );

      Navigator.pop(context, true);
    } finally {
      setState(() {
        _isSaving = false;
      });
       Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        automaticallyImplyLeading: true,
        title: SizedBox(
          height: 40,
          child: TextField(
            controller: titleController,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            decoration: const InputDecoration(
              hintText: 'Title',
              border: InputBorder.none,
              isCollapsed: true,
              hintStyle: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: contentController,
                  style: const TextStyle(fontSize: 16, height: 1.6),
                  maxLines: null,
                  expands: true,
                  decoration: const InputDecoration(
                    hintText: 'Start writing...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: () {
            _isSaving ? null : saveNote();
             Navigator.pop(context, true);
          },
          label: const Text(
            'Save Note',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
