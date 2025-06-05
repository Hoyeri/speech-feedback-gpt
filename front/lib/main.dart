// front/lib/main.dart
import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: WebSpeechFeedbackApp(),
  ));
}

class WebSpeechFeedbackApp extends StatefulWidget {
  const WebSpeechFeedbackApp({super.key});

  @override
  State<WebSpeechFeedbackApp> createState() => _WebSpeechFeedbackAppState();
}

class _WebSpeechFeedbackAppState extends State<WebSpeechFeedbackApp> {
  String? _transcribedText;
  String? _feedback;
  bool _isLoading = false;

  Future<void> _uploadAudioAndGetFeedback() async {
    final input = html.FileUploadInputElement()..accept = 'audio/*';
    input.click();

    await input.onChange.first;
    if (input.files == null || input.files!.isEmpty) return;

    final file = input.files!.first;
    final reader = html.FileReader();

    setState(() {
      _isLoading = true;
      _transcribedText = null;
      _feedback = null;
    });

    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;

    final uri = Uri.parse('http://localhost:5001/transcribe');

    final request = http.MultipartRequest('POST', uri);

    request.files.add(http.MultipartFile.fromBytes(
      'audio',
      reader.result as List<int>,
      filename: file.name,
      contentType: MediaType('audio', 'wav'),
    ));

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        setState(() {
          _transcribedText = data['text'];
          _feedback = data['feedback'];
        });
      } else {
        setState(() {
          _feedback = "서버 오류 발생: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _feedback = "서버에 연결할 수 없습니다.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 전체 배경 흰색
      appBar: AppBar(
        title: const Text('말하기 피드백-과제#2 DEMO'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: SingleChildScrollView( // overflow 방지
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text("오디오 파일 업로드"),
                onPressed: _uploadAudioAndGetFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 30),
              if (_isLoading) const CircularProgressIndicator(),
              if (_transcribedText != null) ...[
                _buildBox("📝 나의 발화", _transcribedText!),
              ],
              if (_feedback != null) ...[
                _buildBox("💬 GPT 피드백", _feedback!),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBox(String title, String content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Color(0xFF333333))),
          const SizedBox(height: 8),
          Text(content,
              style: const TextStyle(fontSize: 15, color: Colors.black87)),
        ],
      ),
    );
  }
}
