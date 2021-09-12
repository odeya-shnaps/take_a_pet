
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:take_a_pet/models/app_user.dart';
import 'package:take_a_pet/models/message.dart';

class Conversation {
  final String conversationId;
  //final List<Message> messagesList;
  final List<String> users;
  final Message lastMessage;

  // singleton - only one object is created
  const Conversation._internal(
      {
        required this.conversationId,
        //required this.messagesList,
        required this.users,
        required this.lastMessage,
      });

  factory Conversation(
      {
        //required String user1,
        //required String user2,
        //required List<Message> messagesList,
        required List<String> users,
        required Message lastMessage
      }) {
    return Conversation._internal(
        conversationId: createConversationId(users[0], users[1]),
        //messagesList: messagesList,
        users: users,
        lastMessage: lastMessage
    );
  }

  Conversation.fromSnapshot(DocumentSnapshot snap /*, CollectionReference col*/)
      : //messagesList = snap.get('messagesList'),
        users = List.castFrom(snap.get('users')),
        lastMessage = Message.fromMap(snap.get('lastMessage')),
        conversationId = snap.id;

  // void addToMessagesList (Message message) {
  //   this.messagesList.add(message);
  // }

  static String createConversationId(String user1, String user2) {
    int compare = user1.compareTo(user2);
    if(compare == -1) { // user1 < user2
      return user1+'_'+user2;
    } else {
      return user2+'_'+user1;
    }
  }

}