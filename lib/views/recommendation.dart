import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:take_a_pet/db/data_repository.dart';
import 'package:take_a_pet/db/db_logic.dart';
import 'package:take_a_pet/db/storage_repository.dart';
import 'package:take_a_pet/models/animal_profile.dart';
import 'package:take_a_pet/models/app_user.dart';
import 'package:take_a_pet/util/animal_profile_card.dart';
import 'package:take_a_pet/util/const.dart';
import 'package:take_a_pet/util/widgets.dart';
import 'package:take_a_pet/models/history.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';


class Recommendation extends StatefulWidget {

  Recommendation({Key? key, required this.logic, required this.storage, required this.dataRepo}) : super(key: key);

  final DBLogic logic;
  final StorageRepository storage;
  final DataRepository dataRepo;

  @override
  _RecommendationState createState() => _RecommendationState();
}

class _RecommendationState extends State<Recommendation> {

  String _currentUserId = '';
  AppUser _currentUser = new AppUser(id: "",
      email: "",
      firstName: "",
      gender: "",
      favoriteProfilesIdList: [],
      createdProfilesIdList: [],
      historyData:
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
    _getRecommendation();
  }

  Future<void> _getRecommendation() async {
    // get data from algo
    _animalIdList = [];
    _numCards = _animalsList.length;
    _getAllAnimalsFromId();
  }

  Future<void> _currentUserDetails() async {
    try {
      _currentUserId = widget.logic.getCurrentUser()!.uid;
      _currentUser = await widget.logic.getUserById(_currentUserId);
    } catch (e) {
      _error = e.toString();
      _showError();
    }
  }

  Future<void> _getAllAnimalsFromId() async {
    int len = _animalIdList.length;
    for (int i = 0; i < len; i++) {
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
        title: "Error!",
        message: _error,
        duration: Duration(seconds: 5),
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
      child:
      AdminScaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Recommendations', style: TextStyle(fontSize: 15, color: Colors.white),),
            backgroundColor: Colors.lightBlue,
            actions: [
              IconButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                        context, '/recommendation');
                  },
                  icon: Icon(Icons.refresh)
              ),
              // IconButton(
              //     onPressed: () {
              //       Navigator.pop(context);
              //     },
              //     icon: Icon(Icons.arrow_forward)
              // ),
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
                  reverse: true,
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

  /*
  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      appBar: AppBar(
        title: const Text('Recommendation'),
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                    context, '/recommendation');
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
        body: Container(),
    );
  }
}*/