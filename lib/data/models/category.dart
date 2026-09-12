import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'category.g.dart';

@HiveType(typeId: 2)
class CategoryModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late int colorValue;

  @HiveField(3)
  late String icon;

  @HiveField(4)
  late DateTime createdAt;

  CategoryModel({
    String? id,
    required this.name,
    required this.colorValue,
    this.icon = '📁',
    DateTime? createdAt,
  }) {
    this.id = id ?? const Uuid().v4();
    this.createdAt = createdAt ?? DateTime.now();
  }

  Color get color => Color(colorValue);

  static CategoryModel get uncategorized => CategoryModel(
        id: 'uncategorized',
        name: 'All Snippets',
        colorValue: 0xFF6C63FF,
        icon: '✨',
      );
}
