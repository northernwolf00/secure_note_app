import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:secure_note_app/core/encription/secure_storage.dart';
import 'package:secure_note_app/core/utils/app_colors.dart';
import 'package:secure_note_app/data/model/note_model.dart';
import 'package:secure_note_app/presentation/screens/bookmark/bookmark_screen.dart';
import 'package:secure_note_app/presentation/screens/home/note_detail_screen.dart';
import 'package:secure_note_app/presentation/widgets/search_delegate.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  String searchQuery = '';

  Stream<List<Note>> loadNotes() {
    return FirebaseFirestore.instance
        .collection('notes')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Note(
          id: doc.id,
          title: SecureStorage.decrypt(data['title']),
          content: SecureStorage.decrypt(data['content']),
          isBookmarked: data['isBookmarked'] ?? false,
        );
      }).toList();
    });
  }

  void toggleBookmark(Note note) {
    FirebaseFirestore.instance.collection('notes').doc(note.id).update({
      'isBookmarked': !(note.isBookmarked ?? false),
    });
    
  }

  void deleteNote(String id) {
    FirebaseFirestore.instance.collection('notes').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Center(child: Text('User not logged in.'));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Notes',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search,
                color: Colors.white),
            onPressed: () async {
              final result = await showSearch(
                context: context,
                delegate: NoteSearchDelegate(loadNotes()),
              );
              if (result != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NoteDetailScreen(note: result),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark,
                color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BookmarkScreen(userId: userId, )),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Note>>(
        stream: loadNotes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading notes"));
          }

          final notes = snapshot.data ?? [];

          if (notes.isEmpty) {
            return const Center(child: Text("No notes found."));
          }

          return Padding(
            padding: const EdgeInsets.all(8),
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: notes.map((note) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NoteDetailScreen(note: note),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Expanded(
                                child: Text(
                                  note.content,
                                  maxLines: 6,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            left: 70,
                     
                            top: 70,
                            child: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'delete') {
                                  deleteNote(note.id);
                                } else if (value == 'bookmark') {
                                  toggleBookmark(note);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                                PopupMenuItem(
                                  value: 'bookmark',
                                  child: Text(note.isBookmarked == true
                                      ? 'Remove'
                                      : 'Bookmark'),
                                ),
                              ],
                              icon: const Icon(Icons.more_vert, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
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
          if (result == true) {
            setState(() {});
          }
        },
        child: const Icon(Icons.add,
          color: Colors.white,
          size: 30,),
      ),
    );
  }
}
