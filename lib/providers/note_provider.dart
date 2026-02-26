import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/note.dart';

class NoteProvider extends ChangeNotifier {
  final Box<Note> _notesBox = Hive.box<Note>('notes');
  final _uuid = const Uuid();

  /// 获取所有笔记（按日期倒序）
  List<Note> get allNotes {
    final notes = _notesBox.values.toList();
    notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notes;
  }

  /// 获取今天的笔记
  List<Note> get todayNotes {
    final now = DateTime.now();
    return allNotes.where((note) {
      return note.createdAt.year == now.year &&
          note.createdAt.month == now.month &&
          note.createdAt.day == now.day;
    }).toList();
  }

  /// 获取需要复习的笔记
  List<Note> get reviewNotes {
    return allNotes.where((note) => note.shouldReviewToday()).toList();
  }

  /// 创建新笔记
  Future<Note> createNote({
    required String title,
    required String content,
    String? sourceUrl,
    bool isAiGenerated = false,
  }) async {
    final note = Note(
      id: _uuid.v4(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      sourceUrl: sourceUrl,
      isAiGenerated: isAiGenerated,
    );
    
    await _notesBox.put(note.id, note);
    notifyListeners();
    return note;
  }

  /// 更新笔记
  Future<void> updateNote(Note note) async {
    final updated = note.copyWith(updatedAt: DateTime.now());
    await _notesBox.put(note.id, updated);
    notifyListeners();
  }

  /// 删除笔记
  Future<void> deleteNote(String id) async {
    await _notesBox.delete(id);
    notifyListeners();
  }

  /// 点赞笔记
  Future<void> likeNote(Note note) async {
    note.like();
    await _notesBox.put(note.id, note);
    notifyListeners();
  }

  /// 跳过笔记
  Future<void> skipNote(Note note) async {
    note.skip();
    await _notesBox.put(note.id, note);
    notifyListeners();
  }

  /// 搜索笔记
  List<Note> searchNotes(String query) {
    if (query.isEmpty) return allNotes;
    final lowerQuery = query.toLowerCase();
    return allNotes.where((note) {
      return note.title.toLowerCase().contains(lowerQuery) ||
          note.content.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// 按日期获取笔记
  List<Note> getNotesByDate(DateTime date) {
    return allNotes.where((note) {
      return note.createdAt.year == date.year &&
          note.createdAt.month == date.month &&
          note.createdAt.day == date.day;
    }).toList();
  }
}
