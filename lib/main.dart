import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:take_a_pet/home_profiles.dart';
import 'package:take_a_pet/models/animal_profile.dart';
import 'package:take_a_pet/models/history.dart';
import 'package:take_a_pet/util/dynamic_text_field.dart';
import 'package:take_a_pet/views/animal_profile_create.dart';
import 'package:take_a_pet/views/animal_profile_edit.dart';
import 'package:take_a_pet/views/camera_view.dart';
import 'package:take_a_pet/views/chats_view.dart';
import 'package:take_a_pet/views/created_profiles.dart';
import 'package:take_a_pet/views/user_profile_edit.dart';
import 'package:take_a_pet/views/user_profile_view.dart';
import 'package:take_a_pet/wrappers/main_wrapper.dart';
import 'db/data_repository.dart';
import 'db/db_logic.dart';
import 'models/app_user.dart';
import 'package:take_a_pet/views/login.dart';
import 'package:take_a_pet/views/recommendation.dart';
import 'package:take_a_pet/views/animal_profile_view.dart';
import 'package:take_a_pet/views/favorites.dart';
import 'package:take_a_pet/views/sign_out.dart';
import 'package:take_a_pet/db/storage_repository.dart';


void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp();

    DBLogic logic = DBLogic();
    DataRepository dateRepo = new DataRepository();
    StorageRepository storageRepo = new StorageRepository();

    Map<String, Widget Function(BuildContext)> routes = {
      '/': (context) => Login(logic: logic, storage: storageRepo),
      '/created_profiles': (context) => CreatedProfiles(logic: logic, storage: storageRepo, dataRepo: dateRepo,),
      '/login': (context) => Login(logic: logic, storage: storageRepo),
      '/favorites': (context) => Favorites(logic: logic, storage: storageRepo, dataRepo: dateRepo,),
      '/user_profile_edit': (context) => UserProfileEdit(logic: logic, storage: storageRepo,),
      '/animal_profile_create': (context) => AnimalProfileCreate(logic: logic, storage: storageRepo, dataRepo: dateRepo),
      '/recommendation': (context) => Recommendation(logic: logic, storage: storageRepo, dataRepo: dateRepo,),
      '/sign_out': (context) => SignOut(),
      '/chats': (context) => ChatsView(),
      '/home_profiles.dart': (context) => HomeProfiles(logic: logic, storage: storageRepo, dataRepo: dateRepo,),


    };

    runApp(MyApp(routes: routes,logic: logic,));

  } catch (e) {
    print(e);
  }

}


class MyApp extends StatelessWidget {

  MyApp({required this.routes, required this.logic});

  final Map<String, Widget Function(BuildContext)> routes;
  final DBLogic logic;

  @override
  Widget build(BuildContext context) {


    // listen to changes in AuthService.user stream
    return StreamProvider<User?>.value(
      value: logic.listenToUserAuth(),
      initialData: null, //user signed out
      child: MaterialApp(
        //initialRoute: '/login',
        //routes: this.routes,
        // passing the change in stream to child widgets
        home: MainWrapper(routes: this.routes,),
      ),
    );
  }
}


