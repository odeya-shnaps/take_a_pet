import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:take_a_pet/util/text_form.dart';

MaterialButton longButtons(String title, void Function() fun,
    {Color color: const Color(0xfff063057), Color textColor: Colors.white}) {
  return MaterialButton(
    onPressed: fun,
    textColor: textColor,
    color: color,
    child: SizedBox(
      width: 100.0,
      child: Text(
        title,
        textAlign: TextAlign.center,
      ),
    ),
    height: 45,
    minWidth: 100,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(40))
    ),
  );
}

label(String title) => Text(title);

InputDecoration buildInputDecoration(String hintText, IconData icon) {
  return InputDecoration(
    prefixIcon: Icon(icon, color: Color.fromRGBO(50, 62, 72, 1.0)),
    // hintText: hintText,
    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
  );
}

SideBar buildSideBar(BuildContext context) {
  return SideBar(
    items: const [
      MenuItem(
        title: 'Home',
        route: '/home_profiles.dart',
        icon: Icons.home,
      ),
      MenuItem(
        title: 'Favorites',
        route: '/favorites',
        icon: Icons.favorite,
      ),
      MenuItem(
        title: 'My Profile',
        route: '/user_profile_edit',
        icon: Icons.person,
      ),
      MenuItem(
        title: 'Create Animal Profile',
        route: '/animal_profile_create',
        icon: Icons.add,
      ),
      MenuItem(
        title: 'Created By Me',
        route: '/created_profiles',
        icon: Icons.list_alt,
      ),

      MenuItem(
        title: 'Recommendations',
        route: '/recommendation',
        icon: Icons.recommend,
      ),
      MenuItem(
        title: 'Chats',
        route: '/chats',
        icon: Icons.chat,
      ),
      MenuItem(
        title: 'Sign Out',
        route: '/sign_out',
        icon: Icons.logout,
      ),
    ],
    selectedRoute: '/',
    onSelected: (item) {
      if (item.route != null) {
        Navigator.of(context).pushNamed(item.route!);
      }
    },
/*
    header: Center(
      child: Container(
          width: 100.0,
          height: 100.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[400],
          ),
          child: Icon(
            Icons.person,
            size: 60,
            color: Colors.white,
          )
      ),
    ),
    footer: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
              width: 80.0,
              height: 60,
            color: Colors.transparent,
            child: Image.asset('assets/images/logo.png', ),
          ),
          SizedBox(width: 20,),
          Text("Take A Pet", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),),
        ],
      ),
    ),*/
    header: Center(
      child: Container(
          width: 240,
          height: 90,
        color: Colors.white70,
        child: Image.asset('assets/images/logo.png', ),
      ),
    ),
  );
}


    /*
    Container(
      height: 50,
      width: double.infinity,
      color: Colors.white24,
      child: Center(
        child: Text(
          'footer',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    ),
  );
}*/

/*
Widget buildAppBar(BuildContext context) {
  final deviceSize = MediaQuery.of(context).size;

  return Row(
    children: [
      IconButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/create_profile');
          },
          icon: Icon(Icons.add),
      ),
      SizedBox(width: 10,),
      AnimatedTextFormField(
          interval: const Interval(0, .85),
          width: deviceSize.width/2,
          maxLines: 1,
          labelText: 'Search',
          prefixIcon: Icon(Icons.search),
          keyboardType: TextInputType.name,
          autofillHints: [AutofillHints.username],
          onFieldSubmitted: (value) {
            // search...
          }
      ),
    ],
  );
}*/

List<Widget> buildAppBar(BuildContext context) {
  return <Widget>[
    IconButton(
        onPressed: () {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
        },
        icon: Icon(Icons.logout)
    ),
    IconButton(
        onPressed: () {
          //setState(() {});
        },
        icon: Icon(Icons.refresh)
    ),
  ];
}