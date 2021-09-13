import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:take_a_pet/db/data_repository.dart';
import 'package:take_a_pet/db/db_logic.dart';
import 'package:take_a_pet/db/storage_repository.dart';
import 'package:take_a_pet/models/animal_profile.dart';
import 'package:take_a_pet/models/app_user.dart';
import 'package:take_a_pet/models/history.dart';
import 'package:take_a_pet/util/animal_profile_card.dart';
import 'package:take_a_pet/util/const.dart';
import 'package:take_a_pet/util/widgets.dart';


class Favorites extends StatefulWidget {

  Favorites({Key? key, required this.logic, required this.storage, required this.dataRepo}) : super(key: key);

  final DBLogic logic;
  final StorageRepository storage;
  final DataRepository dataRepo;

  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {

  AnimalProfile _animalProfile = AnimalProfile(id: "", type: "dog",
      breed: "pomeranian", name: "Lucy", age: 2, gender: "Female", size: "s",
      color: [], location: "Israel", createdAt: Timestamp.now(), creatorId: "user22",
      isAdopted: false, isDeleted: false, qualities: [], likesNum: 0);
  String _currentUserId = '';
  AppUser _currentUser = new AppUser(id: "", email: "", firstName: "", gender: "",
      favoriteProfilesIdList: [], createdProfilesIdList: [], historyData:
      History(labelsSearched: [], profilesId: [], animalsTypes: []));
  int _numCards = 0;
  List<String> _animalIdList = [];
  List<AnimalProfile> _animalsList = [];
  String _error = "";
  Flushbar _flushbarError = Flushbar(message: "",);

  @override
  void initState() {
    super.initState();
    _currentUserDetails();
  }

  Future<void> _currentUserDetails() async {
    try {
      _currentUserId = widget.logic.getCurrentUser()!.uid;
      _currentUser = await widget.logic.getUserById(_currentUserId);
      _animalIdList = _currentUser.getFavProfilesList();
      _numCards = _animalsList.length;
      _getAllAnimalsFromId();
    } catch (e) {
      _error = e.toString();
      _showError();
    }
  }

  Future<void> _update() async{
    try {
      _currentUser = await widget.logic.getUserById(_currentUserId);
      _animalIdList = _currentUser.getFavProfilesList();
      if (_numCards < _animalsList.length) {
        _numCards = _animalsList.length;
        _getAllAnimalsFromId();
      }
    } catch(e) {
      _error = "problem with updating";
      _error += e.toString();
      _showError();
    }
  }

  Future<void> _getAllAnimalsFromId() async {

    int len = _animalIdList.length;
    for(int i=0; i<len; i++) {
      var animalProf = await widget.dataRepo.getAnimalById(_animalIdList[i]);
      if (animalProf != null) {
        _animalsList.add(animalProf);
      }
    }
    setState(() {
      _numCards = _animalsList.length;
    });
  }

  void _showError() {
    if (_error != "") {
      _flushbarError = Flushbar(
        title:  "Error!",
        message:  _error,
        duration:  Duration(seconds: 5),
        backgroundColor: Colors.red,
      );
      _flushbarError.show(context);
    }
    _error = "";
  }

  Widget _createCard(index) {
    return AnimalProfileCard(animalProfile: _animalsList[index],
        storage: widget.storage,
        logic: widget.logic,
        dataRepo: widget.dataRepo,
        withEdit: false, key: new GlobalKey()
    );
  }

  @override
  Widget build(BuildContext context) {
    return
      WillPopScope(
      onWillPop: () => showExitPopup(context),
      child: AdminScaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Favorites'),
            backgroundColor: Colors.lightBlue,
            actions: [
              IconButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                        context, '/favorites');
                  },
                  icon: Icon(Icons.refresh)
              ),
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_forward)
              ),
            ],
          ),
          sideBar: buildSideBar(context),
          body: Container(
            //padding: const EdgeInsets.only(left: 30),
            //width: deviceWidth,
            child: Flexible(
              child: Align(
                alignment: Alignment.topCenter,
                child: ListView.builder(
                  shrinkWrap: true,
                  reverse: false,
                  itemCount: _numCards,
                  itemBuilder: (context, index) {
                    return _createCard(index);
                  },
                ),
              ),
            ),
          )

      ),
    );
  }
}