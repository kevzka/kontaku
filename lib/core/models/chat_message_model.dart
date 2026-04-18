class ChatMessageModel {
  final String sentBy;
  final String message;
  final String messageDate;
  final String messageTime;
  final int timestamp;

  const ChatMessageModel({
    required this.sentBy,
    required this.message,
    required this.messageDate,
    required this.messageTime,
    required this.timestamp,
  });

  factory ChatMessageModel.fromRealtimeMap(Map<String, dynamic> data) {
    return ChatMessageModel(
      sentBy: data['sentBy']?.toString() ?? '',
      message: data['message']?.toString() ?? '',
      messageDate: data['messageDate']?.toString() ?? '',
      messageTime: data['messageTime']?.toString() ?? '',
      timestamp: (data['timestamp'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toRealtimeMap() {
    return {
      'sentBy': sentBy,
      'message': message,
      'messageDate': messageDate,
      'messageTime': messageTime,
      'timestamp': timestamp,
    };
  }
}
