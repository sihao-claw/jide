import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/note_provider.dart';

class NoteEditorScreen extends StatefulWidget {
  final ScrollController? controller;

  const NoteEditorScreen({super.key, this.controller});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _urlController = TextEditingController();
  bool _isGenerating = false;
  bool _useAI = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _generateWithAI() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先输入链接')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      // TODO: 调用 AI 服务生成总结
      await Future.delayed(const Duration(seconds: 2)); // 模拟延迟
      
      setState(() {
        _isGenerating = false;
        _useAI = true;
        _titleController.text = 'AI 总结笔记';
        _contentController.text = '这是一篇由 AI 生成的笔记总结...\n\n（实际内容将在这里显示）';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI 总结完成！你可以继续编辑')),
        );
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('生成失败：$e')),
        );
      }
    }
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('标题和内容不能为空')),
      );
      return;
    }

    final noteProvider = context.read<NoteProvider>();
    await noteProvider.createNote(
      title: title,
      content: content,
      sourceUrl: _urlController.text.trim().isEmpty ? null : _urlController.text.trim(),
      isAiGenerated: _useAI,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('笔记已保存')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 顶部拖动手柄
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 标题栏
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '新建笔记',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: _saveNote,
                  child: const Text('保存'),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 内容区域
          Expanded(
            child: ListView(
              controller: widget.controller,
              padding: const EdgeInsets.all(16),
              children: [
                // URL 输入框
                TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    labelText: '分享链接（可选）',
                    hintText: '粘贴视频或文章链接',
                    prefixIcon: const Icon(Icons.link),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                  ),
                ),

                const SizedBox(height: 16),

                // AI 生成按钮
                if (!_useAI)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isGenerating ? null : _generateWithAI,
                      icon: _isGenerating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: Text(_isGenerating ? '生成中...' : 'AI 智能总结'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // 标题输入
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: '标题',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                  ),
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 16),

                // 内容输入
                TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: '内容',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    alignLabelWithHint: true,
                  ),
                  maxLines: 10,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
