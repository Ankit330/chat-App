// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:chat_app/main.dart';
import 'package:chat_app/model/char_room_model.dart';
import 'package:chat_app/pages/chat_room_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../model/user_model.dart';

enum Gender { Email }

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const SearchPage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Color enabled = const Color(0xFF827F8A);
  Color enabledtxt = Colors.white;
  Color deaible = Colors.grey;
  Color backgroundColor = const Color(0xFF1F1A30);
  Gender? selected;

  TextEditingController searchController = TextEditingController();

  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.isNotEmpty) {
      var docData = snapshot.docs[0].data();

      ChatRoomModel existingChatroom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);

      chatRoom = existingChatroom;
    } else {
      ChatRoomModel newChatroom = ChatRoomModel(
          time: DateTime.now(),
          chatroomid: uuid.v1(),
          lastMessage: "",
          users: [
            widget.userModel.uid.toString(),
            targetUser.uid.toString()
          ],
          participants: {
            widget.userModel.uid.toString(): true,
            targetUser.uid.toString(): true,
          });

      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatroom.chatroomid)
          .set(newChatroom.toMap());

      chatRoom = newChatroom;
      log("new");
    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    var we = MediaQuery.of(context).size.width;
    var he = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Search"),
        elevation: 0,
        backgroundColor: backgroundColor,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0, top: 7),
              child: Container(
                width: we * 0.9,
                height: he * 0.071,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: selected == Gender.Email ? enabled : backgroundColor,
                ),
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  controller: searchController,
                  onTap: () {
                    setState(() {
                      selected = Gender.Email;
                    });
                  },
                  decoration: InputDecoration(
                    enabledBorder: InputBorder.none,
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: selected == Gender.Email ? enabledtxt : deaible,
                    ),
                    hintText: 'Email',
                    hintStyle: TextStyle(
                      color: selected == Gender.Email ? enabledtxt : deaible,
                    ),
                  ),
                  style: TextStyle(
                      color: selected == Gender.Email ? enabledtxt : deaible,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              height: he * 0.01,
            ),
            TextButton(
                onPressed: () {
                  setState(() {});
                },
                style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 0.0, horizontal: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.5))),
                child: Text(
                  "Search",
                  style: GoogleFonts.heebo(
                    color: Colors.black,
                    letterSpacing: 0,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                )),
            SizedBox(
              height: he * 0.01,
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .where("email", isEqualTo: searchController.text)
                  .where("email", isNotEqualTo: widget.userModel.email)
                  .snapshots(),
              builder: (BuildContext context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot dataSnapshort =
                        snapshot.data as QuerySnapshot;
                    if (dataSnapshort.docs.isNotEmpty) {
                      Map<String, dynamic> userMap =
                          dataSnapshort.docs[0].data() as Map<String, dynamic>;

                      UserModel searchUser = UserModel.fromMap(userMap);

                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 5),
                        child: ListTile(
                          onTap: () async {
                            ChatRoomModel? chatRoomModel =
                                await getChatRoomModel(searchUser);

                            if (chatRoomModel != null) {
                              Navigator.pop(context);
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return ChatRoomPage(
                                  userModel: widget.userModel,
                                  targetUser: searchUser,
                                  firebaseUser: widget.firebaseUser,
                                  chatRoom: chatRoomModel,
                                );
                              }));
                            }
                          },
                          leading: CircleAvatar(
                            backgroundColor: enabledtxt,
                            child: Icon(
                              Icons.person,
                              color: backgroundColor,
                            ),
                          ),
                          title: Text(
                            searchUser.fullname!,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20),
                          ),
                          subtitle: Text(
                            searchUser.email!,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                          trailing: Icon(
                            Icons.keyboard_arrow_right,
                            color: enabledtxt,
                          ),
                        ),
                      );
                    } else {
                      return Center(
                        child: Text(
                          "No result found !!",
                          style: TextStyle(color: enabled),
                        ),
                      );
                    }
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text(
                      "An error occured. !!",
                      style: TextStyle(color: enabled),
                    ));
                  } else {
                    return Center(
                        child: Text(
                      "No result found. !!",
                      style: TextStyle(color: enabled),
                    ));
                  }
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: enabled,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
