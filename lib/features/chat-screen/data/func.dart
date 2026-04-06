import 'package:firebase_database/firebase_database.dart';
import 'dart:convert'; // Untuk Base64 encoding
import 'package:crypto/crypto.dart'; // Import untuk hashing

class FirebaseRDB {
  // Fungsi Encoding Base64 untuk Message (Bisa dibalikkan/decode)
  static String encodeMsg(String text) => base64.encode(utf8.encode(text));

  // Fungsi Hashing SHA-256 untuk Chat ID (Satu arah, tidak bisa dibalikkan)
  static String hashId(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }

  static Future<void> makeChatMessages({
    required String meId,
    required String hisId,
  }) async {
    final DatabaseReference dbRef = FirebaseDatabase.instance.ref();

    // 1. Membuat Chat ID konsisten & Ter-Hash
    final String chatId = getChatMessagesId(meId, hisId);

    final int currentTimestamp = DateTime.now().millisecondsSinceEpoch;

    final String? msg1Id = dbRef.child('chatMessages/$chatId').push().key;
    final String? msg2Id = dbRef.child('chatMessages/$chatId').push().key;

    if (msg1Id == null || msg2Id == null) {
      print('❌ Gagal men-generate ID pesan dari Firebase');
      return;
    }

    // Check if chatMessages/$chatId already exists
    final DataSnapshot chatMessagesSnapshot = await dbRef
        .child('chatMessages/$chatId')
        .get();

    if (chatMessagesSnapshot.exists) {
      print(
        '⚠️ Chat dengan ID $chatId sudah ada. Tidak akan menambahkan data dummy.',
      );
      return;
    }

    final Map<String, dynamic> updates = {};

    // 2. Isi Pesan menggunakan Base64
    updates['chatMessages/$chatId/$msg1Id'] = {
      'sentBy': meId,
      'message': encodeMsg('Halo Budi, jadi ketemuan besok?'),
      'messageDate': '2026-04-03',
      'messageTime': '16:15',
      'timestamp': currentTimestamp - 60000,
    };

    updates['chatMessages/$chatId/$msg2Id'] = {
      'sentBy': hisId,
      'message': encodeMsg('Oke, nanti aku kabari ya!'),
      'messageDate': '2026-04-03',
      'messageTime': '16:19',
      'timestamp': currentTimestamp,
    };

    updates['chats/$chatId'] = {
      'members': {meId: true, hisId: true},
      'lastMessageSent': msg2Id,
      'lastMessageText': encodeMsg('Oke, nanti aku kabari ya!'),
      'updatedAt': currentTimestamp,
    };

    updates['userChats/$meId/$chatId'] = true;
    updates['userChats/$hisId/$chatId'] = true;

    try {
      await dbRef.update(updates);
      print('✅ Berhasil! ChatId (Hash): $chatId');
    } catch (error) {
      print('❌ Gagal memasukkan data dummy: $error');
    }
  }

  static String getChatMessagesId(String myId, String hisId) {
    List<String> ids = [myId, hisId];
    ids.sort();
    return hashId(ids.join('_'));
  }
  // static Future<void> insertDummyChatData() async {
  //   final DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  //   // Fungsi Encoding Base64 untuk Message (Bisa dibalikkan/decode)
  //   String encodeMsg(String text) => base64.encode(utf8.encode(text));

  //   // Fungsi Hashing SHA-256 untuk Chat ID (Satu arah, tidak bisa dibalikkan)
  //   String hashId(String input) {
  //     return sha256.convert(utf8.encode(input)).toString();
  //   }

  //   const String meId = 'userAndi123';
  //   const String hisId = 'userBudi456';

  //   // 1. Membuat Chat ID konsisten & Ter-Hash
  //   List<String> ids = [meId, hisId];
  //   ids.sort();
  //   // Gabungan ID di-hash sehingga menjadi string unik seperti "a1b2c3d4..."
  //   final String chatId = hashId(ids.join('_'));

  //   final int currentTimestamp = DateTime.now().millisecondsSinceEpoch;

  //   final String? msg1Id = dbRef.child('chatMessages/$chatId').push().key;
  //   final String? msg2Id = dbRef.child('chatMessages/$chatId').push().key;

  //   if (msg1Id == null || msg2Id == null) {
  //     print('❌ Gagal men-generate ID pesan dari Firebase');
  //     return;
  //   }

  //   // Check if chatMessages/$chatId already exists
  //   final DataSnapshot chatMessagesSnapshot = await dbRef
  //       .child('chatMessages/$chatId')
  //       .get();

  //   if (chatMessagesSnapshot.exists) {
  //     print(
  //       '⚠️ Chat dengan ID $chatId sudah ada. Tidak akan menambahkan data dummy.',
  //     );
  //     return;
  //   }

  //   final Map<String, dynamic> updates = {};

  //   // 2. Isi Pesan menggunakan Base64
  //   updates['chatMessages/$chatId/$msg1Id'] = {
  //     'sentBy': meId,
  //     'message': encodeMsg('Halo Budi, jadi ketemuan besok?'),
  //     'messageDate': '2026-04-03',
  //     'messageTime': '16:15',
  //     'timestamp': currentTimestamp - 60000,
  //   };

  //   updates['chatMessages/$chatId/$msg2Id'] = {
  //     'sentBy': hisId,
  //     'message': encodeMsg('Oke, nanti aku kabari ya!'),
  //     'messageDate': '2026-04-03',
  //     'messageTime': '16:19',
  //     'timestamp': currentTimestamp,
  //   };

  //   updates['chats/$chatId'] = {
  //     'members': {meId: true, hisId: true},
  //     'lastMessageSent': msg2Id,
  //     'lastMessageText': encodeMsg('Oke, nanti aku kabari ya!'),
  //     'updatedAt': currentTimestamp,
  //   };

  //   updates['userChats/$meId/$chatId'] = true;
  //   updates['userChats/$hisId/$chatId'] = true;

  //   try {
  //     await dbRef.update(updates);
  //     print('✅ Berhasil! ChatId (Hash): $chatId');
  //   } catch (error) {
  //     print('❌ Gagal memasukkan data dummy: $error');
  //   }
  // }

  static Future<void> printChatHistory() async {
    final DatabaseReference dbRef = FirebaseDatabase.instance.ref();

    const String myUserId = 'userAndi123';
    const String chatId = 'chat789';

    print('⏳ Mengambil data obrolan...');

    try {
      final DataSnapshot snapshot = await dbRef
          .child('chatMessages/$chatId')
          .orderByChild('timestamp')
          .get();

      if (snapshot.exists) {
        print('\n=== RIWAYAT OBROLAN ===');

        for (final child in snapshot.children) {
          final Map<dynamic, dynamic> messageData =
              child.value as Map<dynamic, dynamic>;

          final String senderId = messageData['sentBy'];
          final String text = messageData['message'];
          final String time = messageData['messageTime'];

          if (senderId == myUserId) {
            print('Saya (Andi) : $text  [$time]');
          } else {
            print('Dia (Budi)  : $text  [$time]');
          }
        }

        print('=======================\n');
      } else {
        print('Ruang obrolan ini masih kosong.');
      }
    } catch (error) {
      print('❌ Gagal mengambil pesan: $error');
    }
  }

  static Future<void> sendMessage({
    required String myId,
    required String chatId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;

    final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
    final int timestamp = DateTime.now().millisecondsSinceEpoch;

    final String? newMessageId = dbRef.child('chatMessages/$chatId').push().key;

    if (newMessageId == null) return;

    final DateTime now = DateTime.now();
    final String dateStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final String timeStr =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    final Map<String, dynamic> updates = {};

    updates['chatMessages/$chatId/$newMessageId'] = {
      'sentBy': myId,
      'message': text,
      'messageDate': dateStr,
      'messageTime': timeStr,
      'timestamp': timestamp,
    };

    updates['chats/$chatId/lastMessageSent'] = newMessageId;
    updates['chats/$chatId/lastMessageText'] = text;
    updates['chats/$chatId/updatedAt'] = timestamp;

    try {
      await dbRef.update(updates);
      print('✅ Pesan terkirim!');
    } catch (e) {
      print('❌ Gagal mengirim pesan: $e');
    }
  }
}
