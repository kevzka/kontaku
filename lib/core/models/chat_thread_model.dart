class ChatThreadModel {
  final Map<String, bool> members;
  final String lastMessageSent;
  final String lastMessageText;
  final int updatedAt;

  const ChatThreadModel({
    required this.members,
    required this.lastMessageSent,
    required this.lastMessageText,
    required this.updatedAt,
  });

  Map<String, dynamic> toRealtimeMap() {
    return {
      'members': members,
      'lastMessageSent': lastMessageSent,
      'lastMessageText': lastMessageText,
      'updatedAt': updatedAt,
    };
  }
}
