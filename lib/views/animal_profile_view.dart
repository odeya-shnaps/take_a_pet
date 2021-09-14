
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:take_a_pet/db/data_repository.dart';
import 'package:take_a_pet/models/animal_profile.dart';
import 'package:take_a_pet/util/widgets.dart';
import 'package:take_a_pet/db/db_logic.dart';
import 'package:take_a_pet/models/app_user.dart';
import 'package:take_a_pet/models/history.dart';
import 'package:take_a_pet/views/Image_view.dart';
import 'package:take_a_pet/db/storage_repository.dart';
import 'package:take_a_pet/views/user_profile_view.dart';
import 'package:color/color.dart' as SPColor;


class AnimalProfileView extends StatefulWidget {

  AnimalProfileView({Key? key, required this.logic, required this.storage, required this.dataRepo, required this.animalProfile,}) : super(key: key);

  final DBLogic logic;
  final StorageRepository storage;
  final DataRepository dataRepo;
  final AnimalProfile animalProfile;

  @override
  _AnimalProfileViewState createState() => _AnimalProfileViewState();
}

class _AnimalProfileViewState extends State<AnimalProfileView> {

  bool _isEmpty = false;
  String _animalId = "";
  late AnimalProfile _currentAnimal;
  String _currentUserId = '';
  AppUser _currentUser = new AppUser(id: "", email: "", firstName: "", gender: "",
      favoriteProfilesIdList: [], createdProfilesIdList: [], historyData:
      History(labelsSearched: [], profilesId: [], animalsTypes: []));
  String _error = "";
  Image? _currentImageInDB;
  Flushbar _flushbarError = Flushbar(message: "",);
  Color _iconColor = Colors.black;
  IconData _icon = Icons.favorite_border;
  Image? _creatorImage;

  @override
  void initState() {
    super.initState();
    // get current user's details, and creator id.
    _currentAnimal = widget.animalProfile;
    _getDetails();
    _retrieveAnimalPicFromDB();
    _retrieveCreatorPicFromDB();
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

  String _getStringFromList(List<String> list) {
    String str = "";
    list.forEach((element) {
      if (element != " " || element != '\n') {
        str = str + element + "\n";
      }
    });
    return str;
  }

  Future<void> _getDetails() async {
    try {
      _animalId = widget.animalProfile.id;
      _currentUserId = widget.logic.getCurrentUser()!.uid;
      _currentUser = await widget.logic.getUserById(_currentUserId);
      if (_currentUser.inFavProfilesList(widget.animalProfile.id)) {
        _iconColor = Colors.red;
        _icon = Icons.favorite;
      }
    } catch (e) {
      _error = e.toString();
      _showError();
    }
  }

  Future<void> _retrieveCreatorPicFromDB() async {
    String fileName = widget.animalProfile.creatorId;

    try {
      Image? currentProfileImage = await widget.storage.getImageFromStorage(fileName);

      setState(() {
        _creatorImage = currentProfileImage;
      });

    } catch (e) {
      _error = e.toString();
      _showError();
    }
  }

  Future<void> _retrieveAnimalPicFromDB() async {

    String fileName = _animalId;

    try {
      Image? currentProfileImage = await widget.storage.getImageFromStorage(fileName);

      setState(() {
        _currentImageInDB = currentProfileImage;
      });

    } catch (e) {
      _error = e.toString();
      _showError();
    }
  }

  Widget _createProfileImage() {
    return Container(
      height: 170.0,
      color: Colors.white,
      child: InkWell(
        child: Center(
          child: Container(
            width: 170.0,
            height: 170.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[400],
            ),
            child: (_currentImageInDB == null) // no image in db and no image selected
                ? Icon(
              Icons.pets,
              size: 130,
              color: Colors.white,
            )
                : ClipRRect( // the pickedPicture
                borderRadius: BorderRadius.circular(50),
                child: FittedBox( // no selected image - showing the image in the DB
                  child: _currentImageInDB,
                  fit: BoxFit.fill,
                )
            ),
          ),
        ),
        onTap: () {
          if (_currentImageInDB != null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ImageView(
                        imageFromDB: _currentImageInDB,
                        forEdit: false,),
                ));
          }
        },
      ),
    );
  }

  Future<void> _addToFavorites() async {
    try {
      AnimalProfile newAnimalProf = widget.animalProfile.copyWith(likesNum: widget.animalProfile.getLikes()+1);

      _currentUser.addToFavProfilesList(newAnimalProf.id);

      await Future.wait([
        widget.logic.updateUserInfo(updatedUser: _currentUser),
        widget.dataRepo.updateAnimal(updatedAnimal: newAnimalProf)
      ]);

      // _currentUser.addToFavProfilesList(widget.animalProfile.id);
      // await widget.logic.updateUserInfo(updatedUser: _currentUser);
    } catch(e) {
      _error = e.toString();
      _showError();
    }
  }

  Future<void> _removeFromFavorites() async {
    try {

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

  Widget _getIconsRow() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(width: 0),

          Column(
            children: <Widget> [
              IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserProfileView(userId: _currentAnimal.creatorId,
                                logic: widget.logic,
                                storage: widget.storage),
                      ));
                },
                icon: Icon(Icons.account_circle),
                iconSize: 30,
              ),
              SizedBox(height: 5),
              Text('Owner')
            ],
          ),
          SizedBox(width: 10),
          Column(
              children: <Widget> [
                IconButton(
                  onPressed: () {
                    // color the heart in red and add to favorites
                    setState(() {
                      if (_iconColor == Colors.black) {
                        _iconColor = Colors.red;
                        _icon = Icons.favorite;
                        //add to favorites
                        _addToFavorites();
                      } else {
                        _iconColor = Colors.black;
                        _icon = Icons.favorite_border;
                        //remove from favorites
                        _removeFromFavorites();
                      }
                    });
                  },
                  icon: Icon(_icon, color: _iconColor,),
                  iconSize: 30,
                ),
                SizedBox(height: 5),
                Text('Like')
              ]
          ),
          /*
          SizedBox(width: 10,),
          Column(
            children: <Widget> [
              IconButton(
                onPressed: () {
                  // chat
                },
                icon: Icon(Icons.chat),
                iconSize: 30,
              ),
              Text('Direct\n message', textAlign: TextAlign.center,)
            ],
          ),*/
        ],
      ),
    );
  }



  Widget _createRow(String? t, String toolTip, Icon icon, bool isAge, bool isSize) {
    _isEmpty = false;
    if (t == null || t == "") {
      _isEmpty = true;
      return SizedBox();
    }
    String text = t;
    if (isSize) {
      switch(text) {
      //case 'XS' : text = "Extra small"; break;
        case 'S' : text = "Small"; break;
        case 'M' : text = "Medium"; break;
        case 'L' : text = "Large"; break;
      //case 'XL' : text = "Extra large"; break;
      //case 'XXL' : text = "Extra extra large"; break;
      }
    }

    return Row(
      // crossAxisAlignment: CrossAxisAlignment.start,
      // mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          icon: icon,
          tooltip: toolTip,
          onPressed: () {},
        ),
        SizedBox(width: 10,),
        Flexible(
          child: Text(
              text,
              style: TextStyle(
                fontSize: 16.0,
                //fontWeight: FontWeight.bold
              )
          ),
        )
      ],
    );
  }

  Widget _createTitleRow(String? t, Icon icon, String title) {
    _isEmpty = false;
    if (t == null || t == "") {
      _isEmpty = true;
      return SizedBox();
    }
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 20),
      child: Row(

        children: [
          icon,
          SizedBox(width: 20,),
          Text(
              title,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,

              )
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {


    return AdminScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Animal Profile'),
        backgroundColor: Colors.lightBlue,
        actions: [
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
        color: Colors.white,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(30, 15.0, 30, 30),
          children: <Widget>[
            Text(_currentAnimal.name, textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 25)),
            SizedBox(height: 10),
            _createProfileImage(),
            SizedBox(height: 20),
            _getIconsRow(),
            Padding(padding: EdgeInsets.only(left: 0, right: 0),
              child: Divider(thickness: 3),
            ),

            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.only(left: 0),
              child: Text (
                'Pet Information',
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.only(left: 10, right: 20),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //_createRow(_currentAnimal.name, Icon(Icons.pets, color: Colors.orange[600],), false, false),
                  //_isEmpty ? SizedBox() : SizedBox(height: 20),
                  _createRow(_currentAnimal.type, 'Type', Icon(Icons.widgets_outlined, color: Colors.orange[600],), false, false),
                  _isEmpty ? SizedBox() : SizedBox(height: 10),
                  _createRow(_currentAnimal.getBreed(), 'Breed', Icon(Icons.filter_vintage, color: Colors.orange[600],), false, false),
                  _isEmpty ? SizedBox() : SizedBox(height: 10),
                  _createRow(_currentAnimal.getStringAge(), 'Age', Icon(Icons.date_range_outlined, color: Colors.orange[600],), true, false),
                  _isEmpty ? SizedBox() : SizedBox(height: 10),
                  _createRow(_currentAnimal.gender, 'Gender', Icon(Icons.wc_outlined, color: Colors.orange[600],), false, false),
                  _isEmpty ? SizedBox() : SizedBox(height: 10),
                  _createRow(_currentAnimal.getIsTrained(), 'Trained?', Icon(Icons.wb_incandescent_outlined, color: Colors.orange[600],), false, false),
                  _isEmpty ? SizedBox() : SizedBox(height: 10),
                  _createRow(_currentAnimal.size, 'Size', Icon(Icons.photo_size_select_large_outlined, color: Colors.orange[600],), false, true),
                  _isEmpty ? SizedBox() : SizedBox(height: 10),
                  _createRow(_currentAnimal.location, 'Location', Icon(Icons.location_on, color: Colors.orange[600],), false, false),
                  _isEmpty ? SizedBox() : SizedBox(height: 20),
                  _createTitleRow(_getStringFromList(_currentAnimal.color), Icon(Icons.color_lens_outlined, color: Colors.orange[600],), "Colors"),
                  _isEmpty ? SizedBox() : SizedBox(height: 10),
                  _createRow(_getStringFromList(_currentAnimal.color), 'Colors', Icon(Icons.color_lens_outlined, color: Colors.white24,), false, false),
                  _isEmpty ? SizedBox() : SizedBox(height: 20),
                  _createTitleRow(_getStringFromList(_currentAnimal.qualities), Icon(Icons.recommend, color: Colors.orange[600],), "Qualities"),
                  _isEmpty ? SizedBox() : SizedBox(height: 10),
                  _createRow(_getStringFromList(_currentAnimal.qualities), 'Qualities', Icon(Icons.recommend, color: Colors.white24,), false, false),
                  _isEmpty ? SizedBox() : SizedBox(height: 10),
                  _createRow(_currentAnimal.about, 'About', Icon(Icons.description_outlined, color: Colors.orange[600],), false, false),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }


  /// NEED TO COMPLETE
  Widget _createColorsPalette(List<String> colorsList) {

    if(colorsList.length == 0) {
      return Container();
    }

    List<Color> colorsObj = [];

    for (var c in colorsList) {
      print(c);
      Color colorOb = Colors.black;

      try {
        SPColor.RgbColor rgbColor = new SPColor.RgbColor.name(c);
        print('converted');
        print(rgbColor.toCssString());

        colorOb = Color.fromRGBO(rgbColor.r.toInt(), rgbColor.g.toInt(), rgbColor.b.toInt(), 1.0);
        print(colorOb);

      } catch (e) {
        // not a color
        print('not color');
      }

      colorsObj.add(colorOb);

    }

    var list = ListView.builder(
      itemCount: colorsObj.length,
      itemBuilder: (context, index) {
        return Row(
          // crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget> [
            Icon(Icons.play_arrow_rounded, color: colorsObj[index]),
            SizedBox(width: 20,),
            Text(
                colorsList[index],
                style: TextStyle(
                  fontSize: 16.0,
                  //fontWeight: FontWeight.bold
                )
            )

          ],
        );
      },
    );


    return list;

  }


}

/*
Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Column(
                children: [
                  _createTextFormField(context, "Name", Icon(Icons.pets), nameController, nameFocus, typeFocus, TextInputType.name, true),
                  SizedBox(height: 20),
                  _createTextFormField(context, "Type", Icon(Icons.widgets_outlined), typeController, typeFocus, breedFocus, TextInputType.text, true),
                  SizedBox(height: 20),
                  _createTextFormField(context, "Breed", Icon(Icons.filter_vintage), breedController, breedFocus, ageFocus, TextInputType.text, false),
                  SizedBox(height: 20),
                  _createTextFormField(context, "Age", Icon(Icons.date_range_outlined), ageController, ageFocus, locationFocus, TextInputType.text, true),
                ],
              ),
            ),
            SizedBox(height: 20),
            _createTextFieldPickButton(context, "Gender", 0, genderController, ['Female', 'Male'], true),
            //SizedBox(height: 10),
            _createTextFieldPickButton(context, "Is Trained", 1, trainedController, ['Trained', 'Not Trained'], false),
            //SizedBox(height: 10),
            _createTextFieldPickButton(context, "Size", 2, sizeController, ['XS', 'S', 'M', 'L', 'XL', 'XXL'], true),
            //SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _createTextFormField(context, "Location", Icon(Icons.location_on), locationController, locationFocus, null, TextInputType.text, true),
                    //colors
                    SizedBox(height: 30),
                    Text (
                      'Colors',
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(height: 10),
                    DynamicTextField(hint: "Color", fieldsController: colorsController,),
                    // qualities
                    SizedBox(height: 30),
                    Text ('Qualities',
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    DynamicTextField(hint: "Quality", fieldsController: qualitiesController,),
                    SizedBox(height: 20),
                    _createTextFormField(context, "About Your Pet", Icon(Icons.description_outlined), descriptionController, descriptionFocus, null, TextInputType.text, false),
                  ]
              ),
            ),
 */