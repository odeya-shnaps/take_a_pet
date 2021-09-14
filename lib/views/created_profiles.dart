import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:take_a_pet/db/data_repository.dart';
import 'package:take_a_pet/db/db_logic.dart';
import 'package:take_a_pet/db/storage_repository.dart';
import 'package:take_a_pet/models/app_user.dart';
import 'package:take_a_pet/models/history.dart';
import 'package:take_a_pet/util/const.dart';
import 'package:take_a_pet/util/widgets.dart';
import 'package:take_a_pet/util/animal_profile_card.dart';
import 'package:take_a_pet/models/animal_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreatedProfiles extends StatefulWidget {

  CreatedProfiles({Key? key, required this.logic, required this.storage, required this.dataRepo}) : super(key: key);

  final DBLogic logic;
  final StorageRepository storage;
  final DataRepository dataRepo;

  @override
  _CreatedProfilesState createState() => _CreatedProfilesState();
}

class _CreatedProfilesState extends State<CreatedProfiles> {

  // AnimalProfile _animalProfile = AnimalProfile(id: "", type: "dog",
  //     breed: "pomeranian", name: "Lucy", age: 2, image: "", gender: "Female", size: "s",
  //     color: [], location: "Israel", createdAt: Timestamp.now(), creatorId: "user22",
  //     isAdopted: false, isDeleted: false, qualities: []);
  String _currentUserId = '';
  AppUser _currentUser = new AppUser(id: "", email: "", firstName: "", gender: "",
      favoriteProfilesIdList: [], createdProfilesIdList: [], historyData:
      History(labelsSearched: [], profilesId: [], animalsTypes: []));
  int _numCards = -1;
  List<String> _animalIdList = [];
  List<AnimalProfile> _animalsList = [];
  String _error = "";
  Flushbar _flushbarError = Flushbar(message: "",);

  @override
  void initState() {
    //print('init');
    _animalsList = [];
    _animalIdList = [];
    super.initState();
    _currentUserDetails();
    //print('DONE init: '+ _animalsList.length.toString());

  }

  Future<void> _currentUserDetails() async {
    try {
      _currentUserId = widget.logic.getCurrentUser()!.uid;
      _currentUser = await widget.logic.getUserById(_currentUserId);
      _animalIdList =  _currentUser.getCreatedProfilesIdList();
      _numCards = _animalIdList.length;
      await _getAllAnimalsFromId();
      //print('finish update list');
    } catch (e) {
      _error = e.toString();
      _showError();
    }
  }

  Future<void> _update() async{
    try {
      _currentUser = await widget.logic.getUserById(_currentUserId);
      _animalIdList = _currentUser.getCreatedProfilesIdList();
      if (_numCards < _animalsList.length) {
        _numCards = _animalsList.length;
        await _getAllAnimalsFromId();
      }
    } catch(e) {
      _error = "problem with updating";
      _error += e.toString();
      _showError();
    }
  }

  Future<void> _getAllAnimalsFromId() async {

    _animalsList = [];
    int len = _animalIdList.length;
    for(int i=0; i<len; i++) {
      var animalProf = await widget.dataRepo.getAnimalById(_animalIdList[i]);
      if (animalProf != null) {
        _animalsList.add(animalProf);
      }
    }

    _animalsList.sort((a,b) {
      return a.createdAt.compareTo(b.createdAt);
    });

    _animalsList = _animalsList.reversed.toList();


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
      withEdit: true, key: new GlobalKey()
    );
  }

  @override
  Widget build(BuildContext context) {

    return

      AdminScaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Created Profiles', style: TextStyle(fontSize: 15, color: Colors.white),),
            backgroundColor: Colors.lightBlue,
            actions: [
              IconButton(
                  onPressed: () {

                    Navigator.pushNamed(
                        context, '/animal_profile_create').then((_) => setState(() {
                      //_update();
                      _currentUserDetails();
                    }));

                  },
                  icon: Icon(Icons.add)
              ),
              IconButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                        context, '/created_profiles');
                  },
                  icon: Icon(Icons.refresh)
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
                child: _numCards == -1 ?
                Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: CircularProgressIndicator(color: Colors.orange,)
                ) :
                _numCards == 0 ? Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: Text('You have not created profiles yet...',
                    style: TextStyle(
                        color: Colors.amber[800],
                    fontSize: 16,
                        fontWeight: FontWeight.bold)),
                ) :
                ListView.builder(
                  shrinkWrap: true,
                  reverse: false,
                  itemCount: _numCards,
                  itemBuilder: (context, index) {
                    return _createCard(index);
                  },
                  addAutomaticKeepAlives: true,
                  //cacheExtent: _numCards,


                ),


              ),
            ),
          )

      );
    //);
  }
}