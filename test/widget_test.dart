import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jide/models/note.dart';

void main() {
  // ============================================================
  // Note 模型单元测试 - 不依赖 Hive 或 Provider
  // ============================================================

  test('Note - 初始状态验证', () {
    final note = Note(
      id: 'test-1',
      title: '测试笔记',
      content: '测试内容',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    expect(note.id, equals('test-1'));
    expect(note.title, equals('测试笔记'));
    expect(note.content, equals('测试内容'));
    expect(note.likeCount, equals(0));
    expect(note.reviewWeight, equals(1.0));
    expect(note.lastReviewedAt, isNull);
  });

  test('Note - 应该复习今天（新笔记）', () {
    final note = Note(
      id: 'test-2',
      title: '新笔记',
      content: '内容',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      lastReviewedAt: null,
    );

    // 新笔记应该立即需要复习
    expect(note.shouldReviewToday(), isTrue);
  });

  test('Note - 点赞功能验证', () {
    final note = Note(
      id: 'test-3',
      title: '测试',
      content: '内容',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      likeCount: 0,
      reviewWeight: 1.0,
    );

    // 第一次点赞
    note.like();
    expect(note.likeCount, equals(1));
    expect(note.reviewWeight, equals(1.2));
    expect(note.lastReviewedAt, isNotNull);

    // 第二次点赞
    note.like();
    expect(note.likeCount, equals(2));
    expect(note.reviewWeight, equals(1.4));

    // 第三次点赞
    note.like();
    expect(note.likeCount, equals(3));
    expect(note.reviewWeight, equals(1.6));
  });

  test('Note - 跳过功能验证', () {
    final note = Note(
      id: 'test-4',
      title: '测试',
      content: '内容',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      likeCount: 0,
      reviewWeight: 1.0,
    );

    final beforeSkip = DateTime.now();
    note.skip();
    
    // 跳过会更新 lastReviewedAt 但不改变权重
    expect(note.lastReviewedAt, isNotNull);
    expect(note.lastReviewedAt!.isAfter(beforeSkip), isTrue);
    expect(note.likeCount, equals(0));
    expect(note.reviewWeight, equals(1.0));
  });

  test('Note - 遗忘曲线间隔验证', () {
    final note = Note(
      id: 'test-5',
      title: '测试',
      content: '内容',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      likeCount: 0,
    );

    // 遗忘曲线间隔：[1, 2, 4, 7, 15, 30] 天
    // likeCount 直接作为索引：0→1 天，1→2 天，2→4 天，3→7 天，4→15 天，5→30 天
    final intervals = [1, 2, 4, 7, 15, 30];

    for (int i = 0; i < intervals.length; i++) {
      note.like();
      final nextReview = note.getNextReviewDate();
      // like() 后 likeCount = i + 1，所以索引是 i + 1，但 clamp 到 5
      final expectedIndex = (i + 1).clamp(0, 5);
      final expectedDays = intervals[expectedIndex];
      final actualDays = nextReview.difference(DateTime.now()).inDays;
      
      // 允许 1 天的误差（因为时间可能跨越午夜）
      expect((actualDays - expectedDays).abs() <= 1, isTrue,
        reason: 'Like count ${i + 1}: expected ~$expectedDays days (index $expectedIndex), got $actualDays');
    }
  });

  test('Note - copyWith 方法验证', () {
    final original = Note(
      id: 'original',
      title: '原标题',
      content: '原内容',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      likeCount: 0,
    );

    final updated = original.copyWith(
      title: '新标题',
      likeCount: 5,
    );

    // 验证修改的字段
    expect(updated.title, equals('新标题'));
    expect(updated.likeCount, equals(5));
    
    // 验证未修改的字段保持不变
    expect(updated.id, equals('original'));
    expect(updated.content, equals('原内容'));
    expect(updated.createdAt, equals(DateTime(2024, 1, 1)));
  });

  test('Note - 最大点赞等级验证', () {
    final note = Note(
      id: 'test-6',
      title: '测试',
      content: '内容',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      likeCount: 0,
    );

    // 点赞超过 5 次，应该保持在最大间隔 30 天
    for (int i = 0; i < 10; i++) {
      note.like();
    }

    expect(note.likeCount, equals(10));
    
    final nextReview = note.getNextReviewDate();
    final daysUntilReview = nextReview.difference(DateTime.now()).inDays;
    
    // 最大间隔应该是 30 天左右
    expect(daysUntilReview, greaterThanOrEqualTo(29));
    expect(daysUntilReview, lessThanOrEqualTo(31));
  });

  test('Note - 权重计算验证', () {
    final note = Note(
      id: 'test-7',
      title: '测试',
      content: '内容',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      likeCount: 0,
      reviewWeight: 1.0,
    );

    // 权重公式：1.0 + (likeCount * 0.2)
    for (int i = 1; i <= 5; i++) {
      note.like();
      final expectedWeight = 1.0 + (i * 0.2);
      expect(note.reviewWeight, equals(expectedWeight),
        reason: 'After $i likes, weight should be $expectedWeight');
    }
  });
}
