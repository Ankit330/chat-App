import 'package:chat_app/utils/theme.dart';
import 'package:flutter/material.dart';

void showSnacBar(BuildContext context, String text) {
  final SnackBar snackBar;

  snackBar = SnackBar(
    content: Center(child: Text(text)),
    backgroundColor: MyTheme.backgroundColor,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Widget showText(String text) {
  return Center(
    child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 20)),
  );
}

Widget indicator() {
  return const Center(
    child: CircularProgressIndicator(
      strokeWidth: 3,
      color: Colors.grey,
    ),
  );
}
