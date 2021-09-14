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

  Icon _icon = new Icon(
    Icons.search,
    color: Colors.white,
  );

  bool _isSearching = false;
  String _searchText = "";

  List<String> _searchOptions =[];

  final TextEditingController _controller = new TextEditingController();

  List<int> searchResultIndexes = [];

  Widget _appBarTitle = const Text('Created Profiles', style: TextStyle(fontSize: 15, color: Colors.white),);


  @override
  void initState() {
    print('init');
    _animalsList = [];
    _animalIdList = [];
    super.initState();
    _currentUserDetails();

    _controller.addListener(() {
      if (_controller.text.isEmpty) {
        setState(() {
          _isSearching = false;
          _searchText = "";
        });
      } else {
        setState(() {
          _isSearching = true;
          _searchText = _controller.text;
        });
      }
    });
  }

  void getNames() {

    _animalsList.forEach((element) {
      _searchOptions.add(element.name);
    });

  }


  Future<void> _currentUserDetails() async {
    try {
      _currentUserId = widget.logic.getCurrentUser()!.uid;
      _currentUser = await widget.logic.getUserById(_currentUserId);
      _animalIdList =  _currentUser.getCreatedProfilesIdList();
      _numCards = _animalIdList.length;
      await _getAllAnimalsFromId();
      print('finish update list');
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


  void _handleSearchStart() async{
    getNames();

    setState(() {
      _isSearching = true;
    });
  }

  // void _handleSearchEnd() async {
  //   //await _currentUserDetails();
  //
  //   setState(() {
  //     _icon = new Icon(
  //       Icons.search,
  //       color: Colors.white,
  //     );
  //     _appBarTitle = const Text('Created Profiles', style: TextStyle(fontSize: 15, color: Colors.white),);
  //     _isSearching = false;
  //     _controller.clear();
  //     // all animals created
  //     print('numcards '+_numCards.toString());
  //     _numCards = _animalIdList.length;
  //
  //   });
  // }

  void searchOperation(String searchText) {
    _numCards = 0;
    searchResultIndexes.clear();
    if (_isSearching) {
      for (int i = 0; i < _animalsList.length; i++) {
        String data = _animalsList[i].name;
        // the animal name contains the name typed by user
        if (data.toLowerCase().contains(searchText.toLowerCase())) {
          searchResultIndexes.add(i);
          _numCards+=1;
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {

    return

      AdminScaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: _appBarTitle,
            backgroundColor: Colors.lightBlue,
            actions: [
              IconButton(
                onPressed: () {
                  setState(() async {
                    if (_icon.icon == Icons.search) {
                      _icon = new Icon(
                        Icons.close,
                        color: Colors.white,
                      );
                      _appBarTitle = new TextField(
                        controller: _controller,
                        style: new TextStyle(
                          color: Colors.white,
                        ),
                        decoration: new InputDecoration(
                            prefixIcon: new Icon(Icons.search, color: Colors.white),
                            hintText: "Type a name",
                            hintStyle: new TextStyle(color: Colors.white)),
                        onChanged: searchOperation,
                      );

                      _handleSearchStart();
                    } else {
                      Navigator.pushReplacementNamed(
                          context, '/created_profiles');
                    }
                  });
                },
                icon: _icon,
              ),
              if(!_isSearching)
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
              if(!_isSearching)
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
                  child: _isSearching ?
                  Text('We couldn\'t find this name\nin the animals you posted',
                      style: TextStyle(
                          color: Colors.red[800],
                          fontSize: 16,
                          fontWeight: FontWeight.bold))
                      :
                  Text('You have not created profiles yet...',
                      style: TextStyle(
                          color: Colors.amber[800],
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ) :
                searchResultIndexes.length != 0 || _controller.text.isNotEmpty ?
                ListView.builder(
                  shrinkWrap: true,
                  reverse: false,
                  itemCount: _numCards,
                  itemBuilder: (context, index) {
                    return _createCard(searchResultIndexes[index]);
                  },
                  addAutomaticKeepAlives: true,
                  //cacheExtent: _numCards,


                )
                // no search - presenting all profiles
                    :ListView.builder(
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