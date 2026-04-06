import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:go_router/go_router.dart';
import 'package:kontaku/features/chat-screen/data/func.dart';
import 'package:kontaku/core/utils/utils.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.hisId});

  final String hisId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  NumberModel? hisData;
  static const String myUserId = 'userAndi123';
  static String chatId = 'chat789';

  late final StreamSubscription<DatabaseEvent> _messagesSubscription;
  List<_ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    print("hisId: ${widget.hisId}");
    _listenToChatMessages();
    _handleHisData();
    FirebaseRDB.makeChatMessages(meId: myUserId, hisId: widget.hisId);
  }

  @override
  void dispose() {
    _messagesSubscription.cancel();
    _messageController.dispose();
    super.dispose();
  }

  void _listenToChatMessages() {
    final messagesQuery = FirebaseDatabase.instance
        .ref()
        .child('chatMessages/$chatId')
        .orderByChild('timestamp');

    _messagesSubscription = messagesQuery.onValue.listen(
      (DatabaseEvent event) {
        final List<_ChatMessage> loadedMessages = [];

        for (final child in event.snapshot.children) {
          final rawValue = child.value;
          if (rawValue is! Map) {
            continue;
          }

          final messageData = Map<String, dynamic>.from(rawValue);
          final String senderId = messageData['sentBy']?.toString() ?? '';
          final String text = messageData['message']?.toString() ?? '';
          final String time = messageData['messageTime']?.toString() ?? '';

          loadedMessages.add(
            _ChatMessage(
              text: Kontaku.decodeBase64Msg(text),
              isMe: senderId == myUserId,
              time: time,
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

  Future<void> _handleHisData() async {
    final data = await getHisData(widget.hisId);
    final chatMessagesId = FirebaseRDB.getChatMessagesId(
      myUserId,
      widget.hisId,
    );
    print("Chat Messages ID: $chatMessagesId");

    if (data != null) {
      setState(() {
        if (chatMessagesId != null) {
          print("Chat ID berhasil dibuat: $chatMessagesId");
          chatId = chatMessagesId;
        }
        hisData = data;
      });
    }
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
          onPressed: () => context.go("/mainNavigation"),
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
                    hisData?.name ?? 'Loading...',
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
                        print("test getChats");
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
    final colorScheme = Color(Kontaku.cream);
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

Future<NumberModel?> getHisData(String hisUID) async {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final userDetails = db.collection('userDetails');
  try {
    final snapshot = await userDetails.where("uid", isEqualTo: hisUID).get();
    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      final String profileImagePath = data['imageProfile'] as String? ?? '';
      final String name = data['username'] as String? ?? 'Unknown';
      final String phoneNumber = data['phoneNumber'] as String? ?? 'Unknown';

      print('Nama: $name');
      print('Nomor Telepon: $phoneNumber');
      print('Image Profile: $profileImagePath');
      return NumberModel(
        name: name,
        number: phoneNumber,
        profilePath: profileImagePath,
        uid: hisUID,
      );
    } else {
      print('Data pengguna tidak ditemukan untuk UID: $hisUID');
    }
  } catch (error) {
    print('❌ Gagal mengambil data pengguna: $error');
  }
  return null;
}

class NumberModel {
  final String name;
  final String number;
  final String? profilePath;
  final String? uid;
  final String? uidNumber;

  const NumberModel({
    required this.name,
    required this.number,
    this.profilePath,
    this.uid,
    this.uidNumber,
  });
}
