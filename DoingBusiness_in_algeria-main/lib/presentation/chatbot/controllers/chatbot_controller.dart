import 'dart:async';
import 'package:get/get.dart';

enum ChatRole { user, assistant }

class ChatMessage {
  final ChatRole role;
  final String text;
  final List<ChatSource> sources;
  ChatMessage({required this.role, required this.text, this.sources = const []});
}

class ChatSource {
  final String articleId;
  final String title;
  ChatSource({required this.articleId, required this.title});
}

/// Mock chatbot controller. Phase 7 will replace `_askAi` with a Cloud Function
/// call to an AI provider (Anthropic Claude) with RAG over the Articles collection.
class ChatbotController extends GetxController {
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isTyping = false.obs;

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

    final reply = await _askAi(trimmed);
    isTyping.value = false;
    messages.add(reply);
  }

  /// MOCK — replace with Cloud Function call in Phase 7.
  /// Returns a canned response with fake article sources so the UI flow
  /// can be validated end-to-end without backend work.
  Future<ChatMessage> _askAi(String prompt) async {
    await Future.delayed(const Duration(milliseconds: 1400));
    final lower = prompt.toLowerCase();

    if (lower.contains('tax') || lower.contains('deadline') || lower.contains('ibs')) {
      return ChatMessage(
        role: ChatRole.assistant,
        text:
            'For 2026, the main corporate tax deadlines in Algeria are:\n\n'
            '• 30 April 2026 — annual IBS declaration for FY 2025\n'
            '• 20th of each month — monthly VAT and withholding tax\n'
            '• 30 June 2026 — transfer pricing documentation\n\n'
            'Penalties for late filing start at 10% of the due amount.',
        sources: [
          ChatSource(articleId: 'stub-tax-2026', title: '2026 tax calendar for corporates'),
          ChatSource(articleId: 'stub-tp-algeria', title: 'Transfer pricing in Algeria: practical guide'),
        ],
      );
    }

    if (lower.contains('vat') || lower.contains('digital')) {
      return ChatMessage(
        role: ChatRole.assistant,
        text:
            'The 2026 Finance Law introduced a revised VAT threshold for digital '
            'services provided by non-residents. Companies exceeding DZD 30M in '
            'annual Algerian revenue must register for Algerian VAT through a '
            'tax representative, charge 19% VAT on in-scope services, and file '
            'quarterly returns.',
        sources: [
          ChatSource(articleId: 'stub-vat-digital', title: 'VAT on digital services: 2026 update'),
        ],
      );
    }

    if (lower.contains('subsidiary') || lower.contains('set up') || lower.contains('company')) {
      return ChatMessage(
        role: ChatRole.assistant,
        text:
            'Setting up a subsidiary in Algeria typically takes 6–10 weeks and '
            'involves: (1) reserving the company name with CNRC, (2) capital '
            'deposit in an Algerian bank, (3) notarising the articles of '
            'association, (4) CNRC registration, and (5) tax + social security '
            'enrolment. The new investment code (2026) offers accelerated '
            'procedures for strategic sectors.',
        sources: [
          ChatSource(articleId: 'stub-setup-sub', title: 'How to open a subsidiary in Algeria'),
          ChatSource(articleId: 'stub-invest-code', title: "Algeria's new investment code"),
        ],
      );
    }

    return ChatMessage(
      role: ChatRole.assistant,
      text:
          'I can help with Algeria-specific questions on tax, legal, customs, '
          'HR, and investment. Try one of the suggested prompts below or '
          'rephrase your question — Phase 7 will upgrade me to search the full '
          'Grant Thornton Algeria article library.',
    );
  }
}
