import 'package:chat_app/main.dart';
import 'package:chat_app/model/char_room_model.dart';
import 'package:chat_app/model/message_model.dart';
import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/utils/theme.dart';
import 'package:chat_app/utils/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatRoom;
  final UserModel userModel;
  final User firebaseUser;
  const ChatRoomPage({
    super.key,
    required this.targetUser,
    required this.chatRoom,
    required this.userModel,
    required this.firebaseUser,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();

    if (msg != "") {
      MessageModel newMessage = MessageModel(
        messageid: uuid.v1(),
        sender: widget.userModel.uid,
        text: msg,
        seen: false,
        createdon: DateTime.now(),
      );
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatRoom.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());

      widget.chatRoom.lastMessage = msg;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatRoom.chatroomid)
          .set(widget.chatRoom.toMap());
      DateTime messageTime = DateTime.now();
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatRoom.chatroomid)
          .update({"time": messageTime});
    }
  }

  @override
  Widget build(BuildContext context) {
    var he = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: MyTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: MyTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(widget.targetUser.fullname.toString()),
      ),
      body: SafeArea(
          child: Column(
        children: [
          Expanded(
              child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("chatrooms")
                    .doc(widget.chatRoom.chatroomid)
                    .collection("messages")
                    .orderBy("createdon", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot dataSnapshot =
                          snapshot.data as QuerySnapshot;

                      return ListView.builder(
                          physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics()),
                          reverse: true,
                          itemCount: dataSnapshot.docs.length,
                          itemBuilder: (context, index) {
                            MessageModel currentMessage = MessageModel.fromMap(
                                dataSnapshot.docs[index].data()
                                    as Map<String, dynamic>);
                            return Row(
                              mainAxisAlignment: (currentMessage.sender ==
                                      widget.userModel.uid)
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10),
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 2),
                                    decoration: BoxDecoration(
                                        color: (currentMessage.sender ==
                                                widget.userModel.uid)
                                            ? Colors.grey[300]
                                            : Colors.green[200],
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              currentMessage.text.toString(),
                                              style: TextStyle(
                                                  color:
                                                      MyTheme.backgroundColor,
                                                  fontSize: 17.2,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              "   ",
                                              style: TextStyle(
                                                  color:
                                                      MyTheme.backgroundColor,
                                                  fontSize: 17.2,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: he * 0.004,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "${currentMessage.createdon!.hour}:${currentMessage.createdon!.minute}",
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 11),
                                            ),
                                            SizedBox(
                                              width: he * 0.002,
                                            ),
                                          ],
                                        ),
                                      ],
                                    )),
                              ],
                            );
                          });
                    } else if (snapshot.hasError) {
                      return showText(
                          "An error occured! Please check your internet connection. !!");
                    } else {
                      return showText("Say hey to your friend");
                    }
                  } else {
                    return indicator();
                  }
                }),
          )),
          SizedBox(
            height: he * 0.01,
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(40)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Row(
              children: [
                Flexible(
                    child: TextField(
                  maxLines: null,
                  controller: messageController,
                  decoration: InputDecoration(
                      enabledBorder: InputBorder.none,
                      border: InputBorder.none,
                      hintText: "Type Message",
                      hintStyle: TextStyle(color: MyTheme.enabledtxt)),
                  style: TextStyle(color: MyTheme.enabledtxt),
                )),
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  child: Center(
                    child: IconButton(
                        onPressed: () {
                          sendMessage();
                        },
                        icon: Icon(
                          Icons.send,
                          color: MyTheme.backgroundColor,
                        )),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: he * 0.02,
          ),
        ],
      )),
    );
  }
}
