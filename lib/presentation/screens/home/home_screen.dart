import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:secure_note_app/core/encription/secure_storage.dart';
import 'package:secure_note_app/core/utils/app_colors.dart';
import 'package:secure_note_app/data/model/note_model.dart';
import 'package:secure_note_app/presentation/screens/home/note_detail_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Note>> _notesFuture;

  @override
  void initState() {
    super.initState();
    _notesFuture = loadNotes();
  }

  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<List<Note>> loadNotes() async {
    final connected = await hasInternetConnection();

    if (connected) {
      final snapshot = await FirebaseFirestore.instance
          .collection('notes')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Note(
          id: doc.id,
          title: SecureStorage.decrypt(data['title']),
          content: SecureStorage.decrypt(data['content']),
        );
      }).toList();
    } else {
      final rawNotes = await SecureStorage.loadLocalNotes();
      return rawNotes.map((note) {
        return Note(
          id: note['id'] ?? '',
          title: note['title'],
          content: note['content'],
        );
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("My Notes"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Note>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Failed to load notes"));
          }

          final notes = snapshot.data ?? [];

          if (notes.isEmpty) {
            return const Center(child: Text("No notes yet. Tap + to add one."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(
                    note.title,
                    style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NoteDetailScreen(note: note),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NoteDetailScreen()),
          );

          // Reload notes after new note is added
          if (result == true) {
            setState(() {
              _notesFuture = loadNotes();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
