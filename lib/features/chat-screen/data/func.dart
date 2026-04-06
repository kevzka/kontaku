import 'package:firebase_database/firebase_database.dart';
import 'package:kontaku/core/utils/utils.dart';

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
      print('❌ Gagal men-generate ID pesan dari Firebase');
      return;
    }

    final DataSnapshot chatMessagesSnapshot = await databaseRef
        .child('chatMessages/$chatId')
        .get();

    if (chatMessagesSnapshot.exists) {
      print(
        '⚠️ Chat dengan ID $chatId sudah ada. Tidak akan menambahkan data dummy.',
      );
      return;
    }

    final Map<String, dynamic> updates = {};

    updates['chatMessages/$chatId/$firstMessageId'] = {
      'sentBy': meId,
      'message': Kontaku.encodeBase64Msg('Halo Budi, jadi ketemuan besok?'),
      'messageDate': '2026-04-03',
      'messageTime': '16:15',
      'timestamp': nowTimestamp - 60000,
    };

    updates['chatMessages/$chatId/$secondMessageId'] = {
      'sentBy': hisId,
      'message': Kontaku.encodeBase64Msg('Oke, nanti aku kabari ya!'),
      'messageDate': '2026-04-03',
      'messageTime': '16:19',
      'timestamp': nowTimestamp,
    };

    updates['chats/$chatId'] = {
      'members': {meId: true, hisId: true},
      'lastMessageSent': secondMessageId,
      'lastMessageText': Kontaku.encodeBase64Msg('Oke, nanti aku kabari ya!'),
      'updatedAt': nowTimestamp,
    };

    updates['userChats/$meId/$chatId'] = true;
    updates['userChats/$hisId/$chatId'] = true;

    try {
      await databaseRef.update(updates);
      print('✅ Berhasil! ChatId (Hash): $chatId');
    } catch (error) {
      print('❌ Gagal memasukkan data dummy: $error');
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

    updates['chatMessages/$chatId/$newMessageId'] = {
      'sentBy': myId,
      'message': encodedText,
      'messageDate': dateStr,
      'messageTime': timeStr,
      'timestamp': messageTimestamp,
    };

    updates['chats/$chatId/lastMessageSent'] = newMessageId;
    updates['chats/$chatId/lastMessageText'] = encodedText;
    updates['chats/$chatId/updatedAt'] = messageTimestamp;

    try {
      await databaseRef.update(updates);
      print('✅ Pesan terkirim!');
    } catch (e) {
      print('❌ Gagal mengirim pesan: $e');
    }
  }
}
