import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:doingbusiness/utils/error_mapper.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

enum ChatRole { user, assistant }

class ChatMessage {
  final ChatRole role;
  final String text;
  final List<ChatSource> sources;
  final bool isPreview;
  ChatMessage({
    required this.role,
    required this.text,
    this.sources = const [],
    this.isPreview = false,
  });
}

class ChatSource {
  final String articleId;
  final String title;
  ChatSource({required this.articleId, required this.title});
}

/// Talks to the `askGtAssistant` Cloud Function (europe-west1).
///
/// The Cloud Function is double-mode: live Anthropic Claude when
/// `ANTHROPIC_API_KEY` is set on the backend, otherwise a small set of
/// canned answers so the UI flow is testable without a key. Either way
/// the client-side code path is the same — this controller doesn't know
/// or care.
class ChatbotController extends GetxController {
  static const _region = 'europe-west1';
  static const _historyWindow = 10;

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isTyping = false.obs;

  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: _region);

  static const suggestedPrompts = [
    'VAT on digital services 2026',
    'Set up a subsidiary',
    'R&D credit eligibility',
    'Transfer pricing deadlines',
    'Customs reform 2026',
  ];

  Future<void> send(String prompt) async {
    final trimmed = prompt.trim();
    if (trimmed.isEmpty || isTyping.value) return;

    messages.add(ChatMessage(role: ChatRole.user, text: trimmed));
    isTyping.value = true;

    try {
      final reply = await _askAi(trimmed);
      messages.add(reply);
    } catch (e) {
      messages.add(ChatMessage(
        role: ChatRole.assistant,
        text: 'Something went wrong. ${ErrorMapper.toUserMessage(e)}',
      ));
    } finally {
      isTyping.value = false;
    }
  }

  Future<ChatMessage> _askAi(String prompt) async {
    // Build the rolling history window (exclude the user turn we just
    // added; the CF appends it itself).
    final history = messages
        .take(messages.length - 1)
        .where((m) => m.text.isNotEmpty)
        .toList()
        .reversed
        .take(_historyWindow)
        .toList()
        .reversed
        .map((m) => {
              'role': m.role == ChatRole.user ? 'user' : 'assistant',
              'text': m.text,
            })
        .toList();

    final callable = _functions.httpsCallable('askGtAssistant');
    final result = await callable.call<Map<String, dynamic>>({
      'question': prompt,
      'history': history,
    });

    final data = Map<String, dynamic>.from(result.data);
    final answer = (data['answer'] as String?) ?? '';
    final mode = (data['mode'] as String?) ?? 'preview';
    final rawSources = (data['sources'] as List?) ?? const [];
    final sources = rawSources
        .whereType<Map>()
        .map((e) => ChatSource(
              articleId: (e['articleId'] as String?) ?? '',
              title: (e['title'] as String?) ?? '',
            ))
        .where((s) => s.title.isNotEmpty)
        .toList();

    if (kDebugMode) {
      debugPrint('[chatbot] mode=$mode, sources=${sources.length}');
    }

    return ChatMessage(
      role: ChatRole.assistant,
      text: answer.isEmpty ? 'I did not receive an answer. Please try again.' : answer,
      sources: sources,
      isPreview: mode == 'preview',
    );
  }
}
