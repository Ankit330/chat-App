// ignore_for_file: sort_child_properties_last, no_leading_underscores_for_local_identifiers, use_build_context_synchronously, constant_identifier_names, library_private_types_in_public_api

import 'dart:developer';
import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/utils/theme.dart';
import 'package:chat_app/utils/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';

enum Gender { fullname, email, password, confirmpassword, phone }

class Singup extends StatefulWidget {
  const Singup({Key? key}) : super(key: key);

  @override
  _SingupState createState() => _SingupState();
}

class _SingupState extends State<Singup> {
  bool ispasswordev = true;
  Gender? selected;
  bool isComplete = false;

  TextEditingController fullnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpasswordController = TextEditingController();

  void checkValues() {
    String _fullname = fullnameController.text.trim();
    String _email = emailController.text.trim();
    String _password = passwordController.text.trim();
    String _confirmpassword = confirmpasswordController.text.trim();

    if (_fullname == "" ||
        _email == "" ||
        _password == "" ||
        _confirmpassword == "") {
      showSnacBar(context, "Please fill the fields!!");
    } else if (_confirmpassword != _password) {
      showSnacBar(context, "confirm password must be same as password!!");
    } else {
      signup(_email, _password);
    }
  }

  void signup(String email, String password) async {
    try {
      setState(() {
        isComplete = true;
      });
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      )
          .then((value) async {
        String uid = value.user!.uid;
        UserModel newUser = UserModel(
            uid: uid,
            fullname: fullnameController.text.trim(),
            email: email,
            profilepic: '');
        await FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .set(newUser.toMap())
            .then((value) => {log("new user created")});
        setState(() {
          isComplete = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
        showSnacBar(context, "Signup successfully!!");
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        setState(() {
          isComplete = false;
        });
        showSnacBar(context, "The password provided is too weak. !!");
      } else if (e.code == 'email-already-in-use') {
        setState(() {
          isComplete = false;
        });
        showSnacBar(context, "The account already exists for that email. !!");
      }
    } catch (e) {
      log(e.toString());
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
                      SizedBox(height: he * 0.05),
                      GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(left: we * 0.04),
                              child: Icon(
                                Icons.arrow_back_outlined,
                                color: MyTheme.enabledtxt,
                                size: 35.0,
                              ))),
                      SizedBox(height: he * 0.03),
                      Container(
                          margin: const EdgeInsets.only(right: 80.0),
                          child: Text("Create Account",
                              style: GoogleFonts.heebo(
                                  color: MyTheme.enabledtxt,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 35,
                                  letterSpacing: 2))),
                      Container(
                          margin: const EdgeInsets.only(right: 130.0),
                          child: Text("Please fill the input blow here",
                              style: GoogleFonts.heebo(
                                  color: MyTheme.deaible, letterSpacing: 1))),
                      SizedBox(height: he * 0.07),
                      Container(
                          width: we * 0.9,
                          height: he * 0.071,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: selected == Gender.fullname
                                ? MyTheme.enabled
                                : MyTheme.backgroundColor,
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                              controller: fullnameController,
                              onTap: () {
                                setState(() {
                                  selected = Gender.fullname;
                                });
                              },
                              decoration: InputDecoration(
                                enabledBorder: InputBorder.none,
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.person_outlined,
                                    color: selected == Gender.fullname
                                        ? MyTheme.enabledtxt
                                        : MyTheme.deaible),
                                hintText: 'FULL NAME',
                                hintStyle: TextStyle(
                                    color: selected == Gender.fullname
                                        ? MyTheme.enabledtxt
                                        : MyTheme.deaible),
                              ),
                              style: TextStyle(
                                  color: selected == Gender.fullname
                                      ? MyTheme.enabledtxt
                                      : MyTheme.deaible,
                                  fontWeight: FontWeight.bold))),
                      SizedBox(height: he * 0.02),
                      Container(
                          width: we * 0.9,
                          height: he * 0.071,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              color: selected == Gender.email
                                  ? MyTheme.enabled
                                  : MyTheme.backgroundColor),
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                              controller: emailController,
                              onTap: () {
                                setState(() {
                                  selected = Gender.email;
                                });
                              },
                              decoration: InputDecoration(
                                enabledBorder: InputBorder.none,
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.email_outlined,
                                    color: selected == Gender.email
                                        ? MyTheme.enabledtxt
                                        : MyTheme.deaible),
                                hintText: 'EMAIL',
                                hintStyle: TextStyle(
                                    color: selected == Gender.email
                                        ? MyTheme.enabledtxt
                                        : MyTheme.deaible),
                              ),
                              style: TextStyle(
                                  color: selected == Gender.email
                                      ? MyTheme.enabledtxt
                                      : MyTheme.deaible,
                                  fontWeight: FontWeight.bold))),
                      SizedBox(height: he * 0.02),
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
                                  prefixIcon: Icon(Icons.lock_open_outlined,
                                      color: selected == Gender.password
                                          ? MyTheme.enabledtxt
                                          : MyTheme.deaible),
                                  suffixIcon: IconButton(
                                      icon: ispasswordev
                                          ? Icon(Icons.visibility_off,
                                              color: selected == Gender.password
                                                  ? MyTheme.enabledtxt
                                                  : MyTheme.deaible)
                                          : Icon(Icons.visibility,
                                              color: selected == Gender.password
                                                  ? MyTheme.enabledtxt
                                                  : MyTheme.deaible),
                                      onPressed: () => setState(
                                          () => ispasswordev = !ispasswordev)),
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
                                  fontWeight: FontWeight.bold))),
                      SizedBox(height: he * 0.02),
                      Container(
                          width: we * 0.9,
                          height: he * 0.071,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              color: selected == Gender.confirmpassword
                                  ? MyTheme.enabled
                                  : MyTheme.backgroundColor),
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                              controller: confirmpasswordController,
                              onTap: () {
                                setState(() {
                                  selected = Gender.confirmpassword;
                                });
                              },
                              decoration: InputDecoration(
                                  enabledBorder: InputBorder.none,
                                  border: InputBorder.none,
                                  prefixIcon: Icon(Icons.lock_open_outlined,
                                      color: selected == Gender.confirmpassword
                                          ? MyTheme.enabledtxt
                                          : MyTheme.deaible),
                                  suffixIcon: IconButton(
                                      icon: ispasswordev
                                          ? Icon(Icons.visibility_off,
                                              color: selected == Gender.confirmpassword
                                                  ? MyTheme.enabledtxt
                                                  : MyTheme.deaible)
                                          : Icon(Icons.visibility,
                                              color: selected ==
                                                      Gender.confirmpassword
                                                  ? MyTheme.enabledtxt
                                                  : MyTheme.deaible),
                                      onPressed: () => setState(
                                          () => ispasswordev = !ispasswordev)),
                                  hintText: 'Confirm Password',
                                  hintStyle: TextStyle(
                                      color: selected == Gender.confirmpassword ? MyTheme.enabledtxt : MyTheme.deaible)),
                              obscureText: ispasswordev,
                              style: TextStyle(color: selected == Gender.confirmpassword ? MyTheme.enabledtxt : MyTheme.deaible, fontWeight: FontWeight.bold))),
                      SizedBox(height: he * 0.03),
                      (isComplete == false)
                          ? TextButton(
                              onPressed: () {
                                checkValues();
                              },
                              child: Text("Sign Up",
                                  style: GoogleFonts.heebo(
                                      color: Colors.black,
                                      letterSpacing: 0.5,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold)),
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
                      SizedBox(height: he * 0.13),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Already have a account?",
                                style: GoogleFonts.heebo(
                                    color: Colors.grey, letterSpacing: 0.5)),
                            GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return LoginPage();
                                  }));
                                },
                                child: Text("Sign in",
                                    style: GoogleFonts.heebo(
                                        color: const Color(0xFF0DF5E4)
                                            .withOpacity(0.9),
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5)))
                          ])
                    ])))));
  }
}
