import 'dart:math';

import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:take_a_pet/db/data_repository.dart';
import 'package:take_a_pet/models/animal_profile.dart';
import 'package:take_a_pet/util/const.dart';
import 'package:take_a_pet/util/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:take_a_pet/util/date_picker.dart';
import 'package:take_a_pet/util/shadow_button.dart';
import 'package:take_a_pet/db/db_logic.dart';
import 'package:take_a_pet/models/app_user.dart';
import 'package:take_a_pet/models/history.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:take_a_pet/util/pick_button.dart';
import 'package:take_a_pet/views/Image_view.dart';
import 'package:take_a_pet/db/storage_repository.dart';
import 'package:take_a_pet/util/dynamic_text_field.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class AnimalProfileEdit extends StatefulWidget {

  AnimalProfileEdit({Key? key, required this.logic, required this.storage, required this.dataRepo, required this.animalProfile}) : super(key: key);

  final DBLogic logic;
  final StorageRepository storage;
  final DataRepository dataRepo;
  final AnimalProfile animalProfile;

  @override
  _AnimalProfileEditState createState() => _AnimalProfileEditState();
}

class _AnimalProfileEditState extends State<AnimalProfileEdit> {

  var random = new Random();
  String _animalId = "";
  AnimalProfile _currentAnimal = new AnimalProfile(id: "", type: "", name: "",
      age: 0.0, gender: "", size: "", color: [], location: "", createdAt: Timestamp.now(),
      creatorId: "", isAdopted: false, isDeleted: false, qualities: [], likesNum: 0);
  String _currentUserId = '';
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  bool _status = true;
  var _pressIcon = List<bool>.filled(3, false);
  //var _fieldIcons = List<Icon>.filled(3, Icon(Icons.keyboard_arrow_down_sharp));
  String _error = "";
  File? _selectedImage;
  Image? _currentImageInDB;
  final nameController = TextEditingController();
  //final breedController = TextEditingController();
  //final typeController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final ageController = TextEditingController();
  final genderController = TextEditingController();
  final trainedController = TextEditingController();
  final sizeController = TextEditingController();
  List<TextEditingController> qualitiesController = [];
  List<TextEditingController> colorsController = [];
  final nameFocus = FocusNode();
  final typeFocus = FocusNode();
  final breedFocus = FocusNode();
  final ageFocus = FocusNode();
  final descriptionFocus = FocusNode();
  final locationFocus = FocusNode();
  Flushbar _flushbarError = Flushbar(message: "",);
  bool validImage = false;
  bool algoInProgress = false;
  String breedClassification='';
  String typeClassification='';

  @override
  void initState() {
    super.initState();
    _animalId = widget.animalProfile.id;
    _currentAnimal = widget.animalProfile;
    // get current user's details
    _currentUserDetails();
    // get pic from db if there is
    _retrievePicFromDB();


  }

  @override
  void dispose() {
    // Clean up the controller and focus nodes when the Widget is disposed
    nameController.dispose();
    //breedController.dispose();
    //typeController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    ageController.dispose();
    genderController.dispose();
    trainedController.dispose();
    sizeController.dispose();
    nameFocus.dispose();
    typeFocus.dispose();
    breedFocus.dispose();
    ageFocus.dispose();
    descriptionFocus.dispose();
    locationFocus.dispose();
    qualitiesController.forEach((element) => element.dispose());
    colorsController.forEach((element) => element.dispose());
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


  void _getPetInformation() {
    setState(() {
      nameController.text = _currentAnimal.name;
      breedClassification = _currentAnimal.getBreed();
      typeClassification= _currentAnimal.type;
      descriptionController.text = _currentAnimal.getAbout();
      locationController.text = _currentAnimal.location;
      ageController.text = _currentAnimal.age.toString();
      genderController.text = _currentAnimal.gender;
      trainedController.text = _currentAnimal.getIsTrained();
      sizeController.text = _currentAnimal.size;
      for(int i=0; i<_currentAnimal.qualities.length; i++) {
        var controller = TextEditingController();
        controller.text = _currentAnimal.qualities[i];
        qualitiesController.add(controller);
      }
      for(int i=0; i<_currentAnimal.color.length; i++) {
        var controller = TextEditingController();
        controller.text = _currentAnimal.color[i];
        colorsController.add(controller);
      }
    }
    );
  }

  double _getAge() {
    // which way is better??
    return double.tryParse(ageController.text) ?? 0.0;
  }


  List<String> _getQualities() {
    List<String> qual = [];
    for (int i=0; i<qualitiesController.length; i++) {
      String text = qualitiesController[i].text;
      if (text != "") {
        qual.add(text);
      }
    }
    return qual;
  }

  List<String> _getColors() {
    List<String> colors = [];
    for (int i=0; i<colorsController.length; i++) {
      String text = colorsController[i].text;
      if (text != "") {
        colors.add(text);
      }
    }
    return colors;
  }

  void _insertDetailsToAnimal() {
    double age = _getAge();
    List<String> qualities = _getQualities();
    List<String> colors = _getColors();

    bool? trained = (trainedController.text == 'Trained') ? true : ((trainedController.text == 'Not Trained') ? false : null);
    _currentAnimal = _currentAnimal.copyWith(id: _animalId,
        name: nameController.text, age: age, gender: genderController.text,
        size: sizeController.text, color: colors, location: locationController.text,
        createdAt: Timestamp.now(), creatorId: _currentUserId, isAdopted: false,
        isDeleted: false, qualities: qualities,
        isTrained: trained, about: descriptionController.text);
  }

  void _insertTypeBreedToAnimal() {
    _currentAnimal = _currentAnimal.copyWith(type: typeClassification, breed: breedClassification);
  }

  Future<void> _currentUserDetails() async {
    try {
      _currentUserId = widget.logic.getCurrentUser()!.uid;
      _getPetInformation();
    } catch (e) {
      _error = e.toString();
      _showError();
    }
  }

  void _deleteProfilePic() async {

    String fileName = _animalId;

    try {

      //_currentAnimal = _currentAnimal.copyWith(image: fileName);

      Future.wait([
        widget.storage.deleteImageFromStorage(fileName),
        //widget.dataRepo.updateAnimal(updatedAnimal: _currentAnimal)
      ]);

      setState(() {
        _selectedImage = null;
        _currentImageInDB = null;
      });

    } catch (e) {
      _error = e.toString();
      _showError();
    }
  }

  Future<void> _retrievePicFromDB() async {

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

  Widget _getActionButtons(BuildContext context) {

    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ShadowButton(
            text: "SAVE",
            color: Colors.green,
            height: 40,
            width: 100,
            onPressed: () {
              setState(() {
              });
              // save all in db
              _saveDetails(context);
            },
          ),
          SizedBox(width: 50,),
          ShadowButton(
            text: "CANCEL",
            color: Colors.red,
            height: 40,
            width: 100,
            onPressed: () {
              // if something new was write but not saved, return to what it was before
              _getPetInformation();
              setState(() {
                _status = true;
                _pressIcon = List<bool>.filled(3, false);
                //_fieldIcons = List<Icon>.filled(3, Icon(Icons.keyboard_arrow_down_sharp));
                _error = "";
                //_currentImageInDB = null;
              });
              _formKey.currentState!.validate();
            },
          ),
        ],
      ),
    );
  }

  Widget _getEditIcon() {
    return GestureDetector(
      child: CircleAvatar(
        backgroundColor: Colors.lightBlue,
        radius: 12.0,
        child: Icon(
          Icons.edit,
          color: Colors.white,
          size: 16.0,
        ),
      ),
      onTap: () {
        setState(() {
          _status = false;
        });
      },
    );
  }

  Widget _createProfileImage() {
    return Container(
      height: 170.0,
      color: Colors.white,
      child: Stack(
        fit: StackFit.loose,
        children: <Widget>[
          InkWell(
            child: Center(
              child: Container(
                width: 170.0,
                height: 170.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[400],
                ),
                child: (_currentImageInDB == null && _selectedImage == null) // no image in db and no image selected
                    ? Icon(
                  Icons.pets,
                  size: 130,
                  color: Colors.white,
                )
                    : ClipRRect( // the pickedPicture
                  borderRadius: BorderRadius.circular(50),
                  child: (_selectedImage == null)
                      ?
                  FittedBox( // no selected image - showing the image in the DB
                    child: _currentImageInDB,
                    fit: BoxFit.fill,
                  )
                      :
                  Image.file(_selectedImage as File, fit: BoxFit.fill), // there is selected image - showing it
                ),
              ),
            ),
            onTap: () {
              if (_selectedImage != null || _currentImageInDB != null) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageView(selectedImage: _selectedImage, imageFromDB: _currentImageInDB, logic: widget.logic, storage: widget.storage, forEdit: false,),
                    ));
              }
            },
          ),
          Padding (
              padding: EdgeInsets.only(top: 125.0, left: 70),
              child: CircleAvatar(
                backgroundColor: Colors.lightBlue,
                radius: 20.0,
                child: IconButton(
                  icon: Icon(Icons.camera_alt, color: Colors.white),
                  iconSize: 25,
                  onPressed: !algoInProgress ? () {
                    _showImageSourceActionSheet();
                    _error = '';
                  } : () {},
                ),
              )),
        ],
      ),
    );
  }

  Widget _createTextFormField(BuildContext context, String hint, Icon textIcon,
      TextEditingController controller, FocusNode focus, FocusNode? nextFocus,
      TextInputType inputType, bool isRequired, bool edit) {

    int? lines = 1;
    if (hint == "About Your Pet") {
      lines = null;
    }

    return TextFormField(
      keyboardType: TextInputType.text,
      textCapitalization: (hint == "About Your Pet") ? TextCapitalization.sentences : TextCapitalization.words,
      decoration: !_status && edit ? InputDecoration (
          icon: textIcon,
          hintText: hint
      ) :
      InputDecoration ( // no edit
          icon: textIcon,
          hintText: hint,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
      ),
      enabled: edit && !_status,
      autofocus: edit && !_status,
      maxLines: lines,
      controller: controller,
      focusNode: focus,
      onFieldSubmitted: (nextFocus != null) ? (value) {
        FocusScope.of(context).requestFocus(nextFocus);
      } : null,
      validator: isRequired ? (val) {
        if (val == "" || val == null || val.isEmpty || val == '0.0') {
          return 'Please insert ' + hint;
        }
        // valid info
        return null;
      } : null,
    );
  }

  Widget _createTextFieldPickButton(BuildContext context, String hint, Icon icon, int index,
      TextEditingController controller, List<String> options, bool isRequired) {

    return Container(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: <Widget>[
                icon,

                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    decoration: _status ? InputDecoration (
                      //icon: textIcon,
                      hintText: hint,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ) : InputDecoration (
                      suffixIcon: !isRequired ? IconButton(
                        icon: Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          controller.text = "";
                        },
                      ) : null,
                      hintText: hint,
                    ),
                    onTap: !_status ? () {
                      setState(() {
                        if (_pressIcon[index]) {
                          //_fieldIcons[index] = Icon(Icons.keyboard_arrow_down_sharp);
                          _pressIcon[index] = false;
                        } else {
                          //_fieldIcons[index] = Icon(Icons.keyboard_arrow_up_sharp);
                          _pressIcon[index] = true;
                        }
                      });
                    } : null,

                    enabled: !_status,
                    autofocus: !_status,
                    readOnly: true,
                    controller: controller,
                    //focusNode: focus,
                    onFieldSubmitted: (value) {
                      //FocusScope.of(context).requestFocus(dateFocus);
                    },
                    validator: isRequired ? (val) {
                      if (val == "" || val == null || val.isEmpty) {
                        return 'Please insert ' + hint;
                      }
                      // valid info
                      return null;
                    } : null,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          _pressIcon[index] ? PickButton(optionsList: options, textController: controller, fontSize: 14.0) : SizedBox(height: 0,),
        ],
      ),
    );

  }

  @override
  Widget build(BuildContext context) {

    //_getPetInformation();

    return WillPopScope(
      onWillPop: () { // clicking the BACK button in the phone
        //trigger leaving and use own data
        Navigator.pop(context);
        Navigator.pushNamed(context, '/created_profiles');

        //we need to return a future
        return Future.value(false);
      },
      child: AdminScaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Animal Profile'),
          backgroundColor: Colors.lightBlue,
          actions: !algoInProgress ?
          [
            IconButton(
                onPressed: () {
                  sleep(Duration(seconds: 1));
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/created_profiles');
                },
                icon: Icon(Icons.arrow_forward)
            ),
          ] : [] // if algorithm is running - no option to go back,
        ),
        sideBar: buildSideBar(context),
        body: Container(
          color: Colors.white,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10.0, 20, 30),
              children: <Widget>[
                Text (
                  'Profile Picture',
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: 10,),
                _createProfileImage(),
                _isImageValid(context),
                SizedBox(height: 30,),
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget> [
                          Text(
                              'Breed:    ',
                              style : TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black45
                              )
                          ),
                          Text(
                              breedClassification,
                              style : TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black
                              )
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      //validImage ?
                      Row(
                        children: <Widget> [
                          Text(
                              'Type:    ',
                              style : TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black45
                              )
                          ),
                          Text(
                              typeClassification,
                              style : TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black
                              )
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(thickness: 3),
                SizedBox(height: 15),
                Container(
                  //padding: EdgeInsets.only(left: 20),
                  child: Row (
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text (
                        'Pet Information',
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(width: 10),
                      (_status) ? _getEditIcon() : Container(),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    children: [
                      _createTextFormField(context, "Name", Icon(Icons.pets), nameController, nameFocus, typeFocus, TextInputType.name, true, false),
                      //SizedBox(height: 20),
                      //_createTextFormField(context, "Type", Icon(Icons.widgets_outlined), typeController, typeFocus, breedFocus, TextInputType.text, true),
                      //SizedBox(height: 20),
                      //_createTextFormField(context, "Breed", Icon(Icons.filter_vintage), breedController, breedFocus, ageFocus, TextInputType.text, false),
                      SizedBox(height: 10),
                      _createTextFormField(context, "Age", Icon(Icons.date_range_outlined), ageController, ageFocus, locationFocus, TextInputType.text, true, true),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                _createTextFieldPickButton(context, "Gender", Icon(Icons.wc_outlined, color: Colors.grey,), 0, genderController, ['Female', 'Male'], true),
                //SizedBox(height: 10),
                _createTextFieldPickButton(context, "Is Trained?",Icon(Icons.wb_incandescent_outlined, color: Colors.grey), 1, trainedController, ['Trained', 'Not Trained'], false),
                //SizedBox(height: 10),
                _createTextFieldPickButton(context, "Size", Icon(Icons.photo_size_select_large_outlined, color: Colors.grey), 2, sizeController, ['S', 'M', 'L'], true),
                //SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _createTextFormField(
                            context,
                            "Location",
                            Icon(Icons.location_on),
                            locationController,
                            locationFocus,
                            null,
                            TextInputType.text,
                            true, true),
                        //colors
                        SizedBox(height: 30),
                        Text(
                          'Colors',
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(height: 10),
                        DynamicTextField(
                          hint: "Color", fieldsController: colorsController,),
                        // qualities
                        SizedBox(height: 30),
                        Text('Qualities',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        DynamicTextField(hint: "Quality",
                          fieldsController: qualitiesController,),
                        SizedBox(height: 20),
                        _createTextFormField(
                            context,
                            "About Your Pet",
                            Icon(Icons.description_outlined),
                            descriptionController,
                            descriptionFocus,
                            null,
                            TextInputType.text,
                            false, true),
                      ]
                  ),
                ),
                SizedBox(height: 20),
                loading ? CircularProgressIndicator()
                    :
                // create the appropriate buttons after pressing edit or in the start - on registration
                (!_status) ? _getActionButtons(context) : new Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _isImageValid(BuildContext context) {
    if (algoInProgress) {
      return Column(
        children: <Widget> [
          Text(
              'We are checking your image',
              style : TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.green
              )
          ),
          CircularProgressIndicator()
        ],
      );
    }

    if(!validImage) {
      print(_error);
      return Center(
        child: Text(_error.toString(),textAlign: TextAlign.center,
            style : TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.red
            )),
      );
    } else {
      print('approved');
      return Icon(Icons.assignment_turned_in_outlined, color: Colors.green);
    }

  }


  Future<void> openImagePicker({required ImageSource imageSource}) async {
    try{
      final pickedImage = await ImagePicker().getImage(source: imageSource, maxWidth: 512, maxHeight: 512);
      if (pickedImage == null) return; // if no image picked - not changing anything

      setState(() {
        //breedClassification = '';
        //typeClassification = '';
        _selectedImage = File(pickedImage.path);
        //print('Image Path: $_selectedImage');
      });

      // starting the algo to check if photo is valid
      await _checkPickedImage(context);

      if(validImage){
        _saveImage(context);
      }


    } catch (e) {
      //print(e);
      _error = e.toString();
      _showError();
    }
  }


  void _showImageSourceActionSheet() {

    Function(ImageSource) selectImageSource = (imageSource) {

      openImagePicker(imageSource: imageSource);

    };

    if (Platform.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) =>
            CupertinoActionSheet(
              actions: [
                CupertinoActionSheetAction(
                  child: Text('Camera'),
                  onPressed: () {
                    Navigator.pop(context);
                    selectImageSource(ImageSource.camera);
                  },
                ),
                CupertinoActionSheetAction(
                  child: Text('Gallery'),
                  onPressed: () {
                    Navigator.pop(context);
                    selectImageSource(ImageSource.gallery);
                  },
                ),
                // (_selectedImage != null || _currentImageInDB != null) ?
                // CupertinoActionSheetAction(
                //   child: Text('Remove Picture'),
                //   onPressed: () {
                //     Navigator.pop(context);
                //     _deleteProfilePic();
                //   },
                // )
                //     :
                // Container(),
              ],
            ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) =>
            Wrap(children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  selectImageSource(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_album),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  selectImageSource(ImageSource.gallery);
                },
              ),
              // (_selectedImage != null || _currentImageInDB != null) ?
              // ListTile(
              //   leading: Icon(Icons.delete),
              //   title: Text('Remove Picture'),
              //   onTap: () {
              //     Navigator.pop(context);
              //     // remove from db
              //     _deleteProfilePic();
              //   },
              // )
              //     :
              // Container(),
            ]),
      );
    }
  }

  Future<String> _convertImageToString() async {

    List<int> imageBytes = _selectedImage!.readAsBytesSync();
    print(imageBytes);
    var base64Image = base64Encode(imageBytes);
    print('finished convert to 64');
    return base64Image;

  }

  Future<Map<String, dynamic>> _classifyPickedImage() async {

    String image = await _convertImageToString();

    // transfer bytes
    Uri functionUrl = Uri.parse('https://europe-central2-take-a-pet.cloudfunctions.net/classify_image');

    print('URL '+ functionUrl.host);
    var jsonImage = {'image': image};
    print(image.length);

    try {
      var response = await http.post(functionUrl, body: jsonImage);
      var modelResult = json.decode(response.body);

      //var data= await json.decode(json.encode(response.databody);


      print(modelResult);
      print(modelResult.runtimeType);

      return modelResult;

    } catch (e) {
      print('HERE');
      print(e);
      throw Exception('Heavy traffic, please try again');
    }
  }

  Future<Map<String, dynamic>> _isAcceptedAnimal(String label) async {

    // cloud function
    Uri functionUrl = Uri.parse('https://europe-central2-take-a-pet.cloudfunctions.net/is_label_an_accepted_animal');

    print('URL '+ functionUrl.host);

    var jsonLabel = {'label': label};


    try {
      var response = await http.post(functionUrl, body: jsonLabel);
      var modelResult = json.decode(response.body);

      //var data= await json.decode(json.encode(response.databody);


      print(modelResult);
      print(modelResult.runtimeType);

      return modelResult;

    } catch (e) {
      print(e);
      throw e;
    }
  }


  Future<void> _checkIfAccepted(String label) async {
    print('_checkIfAccepted');
    print(label);

    try {
      setState(() {
        algoInProgress = true;
      });


      // check if the label is an accepted animal
      var acceptedResult = await _isAcceptedAnimal(label);

      setState(() {
        algoInProgress = false;
      });

      //classificationLabel = finalLabel;

      if(acceptedResult['outResult'] == true) {
        // removing '_' from the label

        typeClassification = acceptedResult['message'];
        setState(() {
          validImage = true;
        });

      } else {
        print('exception');
        throw acceptedResult['message'];
      }


    } catch (e) {
      print(e);
      _error = e.toString();

      setState(() {
        algoInProgress = false;
        validImage = false;
      });

    }

  }

  Future<void> _checkPickedImage(BuildContext context) async {
    print('checking');
    // no new image selected
    if(_selectedImage == null) return;

    try {
      setState(() {
        algoInProgress = true;
        validImage = false;
      });

      var classificationResult = await _classifyPickedImage();

      print('RESULT');
      print(classificationResult);

      setState(() {
        algoInProgress = false;
      });

      var finalLabel = classificationResult['label'];
      print(finalLabel);

      var outVal = classificationResult['isMultiple'];

      if(outVal == 'Error') {
        throw finalLabel;
      }

      if(outVal == true){
        BuildContext dialogContext;

        // finalLabel is a list
        // the user should choose his option from the list
        await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              dialogContext = context;
              return WillPopScope(
                onWillPop: () => showExitPopup(context),
                // onWillPop: () { return Future.value(false); },
                child: Dialog(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      //var label = finalLabel[index].replaceAll('_', ' ');
                      return new ElevatedButton(onPressed: () {
                        finalLabel = finalLabel[index];
                        Navigator.pop(dialogContext);
                      }, child: Text(finalLabel[index].replaceAll('_', ' ')));
                    },
                  ),
                ),
              );
            });


      }

      //setState(() {
      var newBreed = finalLabel.replaceAll('_', ' ');
      print(newBreed);
      if(newBreed != breedClassification) {
        throw ('Are you sure this is '+ _currentAnimal.name+'?\nYou uploaded a pick of '
            + newBreed + ' but '+ _currentAnimal.name+' is a '+ breedClassification+'\nPlease upload a new image');
      }

      setState(() {
        validImage = true;
      });

    } catch (e) {
      // no valid image
      print(e);
      _error = e.toString();
      //_showError();

      setState(() {
        algoInProgress = false;
        validImage = false;
      });

    }

  }

  // Future<void> _saveImageClassification(BuildContext context) async {
  //   try {
  //     setState(() {
  //       loading = true;
  //     });
  //
  //     _insertTypeBreedToAnimal();
  //     await widget.dataRepo.updateAnimal(updatedAnimal: _currentAnimal);
  //
  //
  //
  //     setState(() {
  //
  //       loading = false;
  //     });
  //
  //     //Navigator.pushReplacementNamed(context, '/created_profiles');
  //
  //   } catch (e) {
  //     _error = e.toString();
  //     _showError();
  //     setState(() {
  //       loading = false;
  //     });
  //   }
  //
  //
  // }

  Future<void> _saveDetails(BuildContext context) async {
    if(_formKey.currentState!.validate()) {

      // want to show the loading widget instead of form field
      // setState - tells the framework that the widget’s state has changed and that the widget should be redrawn
      setState(() {
        loading = true;
      });
      try {
        _insertDetailsToAnimal();
        await widget.dataRepo.updateAnimal(updatedAnimal: _currentAnimal);

        setState(() {
          _status = true;
          _pressIcon = List<bool>.filled(3, false);
          //_fieldIcons = List<Icon>.filled(3, Icon(Icons.keyboard_arrow_down_sharp));
          _error = "";
          loading = false;
        });

        //Navigator.pushReplacementNamed(context, '/created_profiles');

      } catch (e) {
        _error = e.toString();
        _showError();
        setState(() {
          loading = false;
        });
      }
    }
  }


  // Future<void> _saveImage() async {
  //
  //   // no new image selected
  //   if(_selectedImage == null) return;
  //
  //   // uploading the picture to storage
  //   String fileName = _animalId;
  //
  //   try {
  //
  //     //_currentAnimal = _currentAnimal.copyWith(image: fileName);
  //
  //     Future.wait([
  //       widget.storage.uploadImageToStorage(fileName, _selectedImage as File),
  //       //widget.dataRepo.updateAnimal(updatedAnimal: _currentAnimal)
  //     ]);
  //
  //     // saved new pic in db
  //     _currentImageInDB = null;
  //
  //   } catch (e) {
  //     _error = e.toString();
  //     _showError();
  //   }
  // }

  Future<void> _saveImage(BuildContext context) async {
    try {
      // no new image selected
      if (_selectedImage == null) return;

      // if (!validImage) {
      //   throw 'You uploaded invalid image for your pet - see details above';
      // }

      // uploading the picture to storage
      String fileName = _animalId;

       await widget.storage.uploadImageToStorage(fileName, _selectedImage as File);

      // saved new pic in db
      setState(() {
        _currentImageInDB = null;
      });


    } catch (e) {
      // throw e;
      _error = e.toString();
      _showError();

    }
  }




}