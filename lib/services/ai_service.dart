import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // TODO: 替换为实际的 API Key
  static const String _apiKey = 'YOUR_API_KEY_HERE';
  static const String _baseUrl = 'https://api.openai.com/v1';

  /// 使用 AI 总结链接内容
  Future<String> summarizeUrl(String url) async {
    // TODO: 实际实现需要：
    // 1. 先抓取链接内容
    // 2. 发送给 AI 进行总结
    // 3. 返回 300 字以内的总结
    
    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content': '你是一个专业的内容总结助手。请将用户提供的链接内容总结成 300 字以内的中文笔记。要求：\n1. 提取核心观点\n2. 语言简洁清晰\n3. 便于日后复习',
          },
          {
            'role': 'user',
            'content': '请总结以下内容：$url',
          },
        ],
        'max_tokens': 500,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('AI 总结失败：${response.statusCode}');
    }
  }

  /// 总结文本内容
  Future<String> summarizeText(String text) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content': '请将以下内容总结成 300 字以内的中文笔记，提取核心观点，语言简洁清晰。',
          },
          {
            'role': 'user',
            'content': text,
          },
        ],
        'max_tokens': 500,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('AI 总结失败：${response.statusCode}');
    }
  }
}
