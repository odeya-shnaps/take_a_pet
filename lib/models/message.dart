
import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  //final String messageId;
  final String from;
  final String fromAvatarKey;
  final String to;
  final String content;
  bool isRead;
  final Timestamp sendingTime;

  Message({/*required this.messageId,*/ required this.from, required this.to,
    required this.content, required this.isRead, required this.sendingTime, required this.fromAvatarKey});

  // compare object
  bool equals(Object other) {
    return this == other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    // comparing all fields
    return other is Message &&
        //messageId == other.messageId &&
        from == other.from &&
        to == other.to &&
        content == other.content &&
        isRead == other.isRead &&
        sendingTime == other.sendingTime &&
        fromAvatarKey == other.fromAvatarKey;
  }


  @override
  int get hashCode => toString().hashCode;

  // Message copyWith(
  //     {
  //       bool? isRead
  //     }) {
  //   return Message(
  //     // creating an object with the new info
  //       messageId: this.messageId,
  //       from: this.from,
  //       to: this.to,
  //       content: this.content,
  //       isRead: isRead ?? this.isRead,
  //       sendingTime: this.sendingTime
  //   );
  // }


  Map<String, dynamic> toJson() => {
    'from': from,
    'to': to,
    'content': content,
    'isRead': isRead,
    'sendingTime': sendingTime,
    'fromAvatarKey': fromAvatarKey
  };

  Message.fromSnapshot(DocumentSnapshot snap/*, String messageId*/)
      : //messageId = messageId,
        from = snap.get('from'),
        to = snap.get('to'),
        content = snap.get('content'),
        isRead = snap.get('isRead'),
        sendingTime = snap.get('sendingTime'),
        fromAvatarKey = snap.get('fromAvatarKey');




  Message.fromMap(Map<String, dynamic> map/*, String messageId*/)
      : //messageId = messageId,
        from = map['from'],
        to = map['to'],
        content = map['content'],
        isRead = map['isRead'],
        sendingTime = map['sendingTime'],
        fromAvatarKey = map['fromAvatarKey'];



  void setIsRead() {
    this.isRead = true;
  }


}