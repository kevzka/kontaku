import 'package:firebase_database/firebase_database.dart';
import 'package:kontaku/core/models/chat_message_model.dart';
import 'package:kontaku/core/models/chat_thread_model.dart';
import 'package:kontaku/core/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kontaku/core/models/number_model.dart';
import 'package:kontaku/core/models/account_model.dart';

class FirebaseRDB {
  static Future<void> makeChatMessages({
    required String meId,
    required String hisId,
  }) async {
    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

    final String chatId = getChatMessagesId(meId, hisId);

    final int nowTimestamp = DateTime.now().millisecondsSinceEpoch;

    final String? firstMessageId = databaseRef
        .child('chatMessages/$chatId')
        .push()
        .key;
    final String? secondMessageId = databaseRef
        .child('chatMessages/$chatId')
        .push()
        .key;

    if (firstMessageId == null || secondMessageId == null) {
      return;
    }

    final DataSnapshot chatMessagesSnapshot = await databaseRef
        .child('chatMessages/$chatId')
        .get();

    if (chatMessagesSnapshot.exists) {
      return;
    }

    final Map<String, dynamic> updates = {};

    final firstMessage = ChatMessageModel(
      sentBy: meId,
      message: Kontaku.encodeBase64Msg('Halo Budi, jadi ketemuan besok?'),
      messageDate: '2026-04-03',
      messageTime: '16:15',
      timestamp: nowTimestamp - 60000,
    );
    final secondMessage = ChatMessageModel(
      sentBy: hisId,
      message: Kontaku.encodeBase64Msg('Oke, nanti aku kabari ya!'),
      messageDate: '2026-04-03',
      messageTime: '16:19',
      timestamp: nowTimestamp,
    );
    final thread = ChatThreadModel(
      members: {meId: true, hisId: true},
      lastMessageSent: secondMessageId,
      lastMessageText: secondMessage.message,
      updatedAt: nowTimestamp,
    );

    updates['chatMessages/$chatId/$firstMessageId'] = firstMessage
        .toRealtimeMap();
    updates['chatMessages/$chatId/$secondMessageId'] = secondMessage
        .toRealtimeMap();
    updates['chats/$chatId'] = thread.toRealtimeMap();

    updates['userChats/$meId/$chatId'] = true;
    updates['userChats/$hisId/$chatId'] = true;

    try {
      await databaseRef.update(updates);
    } catch (error) {
      return;
    }
  }

  static String getChatMessagesId(String myId, String hisId) {
    return Kontaku.buildStablePairHashId(myId, hisId);
  }

  static Future<void> sendMessage({
    required String myId,
    required String chatId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;

    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
    final int messageTimestamp = DateTime.now().millisecondsSinceEpoch;

    final String? newMessageId = databaseRef
        .child('chatMessages/$chatId')
        .push()
        .key;

    if (newMessageId == null) return;

    final DateTime now = DateTime.now();
    final String dateStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final String timeStr =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    final String encodedText = Kontaku.encodeBase64Msg(text);

    final Map<String, dynamic> updates = {};

    final message = ChatMessageModel(
      sentBy: myId,
      message: encodedText,
      messageDate: dateStr,
      messageTime: timeStr,
      timestamp: messageTimestamp,
    );

    updates['chatMessages/$chatId/$newMessageId'] = message.toRealtimeMap();

    updates['chats/$chatId/lastMessageSent'] = newMessageId;
    updates['chats/$chatId/lastMessageText'] = encodedText;
    updates['chats/$chatId/updatedAt'] = messageTimestamp;

    try {
      await databaseRef.update(updates);
    } catch (e) {
      return;
    }
  }
}

Future<NumberModel?> getHisData(String hisUID) async {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  try {
    // UID di level atas: userDetails/{uid}
    final snapshot = await db.collection('userDetails').doc(hisUID).get();
    if (snapshot.exists) {
      final account = AccountModel.fromFirestoreMap(
        snapshot.data() ?? <String, dynamic>{},
        fallbackUid: hisUID,
      );

      return NumberModel(
        name: account.username,
        number: account.phoneNumber,
        profilePath: account.imageProfile,
        uid: account.uid,
      );
    } else {}
  } catch (error) {}
  return null;
}