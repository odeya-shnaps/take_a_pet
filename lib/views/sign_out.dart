import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:take_a_pet/util/shadow_button.dart';
import 'package:take_a_pet/util/widgets.dart';


class SignOut extends StatefulWidget {
  @override
  _SignOutState createState() => _SignOutState();
}

class _SignOutState extends State<SignOut> {

  Widget build(BuildContext context) {
    return AdminScaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Sign Out'),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_forward),
              tooltip: 'Sign Out',

            ),
          ],
        ),
        sideBar: buildSideBar(context),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'To Sign Out',
                style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 30,),
              Text(
                'Press The Button',
                style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 60,),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login', (Route<dynamic> route) => false).then((_) => setState(() {}));;
                },
                icon: Icon(Icons.logout),
                iconSize: 50,
                color: Colors.lightBlue,
              ),
            ],
          ),
        )
    );
  }

}




/*
return Scaffold(
backgroundColor: Colors.white,
body: Text("Sign Out")
);*/