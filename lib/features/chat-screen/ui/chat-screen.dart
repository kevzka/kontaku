import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kontaku/core/models/chat_message_model.dart';
import 'package:kontaku/core/models/number_model.dart';
import 'package:kontaku/core/utils/utils.dart';
import '../data/func.dart';
import '../../authentication/logic/bloc/authentication.dart';
import '../../authentication/logic/event-state/authentication-event-state.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.hisId});

  final String hisId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  NumberModel? peerData;
  late final String myUserId;
  late final String chatId;

  StreamSubscription<DatabaseEvent>? _messagesSubscription;
  List<_ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthenticationBloc>().state;
    myUserId = authState is Authenticated ? authState.user.uid : 'unknownUser';
    chatId = FirebaseRDB.getChatMessagesId(myUserId, widget.hisId);
    _loadPeerData();
    _listenToChatMessages();
    FirebaseRDB.makeChatMessages(meId: myUserId, hisId: widget.hisId);
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  void _listenToChatMessages() {
    final messagesQuery = FirebaseDatabase.instance
        .ref()
        .child('chatMessages/$chatId')
        .orderByChild('timestamp');

    _messagesSubscription?.cancel();
    _messagesSubscription = messagesQuery.onValue.listen(
      (DatabaseEvent event) {
        final List<_ChatMessage> loadedMessages = [];

        for (final child in event.snapshot.children) {
          final rawValue = child.value;
          if (rawValue is! Map) {
            continue;
          }

          final messageModel = ChatMessageModel.fromRealtimeMap(
            Map<String, dynamic>.from(rawValue),
          );

          loadedMessages.add(
            _ChatMessage(
              text: Kontaku.decodeBase64Msg(messageModel.message),
              isMe: messageModel.sentBy == myUserId,
              time: messageModel.messageTime,
            ),
          );
        }

        if (!mounted) {
          return;
        }

        setState(() {
          _messages = loadedMessages;
        });
      },
      onError: (Object error) {
        debugPrint('Gagal mendengar pesan chat: $error');
      },
    );
  }

  Future<void> _loadPeerData() async {
    final data = await getHisData(widget.hisId, myUserId);

    if (!mounted || data == null) {
      return;
    }

    setState(() {
      peerData = data;
    });
  }

  Future<void> _handleSendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      return;
    }

    await FirebaseRDB.sendMessage(myId: myUserId, chatId: chatId, text: text);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Color(Kontaku.sand),
      appBar: AppBar(
        backgroundColor: Color(Kontaku.cream),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go("/mainNavigation/0"),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                'A',
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    peerData?.name ?? 'Loading...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Online now',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.call_outlined)),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.16),
                    colorScheme.secondary.withValues(alpha: 0.10),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This is a sample conversation with dummy messages.',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                itemCount: _messages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _MessageBubble(message: message);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Color(Kontaku.cream),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // FirebaseRDB.insertDummyChatData();
                        // FirebaseRDB.printChatHistory();
                      },
                      child: Icon(Icons.photo_camera_outlined),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.add_circle_outline_rounded),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _handleSendMessage(),
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    FilledButton(
                      onPressed: _handleSendMessage,
                      style: FilledButton.styleFrom(
                        backgroundColor: Color(Kontaku.accent),
                        foregroundColor: Color(Kontaku.dark),
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(14),
                      ),
                      child: const Icon(Icons.send_rounded, size: 18),
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
}

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
  });

  final String text;
  final bool isMe;
  final String time;
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final alignment = message.isMe
        ? Alignment.centerRight
        : Alignment.centerLeft;
    final bubbleColor = message.isMe
        ? Color(Kontaku.accent)
        : Color(Kontaku.cream);
    final textColor = message.isMe ? Colors.white : const Color(0xFF111827);

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(message.isMe ? 18 : 4),
              bottomRight: Radius.circular(message.isMe ? 4 : 18),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.text,
                style: TextStyle(color: textColor, fontSize: 14, height: 1.35),
              ),
              const SizedBox(height: 6),
              Text(
                message.time,
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.72),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


