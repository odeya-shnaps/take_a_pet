import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:take_a_pet/db/chats_repo.dart';
import 'package:take_a_pet/db/db_logic.dart';
import 'package:take_a_pet/models/app_user.dart';
import 'package:take_a_pet/models/conversation.dart';
import 'package:take_a_pet/models/message.dart';

class ConversationView extends StatefulWidget {
  final String conversationId;
  //final String currentUser;

  const ConversationView({Key? key, required this.conversationId}) : super(key: key);

  @override
  _ConversationViewState createState() => _ConversationViewState();
}

class _ConversationViewState extends State<ConversationView> {
  late String conversationId;

  @override
  void initState() {
    super.initState();
    //uid = widget.uid;
    conversationId = widget.conversationId;
    //contact = widget.contact;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              buildMessages(conversationId, 'user1'),
              buildInput(),
            ],
          ),
        ],
      ),
    );
  }



//@override
// Widget build(BuildContext context) {
//
//   /// NEED TO ADD ERROR HANDLING
//   return StreamProvider<List<Message>?>.value(
//     value: Streams.getMessages(widget.conversationId),
//     initialData: [],
//     child: Scaffold(
//       backgroundColor: Colors.brown[50],
//       appBar: AppBar(
//           title: Text(widget.conversationId),
//           backgroundColor: Colors.brown[400],
//           elevation: 0.0
//       ),
//       body: Container(
//           color: Colors.blue[200],
//           child: MessagesList()
//       ),
//     ),
//   );
//
// }
}

@override
Widget buildMessages(String conversationId, String currentUser) => StreamBuilder<List<Message>?> (
  stream: ChatsRepo.getMessages(conversationId),
  builder: (context, snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
        return Center(child: CircularProgressIndicator());
      default:
        if (snapshot.hasError) {
          return buildText('Something Went Wrong Try later');
        } else {
          final messages = snapshot.data;

          return (messages == null || messages.length == 0)
              ? buildText('Say Hi..')
              : ListView.builder(
            physics: BouncingScrollPhysics(),
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];

              return MessageWidget(
                message: message,
                isMe: message.from == currentUser,
              );
            },
          );
        }
    }
  },
);

Widget buildText(String text) => Center(
  child: Text(
    text,
    style: TextStyle(fontSize: 24),
  ),
);


class MessageWidget extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageWidget({
    required this.message,
    required this.isMe,
  });



  @override
  Widget build(BuildContext context) {
    //final DBLogic _logic = DBLogic();

    final radius = Radius.circular(12);
    final borderRadius = BorderRadius.all(radius);


    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        if (!isMe)
          CircleAvatar(
              radius: 16, backgroundImage: NetworkImage(message.fromAvatarKey)),
        Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.all(16),
          constraints: BoxConstraints(maxWidth: 140),
          decoration: BoxDecoration(
            color: isMe ? Colors.grey[100] : Theme.of(context).accentColor,
            borderRadius: isMe
                ? borderRadius.subtract(BorderRadius.only(bottomRight: radius))
                : borderRadius.subtract(BorderRadius.only(bottomLeft: radius)),
          ),
          child: buildMessage(),
        ),
      ],
    );
  }

  Widget buildMessage() => Column(
    crossAxisAlignment:
    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        message.content,
        style: TextStyle(color: isMe ? Colors.black : Colors.white),
        textAlign: isMe ? TextAlign.end : TextAlign.start,
      ),
    ],
  );
}

// Widget buildMessages(Conversation conversationId) {
//
//   final messages = Provider.of<List<Message>?>(context);// ?? [];
//   if (messages == null || messages.length == 0){
//     return Container(
//       child: Text('no messages yet...'),
//     );
//   } else {
//     return Flexible(
//       child: ListView.builder(
//         padding: const EdgeInsets.all(10.0),
//         itemCount: messages.length,
//         reverse: true,
//         itemBuilder: (context, index) {
//           return MessageTile(message: messages[index]);
//         },
//         //controller: listScrollController,
//       ),
//     );
//   }
//
//
// }


Widget buildInput() {
  return Container(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: <Widget>[
            // Edit text
            Flexible(
              child: Container(
                child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextField(
                      autofocus: true,
                      maxLines: 5,
                      //controller: textEditingController,
                      decoration: const InputDecoration.collapsed(
                        hintText: 'Type your message...',
                      ),
                    )),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send, size: 25),
                onPressed: () => {},

                // onPressed: () => onSendMessage(textEditingController.text),
              ),
            ),
          ],
        ),
      ),
      width: double.infinity,
      height: 100.0);
}




// class MessagesList extends StatefulWidget {
//   @override
//   _MessagesListState createState() => _MessagesListState();
// }
//
// class _MessagesListState extends State<MessagesList> {
//   @override
//   Widget build(BuildContext context) {
//
//     final messages = Provider.of<List<Message>?>(context) ?? [];
//
//     return ListView.builder(
//       itemCount: messages.length,
//       itemBuilder: (context, index) {
//         return MessageTile(message: messages[index]);
//       },
//     );
//   }
// }


class MessageTile extends StatefulWidget {
  final Message message;

  const MessageTile({Key? key, required this.message}) : super(key: key);

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {


  @override
  Widget build(BuildContext context) {
    //final lastMessage = Provider.of<Message>(context) ?? "";


    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
          margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
          child: ListTile(
              leading: CircleAvatar(
                radius: 25.0,
                backgroundColor: Colors.brown,
                backgroundImage: AssetImage('images/ab.jpg'),
              ),
              title: Text(widget.message.content),
              //subtitle: Text(widget.message.sendingTime.toString()),
              trailing: SizedBox(
                width: 100,
                child:
                Text(widget.message.sendingTime.toString()),
              )
          )
      ),
    );
  }
}

