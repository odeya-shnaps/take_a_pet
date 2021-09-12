import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:take_a_pet/db/db_logic.dart';
import 'package:take_a_pet/models/app_user.dart';
import 'package:take_a_pet/models/app_user.dart';
import 'package:take_a_pet/util/widgets.dart';
import 'package:take_a_pet/views/registration.dart';
import 'package:take_a_pet/views/user_profile.dart';
import 'package:take_a_pet/db/storage_repository.dart';

const users = const {
  'tusua@gmail.com': '12345',
  'hunter@gmail.com': 'hunter',
  'odeya.shnaps@gmail.com': '12345'
};

class Login extends StatefulWidget {

  Login({Key? key, required this.logic, required this.storage}) : super(key: key);

  final DBLogic logic;
  final StorageRepository storage;

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  AppUser? appUser;
  bool toHome = true;

//  @override
//  void initState() {
//    super.initState();
//  }

  Duration get loginTime => Duration(milliseconds: 2250);

  /*Future<String> _authUser(LoginData data) {
    print('Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(data.name)) {
        return 'User not exists';
      }
      if (users[data.name] != data.password) {
        return 'Password does not match';
      }
      return "";
    });
  }*/

  Future<String> _authUser(LoginData data) {
    //print('Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) async {
      try{
        appUser = await widget.logic.logIn(email: data.name, password: data.password);
        return "";
      }
      catch(e){
        return e.toString();
      }

    });
  }

  Future<String> _register(LoginData data) {
    //print('Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) async{
      try{
        appUser = await widget.logic.registration(email: data.name, password: data.password, firstName: "", gender: "", lastName: "");
        toHome = false;
        return "";
      }
      catch(e){
        return e.toString();
      }
    });
  }


  Future<String> _recoverPassword(String name) {
    print('Name: $name');
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(name)) {
        return 'User not exists';
      }
      return "";
    });
  }

  @override
  Widget build(BuildContext context) {

    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(


      body: SizedBox(
        width: deviceSize.width,
        height: deviceSize.height,
        child: FlutterLogin(
          logo: 'assets/images/logo.png',

          //title: 'Take A Pet',
          //logo: '/images/logo.png',
          onLogin: _authUser,
          onSignup: _register,
          hideForgotPasswordButton: true,
          onSubmitAnimationCompleted: () {
            if (toHome) {
              Navigator.pushReplacementNamed(context, '/home_profiles.dart');
            }
            else {
              //Navigator.pushReplacementNamed(context, '/registration');
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Registration(logic: widget.logic, storage: widget.storage),
                  ));
            }
          },
          onRecoverPassword: _recoverPassword,
          theme: LoginTheme(
              primaryColor: Colors.lightBlue,
              cardTheme: CardTheme(
                //color: Colors.
              )
          ),
        ),
      ),
    );
  }
}