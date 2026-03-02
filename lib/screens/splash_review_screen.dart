import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/note_provider.dart';
import '../models/note.dart';

/// 开屏复习页面
/// 显示需要复习的历史笔记，用户可点赞或跳过
class SplashReviewScreen extends StatefulWidget {
  const SplashReviewScreen({super.key});

  @override
  State<SplashReviewScreen> createState() => _SplashReviewScreenState();
}

class _SplashReviewScreenState extends State<SplashReviewScreen> {
  int _currentIndex = 0;
  List<Note> _reviewNotes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 使用 addPostFrameCallback 确保在 build 完成后访问 context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadReviewNotes();
      }
    });
  }

  Future<void> _loadReviewNotes() async {
    final noteProvider = context.read<NoteProvider>();
    final notes = noteProvider.reviewNotes.take(5).toList();
    
    if (!mounted) return;
    
    if (notes.isEmpty) {
      // 没有需要复习的笔记，直接关闭
      Navigator.pop(context);
      return;
    }
    
    setState(() {
      _reviewNotes = notes;
      _isLoading = false;
    });
  }

  Future<void> _handleLike() async {
    if (_reviewNotes.isEmpty || _currentIndex >= _reviewNotes.length) {
      _finishReview();
      return;
    }

    final note = _reviewNotes[_currentIndex];
    final noteProvider = context.read<NoteProvider>();
    await noteProvider.likeNote(note);

    setState(() {
      _currentIndex++;
    });

    if (_currentIndex >= _reviewNotes.length) {
      _finishReview();
    }
  }

  Future<void> _handleSkip() async {
    if (_reviewNotes.isEmpty || _currentIndex >= _reviewNotes.length) {
      _finishReview();
      return;
    }

    final note = _reviewNotes[_currentIndex];
    final noteProvider = context.read<NoteProvider>();
    await noteProvider.skipNote(note);

    setState(() {
      _currentIndex++;
    });

    if (_currentIndex >= _reviewNotes.length) {
      _finishReview();
    }
  }

  void _finishReview() {
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 如果没有需要复习的笔记，直接返回
    if (_reviewNotes.isEmpty || _currentIndex >= _reviewNotes.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _finishReview();
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final note = _reviewNotes[_currentIndex];
    final progress = (_currentIndex + 1) / _reviewNotes.length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 进度条
            LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),

            // 内容区域
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 提示文字
                    Text(
                      '温故而知新',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '第 ${_currentIndex + 1} / ${_reviewNotes.length} 条笔记',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // 笔记卡片
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            note.content,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.6,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 8,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '创建于 ${_formatDate(note.createdAt)}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // 操作按钮
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 跳过按钮
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _handleSkip,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.skip_next),
                                SizedBox(width: 8),
                                Text('跳过', style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 24),

                        // 点赞按钮
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _handleLike,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.favorite),
                                SizedBox(width: 8),
                                Text('记得', style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 提示
                    Text(
                      '💡 点赞会在遗忘曲线节点再次提醒',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
