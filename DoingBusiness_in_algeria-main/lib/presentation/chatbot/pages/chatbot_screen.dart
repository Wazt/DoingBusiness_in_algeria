import 'package:doingbusiness/core/configs/theme/app_colors.dart';
import 'package:doingbusiness/core/configs/theme/app_spacing.dart';
import 'package:doingbusiness/presentation/chatbot/controllers/chatbot_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Full-screen AI chatbot sheet. Opens from the center FAB in MainWrapper.
class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  late final ChatbotController controller;
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = Get.put(ChatbotController(), permanent: true);
    // Seed greeting on first open
    if (controller.messages.isEmpty) {
      controller.messages.add(ChatMessage(
        role: ChatRole.assistant,
        text:
            'Hello! I can help with your questions on doing business in '
            'Algeria — tax, legal, HR, customs, and more. What would you like '
            'to know?',
      ));
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send(String text) async {
    _inputController.clear();
    await controller.send(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: _buildHeader(context),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              _scrollToBottom();
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                itemCount: controller.messages.length +
                    (controller.isTyping.value ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == controller.messages.length) {
                    return const _TypingBubble();
                  }
                  return _MessageBubble(msg: controller.messages[i]);
                },
              );
            }),
          ),
          _SuggestedPrompts(onTap: _send),
          _InputBar(controller: _inputController, onSubmit: _send),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildHeader(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: AppColors.lightText,
      centerTitle: false,
      titleSpacing: AppSpacing.md,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ask a question',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.1,
                ),
          ),
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Grounded on GT Algeria insights',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.lightTextTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Close',
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.msg});
  final ChatMessage msg;

  @override
  Widget build(BuildContext context) {
    final isUser = msg.role == ChatRole.user;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isUser) const _AssistantLabel(),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.82,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md + 2,
                vertical: AppSpacing.sm + 2,
              ),
              decoration: BoxDecoration(
                color: isUser ? AppColors.brandPurple : AppColors.lightSurface,
                border: isUser
                    ? null
                    : Border.all(color: AppColors.lightBorder),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(isUser ? 14 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 14),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.text,
                    style: TextStyle(
                      fontSize: isUser ? 13.5 : 14,
                      height: 1.42,
                      color: isUser ? Colors.white : AppColors.lightText,
                    ),
                  ),
                  if (msg.sources.isNotEmpty) _SourcesBlock(sources: msg.sources),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssistantLabel extends StatelessWidget {
  const _AssistantLabel();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 4, bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.brandPurple),
          SizedBox(width: 5),
          Text(
            'GT Assistant',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.brandPurple,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _SourcesBlock extends StatelessWidget {
  const _SourcesBlock({required this.sources});
  final List<ChatSource> sources;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 1,
            color: AppColors.lightBorder,
            margin: const EdgeInsets.only(bottom: 8),
          ),
          const Text(
            'SOURCES',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.lightTextTertiary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          ...sources.map((s) => Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  '→ ${s.title}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandPurple,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();
  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AssistantLabel(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              border: Border.all(color: AppColors.lightBorder),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(14),
              ),
            ),
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final t = (_ctrl.value + i * 0.18) % 1.0;
                    final opacity = (t < 0.5) ? (0.3 + t * 1.4) : (1.7 - t * 1.4);
                    return Container(
                      width: 7,
                      height: 7,
                      margin: EdgeInsets.only(right: i == 2 ? 0 : 5),
                      decoration: BoxDecoration(
                        color: AppColors.brandPurple
                            .withOpacity(opacity.clamp(0.2, 1.0)),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestedPrompts extends StatelessWidget {
  const _SuggestedPrompts({required this.onTap});
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightBg,
        border: Border(top: BorderSide(color: AppColors.lightBorder.withOpacity(0.6))),
      ),
      child: SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: ChatbotController.suggestedPrompts.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final prompt = ChatbotController.suggestedPrompts[i];
            return ActionChip(
              label: Text(
                prompt,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              backgroundColor: AppColors.lightSurface,
              side: BorderSide(color: AppColors.lightBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              onPressed: () => onTap(prompt),
            );
          },
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller, required this.onSubmit});
  final TextEditingController controller;
  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.md, AppSpacing.md,
        ),
        color: Theme.of(context).colorScheme.surface,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: onSubmit,
                decoration: InputDecoration(
                  hintText: 'Ask about tax, legal, customs…',
                  hintStyle: TextStyle(
                    color: AppColors.lightTextTertiary,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: AppColors.lightSurfaceAlt,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: BorderSide(color: AppColors.brandPurple, width: 1.2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            _SendButton(onTap: () => onSubmit(controller.text)),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8847BB), Color(0xFF4E2780)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.brandPurple.withOpacity(0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
      ),
    );
  }
}
