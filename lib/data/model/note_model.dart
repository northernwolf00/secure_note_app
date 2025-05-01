class Note {
   final String id;
  final String title;
  final String content;
  final bool isBookmarked;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.isBookmarked = false,
  });

  factory Note.fromMap(String id, Map<String, dynamic> data) {
    return Note(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      isBookmarked: data['isBookmarked'] ?? false,
    );
  }
}

