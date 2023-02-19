// ignore_for_file: use_key_in_widget_constructors, constant_identifier_names, sort_child_properties_last, use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/pages/home_page.dart';
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
  Color enabled = const Color(0xFF827F8A);
  Color enabledtxt = Colors.white;
  Color deaible = Colors.grey;
  Color backgroundColor = const Color(0xFF1F1A30);
  bool ispasswordev = true;
  Gender? selected;
  bool iscomplete = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    if (email == "" || password == "") {
      final snackBar = SnackBar(
        content: const Center(child: Text("Please fill the fields!!")),
        backgroundColor: backgroundColor,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      login(email, password);
    }
  }

  void login(String email, String password) async {
    UserCredential? credential;
    try {
      setState(() {
        iscomplete = true;
      });
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) async {
        setState(() {
          iscomplete = false;
        });
        print(value.user!.uid);
        String uid = value.user!.uid;

        DocumentSnapshot userData =
            await FirebaseFirestore.instance.collection("users").doc(uid).get();

        UserModel userModel =
            UserModel.fromMap(userData.data() as Map<String, dynamic>);
        final snackBar = SnackBar(
          content: const Center(child: Text("Login successfully!!")),
          backgroundColor: backgroundColor,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
        final snackBar = SnackBar(
          content:
              const Center(child: Text("No user found for that email. !!")),
          backgroundColor: backgroundColor,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        // print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        setState(() {
          iscomplete = false;
        });
        // print('Wrong password provided for that user.');
        final snackBar = SnackBar(
          content: const Center(
              child: Text("Wrong password provided for that user. !!")),
          backgroundColor: backgroundColor,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
    if (credential != null) {}
  }

  @override
  Widget build(BuildContext context) {
    var we = MediaQuery.of(context).size.width;
    var he = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: const Color(0xFF1F1A30),
        body: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              width: we,
              height: he,
              child: Column(
                children: <Widget>[
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
                          color: Colors.white,
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
                          color: Colors.grey, letterSpacing: 0.5),
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
                      color:
                          selected == Gender.Email ? enabled : backgroundColor,
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
                          color:
                              selected == Gender.Email ? enabledtxt : deaible,
                        ),
                        hintText: 'Email',
                        hintStyle: TextStyle(
                          color:
                              selected == Gender.Email ? enabledtxt : deaible,
                        ),
                      ),
                      style: TextStyle(
                          color:
                              selected == Gender.Email ? enabledtxt : deaible,
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
                            ? enabled
                            : backgroundColor),
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
                                ? enabledtxt
                                : deaible,
                          ),
                          suffixIcon: IconButton(
                            icon: ispasswordev
                                ? Icon(
                                    Icons.visibility_off,
                                    color: selected == Gender.password
                                        ? enabledtxt
                                        : deaible,
                                  )
                                : Icon(
                                    Icons.visibility,
                                    color: selected == Gender.password
                                        ? enabledtxt
                                        : deaible,
                                  ),
                            onPressed: () =>
                                setState(() => ispasswordev = !ispasswordev),
                          ),
                          hintText: 'Password',
                          hintStyle: TextStyle(
                              color: selected == Gender.password
                                  ? enabledtxt
                                  : deaible)),
                      obscureText: ispasswordev,
                      style: TextStyle(
                          color: selected == Gender.password
                              ? enabledtxt
                              : deaible,
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
                                  borderRadius: BorderRadius.circular(30.0))))
                      : SizedBox(
                          height: 56,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: enabled,
                            ),
                          ),
                        ),
                  SizedBox(
                    height: he * 0.01,
                  ),
                  GestureDetector(
                    onTap: () {
                      final snackBar = SnackBar(
                        content:
                            const Text("Comming Soon otherwise contact Ankit"),
                        backgroundColor: backgroundColor,
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
                            color: Colors.grey,
                            letterSpacing: 0.5,
                          )),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return const Singup();
                          }));
                        },
                        child: Text("Sign up",
                            style: GoogleFonts.heebo(
                              color: const Color(0xFF0DF5E4).withOpacity(0.9),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            )),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
