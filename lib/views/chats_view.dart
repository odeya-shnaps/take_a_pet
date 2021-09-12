import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:provider/provider.dart';
import 'package:take_a_pet/db/chats_repo.dart';

import 'package:take_a_pet/db/db_logic.dart';
import 'package:take_a_pet/models/app_user.dart';
import 'package:take_a_pet/models/conversation.dart';
import 'package:take_a_pet/models/message.dart';
import 'package:take_a_pet/util/const.dart';
import 'package:take_a_pet/util/widgets.dart';
import 'package:take_a_pet/views/conversation_view.dart';

class ChatsView extends StatelessWidget {

  const ChatsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String currentUser = 'id1';


    return WillPopScope(
      onWillPop: () => showExitPopup(context),
      child: AdminScaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Chats'),
            backgroundColor: Colors.lightBlue,
            actions: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_forward)
              ),
            ],
          ),
          sideBar: buildSideBar(context),
          body: StreamBuilder<List<Conversation>?>(
          stream: ChatsRepo.getConversations(currentUser),
          initialData: [],
          builder: (BuildContext context,
          AsyncSnapshot<List<Conversation>?> snapshot) {
            if (snapshot.hasError) {
              return Column(
                  children: <Widget>[
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text('Error: ${snapshot.error}'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('Stack trace: ${snapshot.stackTrace}'),
                    ),
                  ]
              );
            }
            if (snapshot.data == null) {
              return Container();
            }

            var chatsList = snapshot.data;
            return ListView.builder(
                reverse: true,
                shrinkWrap: true,
                itemCount: chatsList!.length,
                itemBuilder: (BuildContext context, int index) {
                  return ConversationTile(conversation: chatsList[index]);
                }

            );

          },

          // child: Scaffold(
          //   backgroundColor: Colors.brown[50],
          //   appBar: AppBar(
          //       title: Text('Chats'),
          //       backgroundColor: Colors.brown[400],
          //       elevation: 0.0
          //   ),
          //   body: Container(
          //       /*decoration: BoxDecoration(
          //         image: DecorationImage(
          //           image: AssetImage('images/logo.png'),
          //           fit: BoxFit.cover,
          //         ),
          //       ),*/
          //       child: ChatsList()
          //   ),
          // ),
        ),
      ),
    );
  }

}


// class ChatsList extends StatefulWidget {
//   @override
//   _ChatsListState createState() => _ChatsListState();
// }
//
// class _ChatsListState extends State<ChatsList> {
//   @override
//   Widget build(BuildContext context) {
//
//     final chats = Provider.of<List<Conversation>?>(context);// ?? [];
//     if (chats == null || chats.length == 0){
//       return Container(
//         child: Text('no conversations yet...'),
//       );
//     } else {
//       return ListView.builder(
//         itemCount: chats.length,
//         itemBuilder: (context, index) {
//           return ConversationTile(conversation: chats[index]);
//         },
//       );
//     }
//
//
//
//   }
// }


class ConversationTile extends StatefulWidget {

  final Conversation conversation;

  const ConversationTile({Key? key, required this.conversation}) : super(key: key);

  @override
  _ConversationTileState createState() => _ConversationTileState();
}

class _ConversationTileState extends State<ConversationTile> {
  final String currentUser = 'user1';


  @override
  Widget build(BuildContext context) {

    //final lastMessage = Provider.of<Message>(context) ?? "";
    Message lastMessage= widget.conversation.lastMessage;


    return GestureDetector(
      onTap:() => _toggleRead(),
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Card(
          margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
          child: ListTile(
            leading: CircleAvatar(
              radius: 25.0,
              backgroundColor: Colors.brown,
              backgroundImage:  AssetImage('images/ab.jpg')
            ),
            title: Text(widget.conversation.users.first),
            subtitle: Text(lastMessage.content),
            trailing: _envelopeIcon(lastMessage)
            ),
      )
        ),
      );

  }


  Icon _envelopeIcon (Message message) {
    if (_lastMessageIsForMe(message) && !message.isRead) {
      return Icon(Icons.mail_rounded, color: Colors.green);
    }
    return Icon(Icons.mail_outline_rounded, color: Colors.green);
  }

  bool _lastMessageIsForMe (Message message) {
    if(message.to == currentUser) {
      return true;
    }
    return false;

  }

  void _toggleRead() {
    // setState(() {
    //   if (!widget.conversation.lastMessage.isRead) {
    //     widget.conversation.lastMessage.setIsRead();
    // }});
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ConversationView(conversationId: widget.conversation.conversationId)),
    );
  }


}



