// GENERATED CODE - MANUAL COMPANION FOR HIVE
part of 'snippet.dart';

class SnippetTypeAdapter extends TypeAdapter<SnippetType> {
  @override
  final int typeId = 0;

  @override
  SnippetType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SnippetType.text;
      case 1:
        return SnippetType.link;
      case 2:
        return SnippetType.image;
      case 3:
        return SnippetType.code;
      default:
        return SnippetType.text;
    }
  }

  @override
  void write(BinaryWriter writer, SnippetType obj) {
    switch (obj) {
      case SnippetType.text:
        writer.writeByte(0);
        break;
      case SnippetType.link:
        writer.writeByte(1);
        break;
      case SnippetType.image:
        writer.writeByte(2);
        break;
      case SnippetType.code:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SnippetTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SnippetAdapter extends TypeAdapter<Snippet> {
  @override
  final int typeId = 1;

  @override
  Snippet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Snippet(
      id: fields[0] as String?,
      title: fields[1] as String,
      content: fields[2] as String,
      type: fields[3] as SnippetType,
      createdAt: fields[4] as DateTime?,
      updatedAt: fields[5] as DateTime?,
      categoryId: fields[6] as String? ?? '',
      tags: (fields[7] as List?)?.cast<String>(),
      isFavorite: fields[8] as bool? ?? false,
      imagePath: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Snippet obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.categoryId)
      ..writeByte(7)
      ..write(obj.tags)
      ..writeByte(8)
      ..write(obj.isFavorite)
      ..writeByte(9)
      ..write(obj.imagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SnippetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
