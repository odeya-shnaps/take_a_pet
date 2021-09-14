
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_compare/image_compare.dart';
import 'package:take_a_pet/db/data_repository.dart';
import 'package:take_a_pet/db/db_logic.dart';
import 'package:take_a_pet/db/storage_repository.dart';
import 'package:take_a_pet/models/animal_profile.dart';
import 'package:take_a_pet/models/app_user.dart';
import 'package:take_a_pet/views/Image_view.dart';
import 'package:take_a_pet/models/history.dart';
import 'package:take_a_pet/views/animal_profile_edit.dart';
import 'package:take_a_pet/views/animal_profile_view.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


class AnimalProfileCard extends StatefulWidget {
  AnimalProfileCard(
      {required this.animalProfile,
        required this.storage,
        required this.dataRepo,
        required this.logic,
        required this.withEdit,
        required this.key
      });
      //: super(key: key);

  AnimalProfile animalProfile;
  final StorageRepository storage;
  final DataRepository dataRepo;
  final DBLogic logic;
  final bool withEdit;
  //bool isDeleted = false;

  final GlobalKey<AnimalProfileCardState> key;

  // void setAsDeleted(){
  //   //print('here');
  //   //setState(() {
  //   isDeleted = true;
  //   createState();
  //   //});
  // }


  // fields of profile
  @override
  AnimalProfileCardState createState() => AnimalProfileCardState();

}

class AnimalProfileCardState extends State<AnimalProfileCard> with AutomaticKeepAliveClientMixin{
  Color _iconColor = Colors.black;
  IconData _icon = Icons.favorite_border;
  Image? _currentImage;
  String _error = "";
  String _currentUserId = '';
  AppUser _currentUser = new AppUser(id: "", email: "", firstName: "", gender: "",
      favoriteProfilesIdList: [], createdProfilesIdList: [], historyData:
      History(labelsSearched: [], profilesId: [], animalsTypes: []));
  Flushbar _flushbarError = Flushbar(message: "",);
  bool finishCreation = false;
  bool isLiked = false;

  final key = GlobalKey();

  bool isDeleted = false;
  bool isUpdated = true;

  late double _cardWidth;
  late double _cardHeight;





  void setAsDeleted(){
    setState((){
      isDeleted = true;
    });
  }

  void setAsUpdated() async {

    // getting the updated info from DB
    AnimalProfile? ap = await widget.dataRepo.getAnimalById(widget.animalProfile.id);
    if(ap !=null) {
      widget.animalProfile = ap;
    }

    setState((){
      isUpdated = true;
    });
  }

  // Future<void> checkIfImageUpdated() async {
  //   print('checkIfImageUpdated');
  //
  //
  //   Image? dbImage= await _retrievePicFromDB(save: false);
  //
  //   Image.
  //
  //   var assetResult = await compareImages(
  //       src1: _currentImage, src2: dbImage, algorithm: PixelMatching());
  //
  //   print('assetResult  '+ assetResult.toString());
  //
  //
  //   if(assetResult > 0.0) {
  //     print('Image changed');
  //     setState((){
  //       _currentImage = dbImage;
  //       print('updated here');
  //       isUpdated = true;
  //     });
  //   }
  //
  //
  // }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(isDeleted == false) {
      print('init');
      _currentUserDetails();
      _retrievePicFromDB();
      _checkIfLiked();
    }




  }

  @override
  void dispose() {
    // Clean up the controller and focus nodes when the Widget is disposed

    super.dispose();
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

  Future<void> _currentUserDetails() async {
    //print('IN');
    try {
    _currentUserId = widget.logic.getCurrentUser()!.uid;
    _currentUser = await widget.logic.getUserById(_currentUserId);
    // if that animal profile already in favorites display the icon in accordance.
    if (_currentUser.inFavProfilesList(widget.animalProfile.id)) {
      setState(() {
        _iconColor = Colors.red;
        _icon = Icons.favorite;
      });
    } else {
      setState(() {
        _iconColor = Colors.black;
        _icon = Icons.favorite_border;
      });
    }
    } catch (e) {
      _error = e.toString();
      _showError();
    }
  }


  Future<void> _retrievePicFromDB() async {
    //print('RETRIEVE');
    String fileName = widget.animalProfile.id;

    try {
      Image? currentProfileImage = await widget.storage.getImageFromStorage(fileName);
      //print(currentProfileImage);


      setState(() {
        _currentImage = currentProfileImage;
      });

    } catch (e) {
      _error = e.toString();
      _showError();
    }
  }

  // Future<Image?> _retrievePicFromDB({required bool save}) async {
  //   print('RETRIEVE');
  //   String fileName = widget.animalProfile.id;
  //
  //   try {
  //     Image? currentProfileImage = await widget.storage.getImageFromStorage(fileName);
  //     print(currentProfileImage);
  //
  //
  //     if(save) {
  //       setState(() {
  //         _currentImage = currentProfileImage;
  //       });
  //       return null;
  //     } else {
  //       return currentProfileImage;
  //     }
  //
  //
  //   } catch (e) {
  //     _error = e.toString();
  //     _showError();
  //   }
  // }

  void _checkIfLiked() {
    String profileId = widget.animalProfile.id;

    if (_currentUser.favoriteProfilesIdList.contains(profileId)) {
      setState(() {
        //print('liked');
        isLiked = true;
      });
    }
  }

  Future<void> _addToFavorites() async {
    try {
      // updating the favorite list - maybe other card also added to favorites
      //await _currentUserDetails();

      AppUser upUser = await widget.logic.getUserById(_currentUserId);
      if(upUser.getFavProfilesList() != _currentUser.getFavProfilesList()) {
        _currentUser = _currentUser.copyWith(favoriteProfilesIdList: upUser.favoriteProfilesIdList);
      }

      AnimalProfile newAnimalProf = widget.animalProfile.copyWith(likesNum: widget.animalProfile.getLikes()+1);

      _currentUser.addToFavProfilesList(newAnimalProf.id);

      await Future.wait([
        widget.logic.updateUserInfo(updatedUser: _currentUser),
        widget.dataRepo.updateAnimal(updatedAnimal: newAnimalProf)
      ]);

    } catch(e) {
      _error = e.toString();
      _showError();
    }
  }

  Future<void> _removeFromFavorites() async {
    try {

      AppUser upUser = await widget.logic.getUserById(_currentUserId);
      if(upUser.getFavProfilesList() != _currentUser.getFavProfilesList()) {
        _currentUser = _currentUser.copyWith(favoriteProfilesIdList: upUser.favoriteProfilesIdList);
      }

      AnimalProfile newAnimalProf = widget.animalProfile.copyWith(likesNum: widget.animalProfile.getLikes()-1);

      _currentUser.removeFromFavProfilesList(widget.animalProfile.id);

      await Future.wait([
        widget.logic.updateUserInfo(updatedUser: _currentUser),
        widget.dataRepo.updateAnimal(updatedAnimal: newAnimalProf)
      ]);

    } catch(e) {
      _error = e.toString();
      _showError();
    }
  }

  Future<void> _deleteAnimalProfile() async {
    try {
      await widget.logic.deleteAnimalProfile(animalId: widget.animalProfile.id, creatorId: widget.animalProfile.creatorId);
      setState(() {
        isDeleted = true;
      });
      _updateMatrix();
    } catch(e) {
      _error = e.toString();
      _showError();
    }
  }

  Future<void> _updateMatrix() async {
    Uri functionUrl = Uri.parse('https://europe-central2-take-a-pet.cloudfunctions.net/update-count-matrix');

    try {
      var response = await http.get(functionUrl);
      var status = response.statusCode;

      //print(status);


    } catch (e) {
      //print(e);
      _error = 'Problem with update matrix';
      _showError();
    }
  }



  Widget _addIcons() {
    return Row(
      children: [
        Column(
          children: [
            IconButton(
                onPressed: () {
                  // color the heart in red and add to favorites
                  setState(() {
                    if (_iconColor == Colors.black) {
                      _iconColor = Colors.red;
                      _icon = Icons.favorite;
                      //add to favorites
                      _addToFavorites();
                      isLiked = true;

                    } else {
                      _iconColor = Colors.black;
                      _icon = Icons.favorite_border;
                      //remove from favorites
                      _removeFromFavorites();
                      isLiked = false;

                    }
                  });
                },
                icon: Icon(_icon, color: _iconColor,)
            ),
            Text(widget.animalProfile.getLikes().toString() + ' Likes',
                style: TextStyle(fontSize: 12),
            )
          ]
        ),
        /*
        SizedBox(width: 40),
        Column(
            children: [
              IconButton(
                //padding: EdgeInsets.fromLTRB(5, 5, 5, 17),
                  onPressed: () {
                    // chat
                  },
                  icon: Icon(Icons.chat)
              ),
              Text('Contact',
                style: TextStyle(fontSize: 12),
              )
            ]
        ),*/
      ],
    );
  }

  Widget _addIconsWithEdit() {
    return Column(
      children: [
        Row(
            children: [
              Icon(Icons.favorite, color: Colors.red, size: 18,),
              SizedBox(width: 5),
              Text(widget.animalProfile.getLikes().toString() + ' Likes',
                style: TextStyle(fontSize: 14),
              )
            ]
        ),
        Row(
          children: [
            IconButton(
                onPressed: (!isDeleted) ? () {
                  //Navigator.of(context).pushNamed('/animal_profile_create');
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnimalProfileEdit(logic: widget.logic, storage: widget.storage, dataRepo: widget.dataRepo, animalProfile: widget.animalProfile,),
                      ));
                } : () {},
                icon: Icon(Icons.edit)
            ),
            IconButton(
                onPressed: (!isDeleted) ? () {
                  showDeleteWarning(context);
                } : () {},
                icon: Icon(Icons.delete)
            ),

          ],
        ),

      ]
    );
  }

  Widget _buildDetails(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Container(

      width: deviceSize.width/2 - 30,
      child: Column(
        children: [
          SizedBox(height: 5),
          Text(
              "${widget.animalProfile.name}",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
              ),
              overflow: TextOverflow.ellipsis,
            ),

          SizedBox(height: 15),
          Text("${widget.animalProfile.getBreed()}", overflow: TextOverflow.ellipsis,),
          SizedBox(height: 10),
          Text("${widget.animalProfile.gender}"),
          SizedBox(height: 10),
          Text("${widget.animalProfile.getStringAge()}"),
          SizedBox(height: 2),
          Divider(thickness: 3, color: Colors.grey[500],),
        ],
      ),
    );
  }

  Widget _buildProfile(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget> [
            Container(
                margin: EdgeInsets.fromLTRB(0, 5, 20, 5),
                width: _cardWidth/2- 25,
                height: _cardHeight * 0.80,
                // decoration: BoxDecoration(
                //   shape: BoxShape.rectangle,
                //   color: Colors.grey[400],
                // ),
                child: (_currentImage == null) // no image in db and no image selected
                    ? Icon(
                  Icons.pets,
                  size: 60,
                  color: Colors.white,
                )
                    : ClipRRect( // the pickedPicture
                  borderRadius: BorderRadius.circular(50),
                  child: FittedBox( // no selected image - showing the image in the DB
                    child: _currentImage,
                    fit: BoxFit.fill,
                  ),
                )
            ),

              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Created At:',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold
                    ),
                    overflow: TextOverflow.ellipsis,),
                  Text(createDateToView(),
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold
                    ),
                    overflow: TextOverflow.ellipsis,)
                ]

            ),

          ]
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildDetails(context),
            // SizedBox(height: 3),
            //SizedBox(height: 1,),
            widget.withEdit ? _addIconsWithEdit() : _addIcons(),
            SizedBox(height: 2,),
          ],
        )
      ],

    );
  }

  String createDateToView() {

    DateTime dt = widget.animalProfile.createdAt.toDate();
    String formattedDate = DateFormat('kk:mm , dd-MM-yyyy').format(dt);

    return formattedDate;


  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery
        .of(context)
        .size;

    _cardWidth = deviceSize.width - 20;
    _cardHeight = deviceSize.height / 3;

    return
    //   isDeleted
    //     ?
    // SizedBox()
    //     :
    Center(
      // child: Banner(
      //   message: isDeleted ? 'Deleted' : '',
      //   color: Colors.redAccent,
      //   location: BannerLocation.topStart,

        child: Stack(
          children: <Widget> [
            Card(
              color: Colors.orange[200],
              child: InkWell(
                  child: SizedBox(
                    width: _cardWidth,
                    height: _cardHeight,
                    child: _currentImage == null ?
                        Padding(
                          padding: EdgeInsets.fromLTRB(10,50,10,50),
                          child: Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,

                                  //margin: EdgeInsets.fromLTRB(deviceSize.width*0.2, deviceSize.height*0.16, deviceSize.width*0.2, deviceSize.height*0.16),
                                  child: SizedBox(
                                    height: _cardHeight * 0.06,
                                      width: _cardWidth * 0.5,
                                      child: LinearProgressIndicator(color: Colors.red, backgroundColor: Colors.orange[200], )
                                  ),
                              ),
                          ),
                        ) : isUpdated ? _buildProfile(context) : null,


                  ),
                  onTap: (!widget.withEdit) && (!isDeleted)? () async {
                    // add profile to history when clicked
                    _currentUser.setHistoryData(profileId: widget.animalProfile.id);
                    await widget.logic.updateUserInfo(updatedUser: _currentUser);
                    // push profile arguments, at list id or something
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AnimalProfileView(animalProfile: widget.animalProfile,
                                logic: widget.logic,
                                dataRepo: widget.dataRepo,
                                storage: widget.storage,),
                        )).then((_)  async {
                      await _currentUserDetails();
                      await _retrievePicFromDB();
                      _checkIfLiked();

                    } ); // the liked list may be changed
                  } : () {} // if edit (from created profiles view - do nothing, because there is an edit button),
              ),
            ),
            if (isDeleted)
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: RotationTransition(
                    turns: new AlwaysStoppedAnimation(-20 / 360),
                    child: Container(
                      width: _cardWidth * 0.8,
                      height: _cardHeight * 0.17,
                      //padding: EdgeInsets.fromLTRB(cardWidth * 0.05, 10, cardWidth * 0.2, 10),
                      decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.7),
                          borderRadius: BorderRadius.all(Radius.circular(20))
                      ),
                      child: Center(child: Text("Deleted", textAlign: TextAlign.center)),
                      //color: Colors.redAccent.withOpacity(0.5)

                    ),
                  ),

                ),
              )

          ]
        ),
      //),
    );
  }

  Future<bool> showDeleteWarning(context) async{
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              height: 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Delete animal?"),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _deleteAnimalProfile();
                            Navigator.of(context).pop();
                          },
                          child: Text("Yes"),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.red[400]),
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              // doing nothing
                            },
                            child: Text("No", style: TextStyle(color: Colors.black)),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green[300],
                            ),
                          ))
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;


}