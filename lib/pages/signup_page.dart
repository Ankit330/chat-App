// ignore_for_file: sort_child_properties_last, no_leading_underscores_for_local_identifiers, use_build_context_synchronously

import 'package:chat_app/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';

enum Gender { fullname, Email, password, confirmpassword, phone }

class Singup extends StatefulWidget {
  const Singup({Key? key}) : super(key: key);

  @override
  _SingupState createState() => _SingupState();
}

class _SingupState extends State<Singup> {
  Color enabled = const Color(0xFF827F8A);
  Color enabledtxt = Colors.white;
  Color deaible = Colors.grey;
  Color backgroundColor = const Color(0xFF1F1A30);
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
      final snackBar = SnackBar(
        content: const Center(child: Text("Please fill the fields!!")),
        backgroundColor: backgroundColor,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (_confirmpassword != _password) {
      final snackBar = SnackBar(
        content: const Center(
            child: Text("confirm password must be same as password!!")),
        backgroundColor: backgroundColor,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      signup(_email, _password);
    }
  }

  void signup(String email, String password) async {
    UserCredential? credential;
    try {
      setState(() {
        isComplete = true;
      });
      credential = await FirebaseAuth.instance
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
            .then((value) => {print("new user created")});
        setState(() {
          isComplete = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
        final snackBar = SnackBar(
          content: const Center(child: Text("Signup successfully!!")),
          backgroundColor: backgroundColor,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        setState(() {
          isComplete = false;
        });
        final snackBar = SnackBar(
          content: const Center(
              child: Text("The password provided is too weak. !!")),
          backgroundColor: backgroundColor,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        // print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        setState(() {
          isComplete = false;
        });
        final snackBar = SnackBar(
          content: const Center(
              child: Text("The account already exists for that email. !!")),
          backgroundColor: backgroundColor,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        // print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    var we = MediaQuery.of(context).size.width;
    var he = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            width: we,
            height: he,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: he * 0.05,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.only(left: we * 0.04),
                    child: const Icon(
                      Icons.arrow_back_outlined,
                      color: Colors.white,
                      size: 35.0,
                    ),
                  ),
                ),
                SizedBox(
                  height: he * 0.03,
                ),
                Container(
                  margin: const EdgeInsets.only(right: 80.0),
                  child: Text(
                    "Create Account",
                    style: GoogleFonts.heebo(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 35,
                        letterSpacing: 2),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 130.0),
                  child: Text(
                    "Please fill the input blow here",
                    style:
                        GoogleFonts.heebo(color: Colors.grey, letterSpacing: 1),
                  ),
                ),
                SizedBox(height: he * 0.07),
                Container(
                  width: we * 0.9,
                  height: he * 0.071,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color:
                        selected == Gender.fullname ? enabled : backgroundColor,
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
                      prefixIcon: Icon(
                        Icons.person_outlined,
                        color:
                            selected == Gender.fullname ? enabledtxt : deaible,
                      ),
                      hintText: 'FULL NAME',
                      hintStyle: TextStyle(
                        color:
                            selected == Gender.fullname ? enabledtxt : deaible,
                      ),
                    ),
                    style: TextStyle(
                        color:
                            selected == Gender.fullname ? enabledtxt : deaible,
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
                    color: selected == Gender.Email ? enabled : backgroundColor,
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
                        color: selected == Gender.Email ? enabledtxt : deaible,
                      ),
                      hintText: 'EMAIL',
                      hintStyle: TextStyle(
                        color: selected == Gender.Email ? enabledtxt : deaible,
                      ),
                    ),
                    style: TextStyle(
                        color: selected == Gender.Email ? enabledtxt : deaible,
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
                        color:
                            selected == Gender.password ? enabledtxt : deaible,
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
                      color: selected == Gender.confirmpassword
                          ? enabled
                          : backgroundColor),
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
                        prefixIcon: Icon(
                          Icons.lock_open_outlined,
                          color: selected == Gender.confirmpassword
                              ? enabledtxt
                              : deaible,
                        ),
                        suffixIcon: IconButton(
                          icon: ispasswordev
                              ? Icon(
                                  Icons.visibility_off,
                                  color: selected == Gender.confirmpassword
                                      ? enabledtxt
                                      : deaible,
                                )
                              : Icon(
                                  Icons.visibility,
                                  color: selected == Gender.confirmpassword
                                      ? enabledtxt
                                      : deaible,
                                ),
                          onPressed: () =>
                              setState(() => ispasswordev = !ispasswordev),
                        ),
                        hintText: 'Confirm Password',
                        hintStyle: TextStyle(
                            color: selected == Gender.confirmpassword
                                ? enabledtxt
                                : deaible)),
                    obscureText: ispasswordev,
                    style: TextStyle(
                        color: selected == Gender.confirmpassword
                            ? enabledtxt
                            : deaible,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: he * 0.03,
                ),
                (isComplete == false)
                    ? TextButton(
                        onPressed: () {
                          checkValues();
                        },
                        child: Text(
                          "Sign Up",
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
                SizedBox(height: he * 0.13),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have a account?",
                        style: GoogleFonts.heebo(
                          color: Colors.grey,
                          letterSpacing: 0.5,
                        )),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return LoginPage();
                        }));
                      },
                      child: Text("Sign in",
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
      ),
    );
  }
}
