
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:take_a_pet/models/conversation.dart';
import 'package:take_a_pet/models/message.dart';

class ChatsRepo {

  static const CONVERSATIONS_COLLECTION_NAME = 'conversations';


  static Stream<List<Conversation>?>? getConversations (String userId){
    try{
      // return a stream when there is a change in the collection
      return FirebaseFirestore.instance.collection(CONVERSATIONS_COLLECTION_NAME)
          .orderBy('lastMessage.sendingTime', descending: true)
          .where('users', arrayContains: userId).snapshots()
          .map(_conversationsListFromSnapshot).handleError((dynamic e) {
        throw(e);
      });
    } catch (e) {
      print('error retrieving conversations');
      throw e;
    }
  }

  static List<Conversation>? _conversationsListFromSnapshot(QuerySnapshot? snapshot) {
    // no users in DB
    if(snapshot == null) {
      return null;
    }

    List<Conversation> listOfConversations = [];
    snapshot.docs.forEach((docum) {

      listOfConversations.add(Conversation.fromSnapshot(docum));
    });
    return listOfConversations;
  }



  static Stream<List<Message>?> getMessages (String conversationId){
    // try{
    //   // return a stream when there is a change in the collection
    //   return FirebaseFirestore.instance
    //       .collection(CONVERSATIONS_COLLECTION_NAME).doc(conversationId)
    //       .collection(conversationId).orderBy('sendingTime', descending: true)
    //       .limit(20)
    //       .snapshots()
    //       .map(_messagesListFromSnapshot).handleError((dynamic e) {
    //     throw(e);
    //   });
    //
    // } catch (e) {
    //   print('error retrieving messages');
    //   return null;
    // }

    return FirebaseFirestore.instance
        .collection(CONVERSATIONS_COLLECTION_NAME).doc(conversationId)
        .collection(conversationId).orderBy('sendingTime', descending: true)
        .limit(20)
        .snapshots()
        .map(_messagesListFromSnapshot);
  }

  static List<Message>? _messagesListFromSnapshot(QuerySnapshot? snapshot) {
    // no users in DB
    if(snapshot == null) {
      return null;
    }

    List<Message> listOfMessages = [];
    snapshot.docs.forEach((docum) {

      listOfMessages.add(Message.fromSnapshot(docum));
    });
    return listOfMessages;
  }

// static Stream<bool> getLastMessageStatus (String conversationId){
//   try{
//     return FirebaseFirestore.instance.collection(CONVERSATIONS_COLLECTION_NAME)
//         .doc(conversationId).get('lastMessage');
//
//   } catch (e) {
//     print('error retrieving messages');
//     return null;
//   }
// }

}

