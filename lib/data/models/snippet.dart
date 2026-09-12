import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'snippet.g.dart';

@HiveType(typeId: 0)
enum SnippetType {
  @HiveField(0)
  text,
  @HiveField(1)
  link,
  @HiveField(2)
  image,
  @HiveField(3)
  code,
}

@HiveType(typeId: 1)
class Snippet extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String content;

  @HiveField(3)
  late SnippetType type;

  @HiveField(4)
  late DateTime createdAt;

  @HiveField(5)
  late DateTime updatedAt;

  @HiveField(6)
  late String categoryId;

  @HiveField(7)
  late List<String> tags;

  @HiveField(8)
  late bool isFavorite;

  @HiveField(9)
  String? imagePath;

  Snippet({
    String? id,
    required this.title,
    required this.content,
    this.type = SnippetType.text,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.categoryId = '',
    List<String>? tags,
    this.isFavorite = false,
    this.imagePath,
  }) {
    this.id = id ?? const Uuid().v4();
    this.createdAt = createdAt ?? DateTime.now();
    this.updatedAt = updatedAt ?? DateTime.now();
    this.tags = tags ?? [];
  }

  Snippet copyWith({
    String? title,
    String? content,
    SnippetType? type,
    String? categoryId,
    List<String>? tags,
    bool? isFavorite,
    String? imagePath,
  }) {
    return Snippet(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      categoryId: categoryId ?? this.categoryId,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  String get typeEmoji {
    switch (type) {
      case SnippetType.text:
        return '📝';
      case SnippetType.link:
        return '🔗';
      case SnippetType.image:
        return '🖼️';
      case SnippetType.code:
        return '💻';
    }
  }

  String get preview {
    if (content.length <= 100) return content;
    return '${content.substring(0, 100)}...';
  }
}
