import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  String _privacyPolicyText = 'Loading...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPrivacyPolicy();
  }

  Future<void> _loadPrivacyPolicy() async {
    // Get system locale from context
    final locale = Localizations.localeOf(context);
    String languageCode = locale.languageCode;
    
    // Determine which file to load
    String fileName;
    switch (languageCode) {
      case 'ko':
        fileName = 'privacy_policy_ko.md';
        break;
      case 'ja':
        fileName = 'privacy_policy_ja.md';
        break;
      case 'zh':
        fileName = 'privacy_policy_zh.md';
        break;
      case 'es':
        fileName = 'privacy_policy_es.md';
        break;
      default:
        fileName = 'privacy_policy_en.md'; // Default to English
        break;
    }
    
    try {
      // Load the file
      final String content = await rootBundle.loadString('assets/privacy_policy/$fileName');
      
      setState(() {
        _privacyPolicyText = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _privacyPolicyText = 'Failed to load privacy policy: $e\n\nFile: $fileName\nLocale: $languageCode';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE6C767),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildMarkdownContent(_privacyPolicyText),
            ),
    );
  }

  Widget _buildMarkdownContent(String content) {
    final lines = content.split('\n');
    final List<Widget> widgets = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 16));
        continue;
      }
      
      if (line.startsWith('# ')) {
        // Main title
        widgets.add(
          Text(
            line.substring(2),
            style: const TextStyle(
              color: Color(0xFFE6C767),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        widgets.add(const SizedBox(height: 20));
      } else if (line.startsWith('## ')) {
        // Section title
        widgets.add(
          Text(
            line.substring(3),
            style: const TextStyle(
              color: Color(0xFFE6C767),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        widgets.add(const SizedBox(height: 12));
      } else if (line.startsWith('**') && line.endsWith('**')) {
        // Bold text
        widgets.add(
          Text(
            line.substring(2, line.length - 2),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        widgets.add(const SizedBox(height: 8));
      } else if (line.startsWith('• ')) {
        // Bullet point
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 4),
            child: Text(
              line,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        );
      } else {
        // Regular text
        widgets.add(
          Text(
            line,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14,
              height: 1.5,
            ),
          ),
        );
        widgets.add(const SizedBox(height: 8));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}