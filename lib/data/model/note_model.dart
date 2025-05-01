class Note {
  final String id;
  final String title;
  final String content;

  Note({required this.id, required this.title, required this.content});

  factory Note.fromMap(String id, Map<String, dynamic> data) {
    return Note(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
    );
  }
}
