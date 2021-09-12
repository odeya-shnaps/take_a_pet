import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class MainWrapper extends StatelessWidget {
  const MainWrapper({Key? key, required this.routes}) : super(key: key);

  final Map<String, Widget Function(BuildContext)> routes;

  /// ADD WHEN DELETING FROM CONSOLE THE USER IS LOGGED OUT
  @override
  Widget build(BuildContext context) {
    // gets the changes from the StreamProvider in main
    final user = Provider.of<User?>(context);
    String initRout = "/login";
    // the user logged in
    if(user != null) {
      initRout = "/home_profiles.dart";
    }
    return MaterialApp(
      initialRoute: initRout,
      routes: routes,
    );
  }
}

/*
// the user logged out
    if(user == null) {
      return LoginView(title: 'LOG IN VIEW');
    }else { // the user logged in
      return CameraView(title: 'Camera Camera 2.0');
    }
 */