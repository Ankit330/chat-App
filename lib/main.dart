import 'package:chat_app/model/firebase_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'model/user_model.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';

var uuid = Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    UserModel thisUserModel =
        await FirebaseHelper.getUserModelById(currentUser.uid);

    runApp(MyAppLogeedIn(userModel: thisUserModel, firebaseUser: currentUser));
  } else {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class MyAppLogeedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MyAppLogeedIn(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(
        firebaseUser: firebaseUser,
        userModel: userModel,
      ),
    );
  }
}
