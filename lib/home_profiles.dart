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

  final List<Flushbar> flushBars = [];


  // list of animalsProfiles in FEED
  List<AnimalProfile> _animalsProfilesFeed = [];

  // cards in FEED
  List<AnimalProfileCard> feedCards = [];

  // widget to be presented
  Widget prev = Container(child: Text('Loading'));

  bool initialFeed = true;


  @override
  void initState() {
    super.initState();
    // _currentUserDetails();
    //_getinitialFeed();
    //build(context);
    print('DONE2');
  }


  void showDismissSnackBar(BuildContext context, String message) => show(
    context,
    Flushbar(
      icon: Icon(Icons.add_alarm, size: 15, color: Colors.white),
      shouldIconPulse: false,
      //title: 'Title',
      message: message,
      mainButton: ElevatedButton(
        style:
        ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.brown),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    //side: BorderSide(color: Colors.brown)
                )
            ),


        ),

        // ElevatedButton.styleFrom(
        //   primary: Colors.brown,
        //
        // ),
        child: Text(
          'Refresh\n feed',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
        onPressed: () {
          Navigator.pushReplacementNamed(
              context, '/home_profiles.dart');
        },
      ),
      flushbarPosition: FlushbarPosition.TOP,
      margin: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width*0.1, kToolbarHeight, MediaQuery.of(context).size.width*0.1, 0),
      borderRadius: BorderRadius.all(Radius.circular(20)),
      backgroundColor: Colors.redAccent.withOpacity(0.7),
      barBlur: 20,
      padding: EdgeInsets.all(16),
      animationDuration: Duration(microseconds: 5),
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
    ),
  );

  Future show(BuildContext context, Flushbar newFlushBar) async {
    await Future.wait(flushBars.map((flushBar) => flushBar.dismiss()).toList());
    flushBars.clear();

    newFlushBar.show(context);
    flushBars.add(newFlushBar);
  }

  Future<bool> _getInitialFeed() async{
    setState(() {
      print('setting true');
      initialFeed = true;
    });

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

    return true;

  }

  void _checkIfDeleted(List<AnimalProfile>? newFeed) {
    List<String> newFeedIds = [];
    if(newFeed !=null) {
      newFeed.forEach((element) {
        newFeedIds.add(element.id);
      });


      feedCards.forEach((animal) {
        // the new list does not contain the item in prevFeed
        bool ifExists = newFeedIds.contains(animal.animalProfile.id);

        AnimalProfileCardState? state = animal.key.currentState;

        if(state != null) {
          if (ifExists == false) {
            print('DELETED ' + animal.animalProfile.name);

            animal.key.currentState!.setAsDeleted();
          } else {
            int index = newFeedIds.indexOf(animal.animalProfile.id);
            // check if Updated
            if (animal.animalProfile != newFeed[index]) {
              // the animal has updated details
              print('updated');
              animal.key.currentState!.setAsUpdated();
            }

          }
        }

      });
    }
  }

  void _checkIfAdded(List<AnimalProfile>? newFeed, BuildContext context) {
    var newItems = 0;
    List<String> feedIds = [];
    _animalsProfilesFeed.forEach((element) {
      feedIds.add(element.id);
    });

    if(newFeed!=null) {
      newFeed.forEach((animal) {
        // the prevFeed does not contain the item in new list
        bool ifExists = feedIds.contains(animal.id);
        print('IF ' + animal.name+'  '+ ifExists.toString());

        if(ifExists == false) {
          print('ADDED ' + animal.name);

          newItems++;
          //animal.key.currentState!.setAsDeleted();
        }
      });
    }

    if(newItems > 0) {
      var message = newItems.toString()+' new profiles added';
      print('iemsNum  '+ newItems.toString());
      print('show snack');
      showDismissSnackBar(context, message);



    }


  }


  @override
  Widget build(BuildContext context) {

    return
      FutureBuilder(
        future: _getInitialFeed(),
          builder: (context, AsyncSnapshot<bool> snapshot) {

              return WillPopScope(
                onWillPop: () => showExitPopup(context),
                child: AdminScaffold(
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
                      ],
                    ),
                    sideBar: buildSideBar(context),
                    body: (snapshot.hasData) ? Container(
                      //padding: const EdgeInsets.only(left: 30),
                      //width: deviceWidth,
                      child:  Flexible(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child:  StreamBuilder<List<AnimalProfile>?>(
                              stream: widget.dataRepo.getAnimalsList(),
                              initialData: _animalsProfilesFeed,
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

                                print(_animalsProfilesFeed);
                                print(_animalsProfilesFeed.length);

                                  _checkIfDeleted(list);
                                  _checkIfAdded(list, context);

                                return prev;

                              }
                          )
                        ),
                      )
                    ): Center(
                      child: SizedBox(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator(),
                      ),
                    ),

                ),
              );


          // return WillPopScope(
          //   onWillPop: () => showExitPopup(context),
          //   child:
          //   AdminScaffold(
          //       backgroundColor: Colors.white,
          //       appBar: AppBar(
          //         title: const Text('Feed', style: TextStyle(fontSize: 17),),
          //         backgroundColor: Colors.lightBlue,
          //         actions: [
          //           IconButton(
          //               onPressed: () {
          //                 Navigator.pushReplacementNamed(
          //                     context, '/home_profiles.dart');
          //               },
          //               icon: Icon(Icons.refresh)
          //           ),
          //           IconButton(
          //               onPressed: () {
          //                 showExitPopup(context);
          //
          //                 // Navigator.of(context).pushNamedAndRemoveUntil(
          //                 //     '/login', (Route<dynamic> route) => false);
          //               },
          //               icon: Icon(Icons.logout)
          //           ),
          //         ],
          //       ),
          //       sideBar: buildSideBar(context),
          //       body: Container(
          //         //padding: const EdgeInsets.only(left: 30),
          //         //width: deviceWidth,
          //         child: Flexible(
          //           child: Align(
          //             alignment: Alignment.topCenter,
          //             child: StreamBuilder<List<AnimalProfile>?>(
          //                 stream: widget.dataRepo.getAnimalsList(),
          //                 initialData: _animalsProfilesFeed,
          //                 builder: (BuildContext context,
          //                     AsyncSnapshot<List<AnimalProfile>?> snapshot) {
          //                   //List<Widget> cards = [];
          //                   if (snapshot.hasError) {
          //                     return Column(
          //                         children: <Widget>[
          //                           const Icon(
          //                             Icons.error_outline,
          //                             color: Colors.red,
          //                             size: 60,
          //                           ),
          //                           Padding(
          //                             padding: const EdgeInsets.only(top: 16),
          //                             child: Text('Error: ${snapshot.error}'),
          //                           ),
          //                           Padding(
          //                             padding: const EdgeInsets.only(top: 8),
          //                             child: Text('Stack trace: ${snapshot.stackTrace}'),
          //                           ),
          //                         ]
          //                     );
          //                   }
          //                   if (!snapshot.hasData) {
          //                     return Container();
          //                   }
          //
          //                   List<AnimalProfile>? list = snapshot.data;
          //
          //                   print(_animalsProfilesFeed);
          //                   print(_animalsProfilesFeed.length);
          //                   //List<AnimalProfileCard> newFeed = [];
          //
          //                   // list!.forEach((animal) {
          //                   //   var animalCard = AnimalProfileCard(
          //                   //       animalProfile: animal,
          //                   //       storage: widget.storage,
          //                   //       logic: widget.logic,
          //                   //       dataRepo: widget.dataRepo,
          //                   //       withEdit: false);
          //                   //   newFeed.add(animalCard);
          //                   // });
          //
          //                   // var newFeed = ListView.builder(
          //                   //   reverse: false,
          //                   //   shrinkWrap: true,
          //                   //   itemCount: list!.length,
          //                   //   itemBuilder: (BuildContext context, int index) {
          //                   //     var animalCard = AnimalProfileCard(
          //                   //         animalProfile: list![index],
          //                   //         storage: widget.storage,
          //                   //         logic: widget.logic,
          //                   //         dataRepo: widget.dataRepo,
          //                   //         withEdit: false);
          //                   //     feed.add(animalCard);
          //                   //     return animalCard;
          //                   //   },
          //                   //
          //                   //
          //                   // );
          //
          //                   // if(!initialFeed) {
          //                   //   print('not initail');
          //                     _checkIfDeleted(list);
          //                     _checkIfAdded(list, context);
          //                  // } else {
          //                  //   print('yes initaial');
          //                   //  initialFeed = false;
          //                  // }
          //
          //                   return prev;
          //
          //
          //                 }
          //             ),
          //           ),
          //         ),
          //       )
          //
          //   ),
          // );
        },

      );
  }
}


// Widget build(BuildContext context) {
//
//   return
//     FutureBuilder(
//       future: _getInitialFeed(),
//       builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
//         return WillPopScope(
//           onWillPop: () => showExitPopup(context),
//           child:
//           AdminScaffold(
//               backgroundColor: Colors.white,
//               appBar: AppBar(
//                 title: const Text('Feed', style: TextStyle(fontSize: 17),),
//                 backgroundColor: Colors.lightBlue,
//                 actions: [
//                   IconButton(
//                       onPressed: () {
//                         Navigator.pushReplacementNamed(
//                             context, '/home_profiles.dart');
//                       },
//                       icon: Icon(Icons.refresh)
//                   ),
//                   IconButton(
//                       onPressed: () {
//                         showExitPopup(context);
//
//                         // Navigator.of(context).pushNamedAndRemoveUntil(
//                         //     '/login', (Route<dynamic> route) => false);
//                       },
//                       icon: Icon(Icons.logout)
//                   ),
//                 ],
//               ),
//               sideBar: buildSideBar(context),
//               body: Container(
//                 //padding: const EdgeInsets.only(left: 30),
//                 //width: deviceWidth,
//                 child: Flexible(
//                   child: Align(
//                     alignment: Alignment.topCenter,
//                     child: Stack(
//                         children:[
//                           prev,
//                           StreamBuilder<List<AnimalProfile>?>(
//                               stream: widget.dataRepo.getAnimalsList(),
//                               initialData: [],
//                               builder: (BuildContext context,
//                                   AsyncSnapshot<List<AnimalProfile>?> snapshot) {
//                                 //List<Widget> cards = [];
//                                 if (snapshot.hasError) {
//                                   return Column(
//                                       children: <Widget>[
//                                         const Icon(
//                                           Icons.error_outline,
//                                           color: Colors.red,
//                                           size: 60,
//                                         ),
//                                         Padding(
//                                           padding: const EdgeInsets.only(top: 16),
//                                           child: Text('Error: ${snapshot.error}'),
//                                         ),
//                                         Padding(
//                                           padding: const EdgeInsets.only(top: 8),
//                                           child: Text('Stack trace: ${snapshot.stackTrace}'),
//                                         ),
//                                       ]
//                                   );
//                                 }
//                                 if (!snapshot.hasData) {
//                                   return Container();
//                                 }
//
//                                 List<AnimalProfile>? list = snapshot.data;
//
//                                 //List<AnimalProfileCard> newFeed = [];
//
//                                 // list!.forEach((animal) {
//                                 //   var animalCard = AnimalProfileCard(
//                                 //       animalProfile: animal,
//                                 //       storage: widget.storage,
//                                 //       logic: widget.logic,
//                                 //       dataRepo: widget.dataRepo,
//                                 //       withEdit: false);
//                                 //   newFeed.add(animalCard);
//                                 // });
//
//                                 // var newFeed = ListView.builder(
//                                 //   reverse: false,
//                                 //   shrinkWrap: true,
//                                 //   itemCount: list!.length,
//                                 //   itemBuilder: (BuildContext context, int index) {
//                                 //     var animalCard = AnimalProfileCard(
//                                 //         animalProfile: list![index],
//                                 //         storage: widget.storage,
//                                 //         logic: widget.logic,
//                                 //         dataRepo: widget.dataRepo,
//                                 //         withEdit: false);
//                                 //     feed.add(animalCard);
//                                 //     return animalCard;
//                                 //   },
//                                 //
//                                 //
//                                 // );
//
//                                 _checkIfDeleted(list);
//                                 _checkIfAdded(list, context);
//
//
//                                 return Container();
//
//                               }
//                           ),
//                         ]
//                     ),
//                   ),
//                 ),
//               )
//
//           ),
//         );
//       },
//
//     );
// }
