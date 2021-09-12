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

class HomeProfiles extends StatefulWidget {

  HomeProfiles({Key? key, required this.logic, required this.storage, required this.dataRepo}) : super(key: key);

  final DBLogic logic;
  final StorageRepository storage;
  final DataRepository dataRepo;

  @override
  _HomeProfilesState createState() => _HomeProfilesState();
}

class _HomeProfilesState extends State<HomeProfiles> {



  // list of animalsProfiles in FEED
  List<AnimalProfile> _animalsProfilesFeed = [];

  // cards in FEED
  List<AnimalProfileCard> feedCards = [];

  // widget to be presented
  Widget prev = Container(child: Text('Loading'));


  @override
  void initState() {
    super.initState();
    // _currentUserDetails();
    //_getinitialFeed();
    //build(context);
    print('DONE2');
  }

  Future<void> _getinitialFeed() async{
    print('_getinitialFeed');
    _animalsProfilesFeed = await widget.dataRepo.getFeed();

    if(_animalsProfilesFeed.length == 0){
      prev = Text('No Profiles');
    }else {
      prev = ListView.builder(
        reverse: false,
        shrinkWrap: true,
        itemCount: _animalsProfilesFeed.length,
        itemBuilder: (BuildContext context, int index) {
          var animalCard = AnimalProfileCard(
              animalProfile: _animalsProfilesFeed[index],
              storage: widget.storage,
              logic: widget.logic,
              dataRepo: widget.dataRepo,
              withEdit: false, key: new GlobalKey());
          feedCards.add(animalCard);
          return animalCard;
        },
        addAutomaticKeepAlives: true,

      );
    }



    print('DONE1');

  }

  void _checkIfDeleted(List<AnimalProfile>? newFeed) {
    List<String> newFeedIds = [];
    newFeed!.forEach((element) {
      newFeedIds.add(element.id);
    });

    feedCards.forEach((animal) {
      // the new list does not contain the item in prevFeed
      bool ifExists = newFeedIds.contains(animal.animalProfile.id);
      if(ifExists == false) {
        print('DELETED '+ animal.animalProfile.name);

        animal.key.currentState!.setAsDeleted();

      } else {
        int index = newFeedIds.indexOf(animal.animalProfile.id);
        // check if updated
        if(animal.animalProfile != newFeed[index]) {
          // the animal has updated details
          animal.key.currentState!.setAsUpdated();

        }
      }

    });

  }

  void _checkIfAdded(List<AnimalProfile>? newFeed) {
    List<String> feedIds = [];
    _animalsProfilesFeed.forEach((element) {
      feedIds.add(element.id);
    });

    newFeed!.forEach((animal) {
      // the new list does not contain the item in prevFeed
      bool ifExists = feedIds.contains(animal.id);
      print('IF ' + animal.name+'  '+ ifExists.toString());

      if(ifExists == false) {
        print('ADDED ' + animal.name);

        //animal.key.currentState!.setAsDeleted();
      }
      // } else {
      //   int index = newFeedIds.indexOf(animal.animalProfile.id);
      //   // check if updated
      //   if(animal.animalProfile != newFeed[index]) {
      //     // the animal has updated details
      //     animal.key.currentState!.setAsUpdated();
      //
      //   }
      // }

    });

  }


  @override
  Widget build(BuildContext context) {

    return
      FutureBuilder(
        future: _getinitialFeed(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          return WillPopScope(
            onWillPop: () => showExitPopup(context),
            child:
            AdminScaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  title: const Text('Feed', style: TextStyle(fontSize: 17),),
                  backgroundColor: Colors.lightBlue,
                  actions: [
                    IconButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, '/home_profiles.dart');
                        },
                        icon: Icon(Icons.refresh)
                    ),
                    IconButton(
                        onPressed: () {
                          showExitPopup(context);

                          // Navigator.of(context).pushNamedAndRemoveUntil(
                          //     '/login', (Route<dynamic> route) => false);
                        },
                        icon: Icon(Icons.logout)
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
                      child: StreamBuilder<List<AnimalProfile>?>(
                          stream: widget.dataRepo.getAnimalsList(),
                          initialData: [],
                          builder: (BuildContext context,
                              AsyncSnapshot<List<AnimalProfile>?> snapshot) {
                            //List<Widget> cards = [];
                            if (snapshot.hasError) {
                              return Column(
                                  children: <Widget>[
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 60,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: Text('Error: ${snapshot.error}'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text('Stack trace: ${snapshot.stackTrace}'),
                                    ),
                                  ]
                              );
                            }
                            if (!snapshot.hasData) {
                              return Container();
                            }

                            List<AnimalProfile>? list = snapshot.data;

                            //List<AnimalProfileCard> newFeed = [];

                            // list!.forEach((animal) {
                            //   var animalCard = AnimalProfileCard(
                            //       animalProfile: animal,
                            //       storage: widget.storage,
                            //       logic: widget.logic,
                            //       dataRepo: widget.dataRepo,
                            //       withEdit: false);
                            //   newFeed.add(animalCard);
                            // });

                            // var newFeed = ListView.builder(
                            //   reverse: false,
                            //   shrinkWrap: true,
                            //   itemCount: list!.length,
                            //   itemBuilder: (BuildContext context, int index) {
                            //     var animalCard = AnimalProfileCard(
                            //         animalProfile: list![index],
                            //         storage: widget.storage,
                            //         logic: widget.logic,
                            //         dataRepo: widget.dataRepo,
                            //         withEdit: false);
                            //     feed.add(animalCard);
                            //     return animalCard;
                            //   },
                            //
                            //
                            // );

                            _checkIfDeleted(list);
                            _checkIfAdded(list);

                            // if(list!.length > _animalsList!.length || _animalsList!.length == 0){
                            //   _animalsList = list;
                            //   prev = ListView.builder(
                            //     reverse: false,
                            //     shrinkWrap: true,
                            //     itemCount: list.length,
                            //     itemBuilder: (BuildContext context, int index) {
                            //       return AnimalProfileCard(
                            //           animalProfile: list[index],
                            //           storage: widget.storage,
                            //           logic: widget.logic,
                            //           dataRepo: widget.dataRepo,
                            //           withEdit: false);
                            //     },
                            //
                            //
                            //   );
                            // }

                            return prev;


                          }
                      ),
                    ),
                  ),
                )

            ),
          );
        },

      );
  }
}