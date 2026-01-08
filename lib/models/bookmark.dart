class Bookmark {
  final int id;
  final int userId;
  final int resepId;
  final String createdAt;

  Bookmark({
    required this.id,
    required this.userId,
    required this.resepId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'resep_id': resepId,
      'created_at': createdAt,
    };
  }

  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      resepId: map['resep_id'] as int,
      createdAt: map['created_at'] as String,
    );
  }
}
