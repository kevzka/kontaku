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

  // Cek dulu apakah chat ini sudah pernah dibuat
  final DataSnapshot chatSnapshot = await databaseRef.child('chats/$chatId').get();
  if (chatSnapshot.exists) return;

  final Map<String, dynamic> updates = {};

  // 1. Buat metadata thread chat
  final thread = {
    'members': {
      meId: true,
      hisId: true,
    },
    'updatedAt': nowTimestamp,
    'lastMessageText': '', // Kosong dulu karena baru inisialisasi
  };

  // 2. Mapping ke masing-masing user agar muncul di daftar chat mereka
  updates['userChats/$meId/$chatId'] = true;
  updates['userChats/$hisId/$chatId'] = true;
  
  // 3. Simpan metadata di folder chats
  updates['chats/$chatId'] = thread;

  try {
    await databaseRef.update(updates);
  } catch (error) {
    print("Error creating chat: $error");
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

Future<NumberModel?> getHisData(String hisUID, String myId) async {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  try {
    // UID di level atas: userDetails/{uid}
    final snapshot = await db.collection('userDetails').doc(hisUID).get();
    
    if (snapshot.exists) {
      
      final account = AccountModel.fromFirestoreMap(
        snapshot.data() ?? <String, dynamic>{},
        fallbackUid: hisUID,
      );
      final contactSnapshot = await db
        .collection('userDetails')
        .doc(myId)
        .collection('contacts')
        .doc(account.phoneNumber).get();

      return NumberModel.fromFirestoreMap(
        contactSnapshot.data() ?? <String, dynamic>{},
        fallbackUid: hisUID,
        // account,
        // name: contactSnapshot.exists
        //     ? (contactSnapshot.data()?['name'] as String? ?? account.username)
        //     : account.username,
      );
    } else {}
  } catch (error) {}
  return null;
}