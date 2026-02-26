import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime updatedAt;

  @HiveField(5)
  String? sourceUrl;

  @HiveField(6)
  bool isAiGenerated;

  @HiveField(7)
  int likeCount;

  @HiveField(8)
  DateTime? lastReviewedAt;

  @HiveField(9)
  double reviewWeight;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.sourceUrl,
    this.isAiGenerated = false,
    this.likeCount = 0,
    this.lastReviewedAt,
    this.reviewWeight = 1.0,
  });

  /// 计算下次复习时间（基于遗忘曲线）
  DateTime getNextReviewDate() {
    // 简化的艾宾浩斯遗忘曲线
    final intervals = [1, 2, 4, 7, 15, 30]; // 天数
    final level = (likeCount.clamp(0, 5));
    final days = intervals[level] ?? 30;
    return DateTime.now().add(Duration(days: days));
  }

  /// 是否应该今天复习
  bool shouldReviewToday() {
    if (lastReviewedAt == null) return true;
    return DateTime.now().isAfter(getNextReviewDate());
  }

  /// 点赞，提高权重
  void like() {
    likeCount++;
    reviewWeight = 1.0 + (likeCount * 0.2);
    lastReviewedAt = DateTime.now();
  }

  /// 跳过
  void skip() {
    // 跳过不改变权重，但记录最后查看时间
    lastReviewedAt = DateTime.now();
  }

  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? sourceUrl,
    bool? isAiGenerated,
    int? likeCount,
    DateTime? lastReviewedAt,
    double? reviewWeight,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      isAiGenerated: isAiGenerated ?? this.isAiGenerated,
      likeCount: likeCount ?? this.likeCount,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      reviewWeight: reviewWeight ?? this.reviewWeight,
    );
  }
}
