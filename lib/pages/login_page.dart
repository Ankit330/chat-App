// ignore_for_file: use_key_in_widget_constructors, constant_identifier_names, sort_child_properties_last, use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/utils/theme.dart';
import 'package:chat_app/utils/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'signup_page.dart';

enum Gender { Email, password }

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<LoginPage> {
  bool ispasswordev = true;
  Gender? selected;
  static bool iscomplete = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    if (email == "" || password == "") {
      showSnacBar(context, "Please fill the fields!!");
    } else {
      login(email, password);
    }
  }

  void login(String email, String password) async {
    try {
      setState(() {
        iscomplete = true;
      });
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) async {
        setState(() {
          iscomplete = false;
        });

        String uid = value.user!.uid;

        DocumentSnapshot userData =
            await FirebaseFirestore.instance.collection("users").doc(uid).get();

        UserModel userModel =
            UserModel.fromMap(userData.data() as Map<String, dynamic>);
        showSnacBar(context, "Login successfully!!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(
                    firebaseUser: value.user!,
                    userModel: userModel,
                  )),
        );

        // await Future.delayed(const Duration(milliseconds: 100));
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        setState(() {
          iscomplete = false;
        });
        showSnacBar(context, "No user found for that email. !!");
      } else if (e.code == 'wrong-password') {
        setState(() {
          iscomplete = false;
        });
        showSnacBar(context, "Wrong password provided for that user. !!");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var we = MediaQuery.of(context).size.width;
    var he = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: MyTheme.backgroundColor,
        body: SafeArea(
            child: SingleChildScrollView(
                child: SizedBox(
                    width: we,
                    height: he,
                    child: Column(children: <Widget>[
                      CachedNetworkImage(
                        imageUrl:
                            "https://cdn3.iconfinder.com/data/icons/outline-business-set-1/256/a-25-512.png",
                        width: we * 0.9,
                        height: he * 0.4,
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 230.0),
                        child: Text(
                          "Login",
                          style: GoogleFonts.heebo(
                              color: MyTheme.enabledtxt,
                              fontWeight: FontWeight.bold,
                              fontSize: 35,
                              letterSpacing: 2),
                        ),
                      ),
                      SizedBox(
                        height: he * 0.01,
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 150.0),
                        child: Text(
                          "Please sign in to continue",
                          style: GoogleFonts.heebo(
                              color: MyTheme.deaible, letterSpacing: 0.5),
                        ),
                      ),
                      SizedBox(
                        height: he * 0.04,
                      ),
                      Container(
                        width: we * 0.9,
                        height: he * 0.071,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: selected == Gender.Email
                              ? MyTheme.enabled
                              : MyTheme.backgroundColor,
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: emailController,
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
                              color: selected == Gender.Email
                                  ? MyTheme.enabledtxt
                                  : MyTheme.deaible,
                            ),
                            hintText: 'Email',
                            hintStyle: TextStyle(
                              color: selected == Gender.Email
                                  ? MyTheme.enabledtxt
                                  : MyTheme.deaible,
                            ),
                          ),
                          style: TextStyle(
                              color: selected == Gender.Email
                                  ? MyTheme.enabledtxt
                                  : MyTheme.deaible,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: he * 0.02,
                      ),
                      Container(
                        width: we * 0.9,
                        height: he * 0.071,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: selected == Gender.password
                                ? MyTheme.enabled
                                : MyTheme.backgroundColor),
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: passwordController,
                          onTap: () {
                            setState(() {
                              selected = Gender.password;
                            });
                          },
                          decoration: InputDecoration(
                              enabledBorder: InputBorder.none,
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.lock_open_outlined,
                                color: selected == Gender.password
                                    ? MyTheme.enabledtxt
                                    : MyTheme.deaible,
                              ),
                              suffixIcon: IconButton(
                                icon: ispasswordev
                                    ? Icon(
                                        Icons.visibility_off,
                                        color: selected == Gender.password
                                            ? MyTheme.enabledtxt
                                            : MyTheme.deaible,
                                      )
                                    : Icon(
                                        Icons.visibility,
                                        color: selected == Gender.password
                                            ? MyTheme.enabledtxt
                                            : MyTheme.deaible,
                                      ),
                                onPressed: () => setState(
                                    () => ispasswordev = !ispasswordev),
                              ),
                              hintText: 'Password',
                              hintStyle: TextStyle(
                                  color: selected == Gender.password
                                      ? MyTheme.enabledtxt
                                      : MyTheme.deaible)),
                          obscureText: ispasswordev,
                          style: TextStyle(
                              color: selected == Gender.password
                                  ? MyTheme.enabledtxt
                                  : MyTheme.deaible,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: he * 0.03,
                      ),
                      (iscomplete == false)
                          ? TextButton(
                              onPressed: () {
                                checkValues();
                              },
                              child: Text(
                                "Login",
                                style: GoogleFonts.heebo(
                                  color: Colors.black,
                                  letterSpacing: 0.5,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFF0DF5E4),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15.0, horizontal: 80),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(30.0))))
                          : SizedBox(
                              height: 56,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: MyTheme.enabled,
                                ),
                              ),
                            ),
                      SizedBox(
                        height: he * 0.01,
                      ),
                      GestureDetector(
                        onTap: () {
                          final snackBar = SnackBar(
                            content: const Text(
                                "Comming Soon otherwise contact Ankit"),
                            backgroundColor: MyTheme.backgroundColor,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        },
                        child: Text("Forgot password?",
                            style: GoogleFonts.heebo(
                              color: const Color(0xFF0DF5E4).withOpacity(0.9),
                              letterSpacing: 0.5,
                            )),
                      ),
                      SizedBox(height: he * 0.08),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account?",
                                style: GoogleFonts.heebo(
                                  color: MyTheme.deaible,
                                  letterSpacing: 0.5,
                                )),
                            GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return const Singup();
                                  }));
                                },
                                child: Text("Sign up",
                                    style: GoogleFonts.heebo(
                                      color: const Color(0xFF0DF5E4)
                                          .withOpacity(0.9),
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    )))
                          ])
                    ])))));
  }
}
