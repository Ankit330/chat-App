// ignore_for_file: use_build_context_synchronously

import 'package:chat_app/model/char_room_model.dart';
import 'package:chat_app/model/firebase_helper.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/user_model.dart';
import 'chat_room_page.dart';
import 'search_page.dart';

class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const HomePage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Color backgroundColor = const Color(0xFF1F1A30);
  Color enabled = const Color(0xFF827F8A);

  @override
  Widget build(BuildContext context) {
    var we = MediaQuery.of(context).size.width;
    var he = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        drawer: Drawer(
          elevation: 0,
          backgroundColor: backgroundColor,
          child: Column(
            children: [
              SizedBox(
                height: he * 0.02,
              ),
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: backgroundColor,
                ),
              ),
              SizedBox(
                height: he * 0.02,
              ),
              Text(
                widget.userModel.fullname.toString(),
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              Text(
                widget.userModel.email.toString(),
                style: TextStyle(color: Colors.grey[200], fontSize: 15),
              ),
              const Divider(
                thickness: 0.1,
                color: Colors.white,
              ),
              Expanded(child: Container()),
              CupertinoButton(
                  child: Text(
                    "Log Out",
                    style: TextStyle(
                        color: Colors.red[900],
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();

                    Navigator.popUntil(context, (route) => route.isFirst);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  })
            ],
          ),
        ),
        backgroundColor: backgroundColor,
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Chat App"),
          elevation: 0,
          backgroundColor: backgroundColor,
        ),
        body: SafeArea(
            child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("chatrooms")
              .where("users", arrayContains: widget.userModel.uid)
              .orderBy("time", descending: true)
              .snapshots(),
          builder: (BuildContext context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                QuerySnapshot chatRoomSnapshot = snapshot.data as QuerySnapshot;

                return ListView.builder(
                    physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    itemCount: chatRoomSnapshot.docs.length,
                    itemBuilder: (context, index) {
                      ChatRoomModel chatroomModel = ChatRoomModel.fromMap(
                          chatRoomSnapshot.docs[index].data()
                              as Map<String, dynamic>);
                      Map<String, dynamic> participants =
                          chatroomModel.participants!;

                      List<String> participantsKeys =
                          participants.keys.toList();

                      participantsKeys.remove(widget.userModel.uid);

                      return FutureBuilder(
                          future: FirebaseHelper.getUserModelById(
                              participantsKeys[0]),
                          builder: (context, userData) {
                            if (userData.connectionState ==
                                ConnectionState.done) {
                              // ignore: unnecessary_null_comparison
                              if (userData != null) {
                                UserModel targetUser =
                                    userData.data as UserModel;
                                return ListTile(
                                    onTap: () async {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                        return ChatRoomPage(
                                          userModel: widget.userModel,
                                          targetUser: targetUser,
                                          firebaseUser: widget.firebaseUser,
                                          chatRoom: chatroomModel,
                                        );
                                      }));
                                    },
                                    leading: SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.person,
                                          size: 25,
                                          color: backgroundColor,
                                        ),
                                      ),
                                    ),
                                    title: Row(
                                      children: [
                                        Text(
                                          targetUser.fullname!,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20.5,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Expanded(child: Container()),
                                        Text(
                                          "${chatroomModel.time!.day}-${chatroomModel.time!.month}-${chatroomModel.time!.year}",
                                          style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    subtitle: Row(
                                      children: [
                                        (chatroomModel.lastMessage! != "")
                                            ? Text(
                                                chatroomModel.lastMessage!,
                                                style: TextStyle(
                                                  color: Colors.green[200],
                                                  fontSize: 15,
                                                ),
                                              )
                                            : Text(
                                                "Say hi to your friend",
                                                style: TextStyle(
                                                  color: Colors.blue[100],
                                                  fontSize: 15,
                                                ),
                                              ),
                                        Expanded(child: Container()),
                                        Text(
                                          "${chatroomModel.time!.hour}:${chatroomModel.time!.minute}",
                                          style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 12),
                                        ),
                                      ],
                                    ));
                              } else {
                                return const Center(
                                  child: Text(
                                    "An error occured... !!",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 20),
                                  ),
                                );
                              }
                            } else {
                              return const Center(
                                child: Text(
                                  "",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 20),
                                ),
                              );
                            }
                          });
                    });
              } else if (snapshot.hasError) {
                print(snapshot.error.toString());
                return const Center(
                  child: Text(
                    "",
                    style: TextStyle(color: Colors.grey, fontSize: 20),
                  ),
                );
              } else {
                return const Center(
                  child: Text(
                    "No chats",
                    style: TextStyle(color: Colors.grey, fontSize: 20),
                  ),
                );
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.grey,
                ),
              );
            }
          },
        )),
        floatingActionButton: FloatingActionButton(
          backgroundColor: enabled,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SearchPage(
                        firebaseUser: widget.firebaseUser,
                        userModel: widget.userModel,
                      )),
            );
          },
          child: const Icon(Icons.search),
        ),
      ),
    );
  }
}
