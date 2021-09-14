import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:take_a_pet/util/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:take_a_pet/util/date_picker.dart';
import 'package:take_a_pet/util/shadow_button.dart';
import 'package:take_a_pet/db/db_logic.dart';
import 'package:take_a_pet/models/app_user.dart';
import 'package:take_a_pet/models/history.dart';
import 'package:take_a_pet/util/pick_button.dart';
import 'package:take_a_pet/views/Image_view.dart';
import 'package:take_a_pet/db/storage_repository.dart';
import 'package:intl/intl.dart';

class Registration extends StatefulWidget {

  Registration({Key? key, required this.logic, required this.storage}) : super(key: key);

  final DBLogic logic;
  final StorageRepository storage;

  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  String _currentUserId = '';
  AppUser _currentUser = new AppUser(id: "", email: "", firstName: "", gender: "",
      favoriteProfilesIdList: [], createdProfilesIdList: [], historyData:
      History(labelsSearched: [], profilesId: [], animalsTypes: []));
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  bool _pressGender = false;
  Icon _genderIcon = Icon(Icons.keyboard_arrow_down_sharp);
  String _error = "";
  File? _selectedImage;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();
  final genderController = TextEditingController();
  final firstNameFocus = FocusNode();
  final lastNameFocus = FocusNode();
  final descriptionFocus = FocusNode();
  final genderFocus = FocusNode();
  final dateFocus = FocusNode();
  Flushbar _flushbarError = Flushbar(message: "",);

  @override
  void initState() {
    super.initState();
    // get current user's details
    _currentUserDetails();
  }

  @override
  void dispose() {
    // Clean up the controller and focus nodes when the Widget is disposed
    firstNameFocus.dispose();
    lastNameFocus.dispose();
    descriptionFocus.dispose();
    genderFocus.dispose();
    dateFocus.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    descriptionController.dispose();
    genderController.dispose();
    dateController.dispose();
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
    try {
      _currentUserId = widget.logic.getCurrentUser()!.uid;
      _currentUser = await widget.logic.getUserById(_currentUserId);
    } catch (e) {
      _error = e.toString();
      _showError();
    }
  }

  Future<void> _saveImage() async {
    // no new image selected
    if(_selectedImage == null) return;

    // uploading the picture to storage
    String fileName = _currentUserId;

    try {
      _currentUser = _currentUser.copyWith(avatarKey: fileName);

      Future.wait([
        widget.storage.uploadImageToStorage(fileName, _selectedImage as File),
        widget.logic.updateUserInfo(updatedUser: _currentUser)
      ]);

    } catch (e) {
      _error = e.toString();
      _showError();
    }
  }

  void _deleteProfilePic() async {

    String fileName = _currentUserId;

    try {
      _currentUser = _currentUser.copyWith(avatarKey: '');

      Future.wait([
        widget.storage.deleteImageFromStorage(fileName),
        widget.logic.updateUserInfo(updatedUser: _currentUser)
      ]);

      setState(() {
        _selectedImage = null;
      });

    } catch (e) {
      _error = e.toString();
      _showError();
    }
  }


  Future<void> _saveDetails(BuildContext context) async {
    if(_formKey.currentState!.validate()) {
      // want to show the loading widget instead of form field
      // setState - tells the framework that the widget’s state has changed and that the widget should be redrawn
      setState(() {
        loading = true;
      });
      try {
        Timestamp? date;
        if (dateController.text != "") {
          date = new Timestamp.fromDate(
              DateFormat('MM/dd/yyyy').parse(dateController.text));
        }
        _currentUser = _currentUser.copyWith(firstName: firstNameController.text, lastName: lastNameController.text,
            description: descriptionController.text, gender: genderController.text, birthday: date);
        await widget.logic.updateUserInfo(updatedUser: _currentUser);

        setState(() {
          _pressGender = false;
        });

        Navigator.pushReplacementNamed(context, '/home_page.dart');
      } catch (e) {
        _error = e.toString();
        _showError();
      }
      setState(() {
        loading = false;
      });
    }

  }

  Widget _getContinueButton(BuildContext context) {

    return Center(
      child: ShadowButton(
        text: "CONTINUE",
        color: Colors.lightBlue,
        height: 30,
        width: 100,
        onPressed: () {
          setState(() {
          });
          // save all in db, check that first name is not empty
          _saveDetails(context);
        },
      ),
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
                child: (_selectedImage == null) // no image in db and no image selected
                    ? Icon(
                  Icons.person,
                  size: 130,
                  color: Colors.white,
                )
                    : ClipRRect( // the pickedPicture
                  borderRadius: BorderRadius.circular(50),
                  child: Image.file(_selectedImage as File, fit: BoxFit.fill), // there is selected image - showing it
                ),
              ),
            ),
            onTap: () {
              if (_selectedImage != null) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ImageView(selectedImage: _selectedImage,
                              logic: widget.logic,
                              storage: widget.storage,
                              forEdit: false,
                              userId: _currentUserId),
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
                  onPressed: () {
                    _showImageSourceActionSheet();
                    _error = '';
                  },
                ),
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return AdminScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.lightBlue,
      ),
      sideBar: buildSideBar(context),
      body: Container(
        color: Colors.white,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 30.0, 20, 30),
            children: <Widget>[
              _createProfileImage(),
              SizedBox(height: 40,),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text (
                  'Personal Information',
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration (
                          icon: Icon(Icons.account_circle),
                          hintText: "First Name"
                      ),
                      autofocus: true,
                      controller: firstNameController,
                      focusNode: firstNameFocus,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(lastNameFocus);
                      },
                      validator: (val) {
                        if (val == "" || val == null || val.isEmpty) {
                          return 'Please insert your first name';
                        }
                        // valid info
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration (
                          icon: Icon(Icons.people_alt_outlined),
                          hintText: "Last Name"
                      ),
                      controller: lastNameController,
                      focusNode: lastNameFocus,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(descriptionFocus);
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration (
                          icon: Icon(Icons.description_outlined),
                          hintText: "About Yourself"
                      ),
                      controller: descriptionController,
                      maxLines: null,
                      focusNode: descriptionFocus,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(genderFocus);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.only(left: 10, right: 20),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: <Widget>[
                    IconButton(
                      icon: _genderIcon,
                      color: Colors.lightBlue,
                      onPressed: () {
                        setState(() {
                          if (_pressGender) {
                            _genderIcon = Icon(Icons.keyboard_arrow_down_sharp);
                            _pressGender = false;
                          } else {
                            _genderIcon = Icon(Icons.keyboard_arrow_up_sharp);
                            _pressGender = true;
                          }
                        });
                      }
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 50),
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration (
                          suffixIcon: IconButton(
                            icon: Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              genderController.text = "";
                            },
                          ),
                          hintText: "Gender",
                        ),
                        readOnly: true,
                        controller: genderController,
                        focusNode: genderFocus,
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).requestFocus(dateFocus);
                        },
                        validator: (val) {
                          if (val == "" || val == null || val.isEmpty) {
                            return 'Please insert your gender';
                          }
                          // valid info
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              _pressGender ? PickButton(optionsList: ['Female','Male'], textController: genderController, fontSize: 14.0) : SizedBox(height: 0,),
              Padding(
                padding: EdgeInsets.only(left: 10, right: 20),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: <Widget>[
                    DatePicker(textController: dateController, active: true,),
                    Padding(
                      padding: const EdgeInsets.only(left: 50),
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration (
                          suffixIcon: IconButton(
                            icon: Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              dateController.text = "";
                            },
                          ),
                          hintText: "Date Of Birth",
                        ),
                        readOnly: true,
                        controller: dateController,
                        focusNode: dateFocus,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              loading ? CircularProgressIndicator()
                  :
              // create the appropriate buttons after pressing edit or in the start - on registration
              _getContinueButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> openImagePicker({required ImageSource imageSource}) async {
    try{
      final pickedImage = await ImagePicker().getImage(source: imageSource, maxWidth: 1024, maxHeight: 1024);
      if (pickedImage == null) return; // if no image picked - not changing anything

      setState(() {
        _selectedImage = File(pickedImage.path);
        //print('Image Path: $_selectedImage');
      });
      _saveImage();

    } catch (e) {
      print(e);
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
                (_selectedImage != null) ?
                CupertinoActionSheetAction(
                  child: Text('Remove Picture'),
                  onPressed: () {
                    Navigator.pop(context);
                    _deleteProfilePic();
                  },
                )
                    :
                Container(),
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
              (_selectedImage != null) ?
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Remove Picture'),
                onTap: () {
                  Navigator.pop(context);
                  // remove from db
                  _deleteProfilePic();
                },
              )
                  :
              Container(),
            ]),
      );
    }
  }

}

/*
  String firstName = "";
  String gender = "f";
  String? lastName;
  String? city;
  String? description;
  TextEditingController dateController = TextEditingController();
  TextEditingController genderController = TextEditingController();

  final firstNameFocusNode = FocusNode();
  final lastNameFocusNode = FocusNode();
  final dateFocusNode = FocusNode();
  User? user;
  String error = "";

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed
    firstNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    dateFocusNode.dispose();
    super.dispose();
  }

  Future<String> save() async{
    user = widget.logic.getCurrentUser();
    String? userId = user!.uid;
    try {
      AppUser appUser = await widget.logic.getUserById(userId);
      print("********************************name: ${this.firstName}");
      AppUser updateUser = new AppUser(id: appUser.getId(), email: appUser.email, firstName: this.firstName, gender: this.gender, favoriteProfilesIdList: [],
        createdProfilesIdList: [], historyData: History(labelsSearched: [], profilesId: [], animalsTypes: []),
        lastName: this.lastName, description: this.description, /* address: this.city*/);
      await widget.logic.updateUserInfo(updatedUser: updateUser);
      error = "";
      return "";
    }
    catch(e)
    {
      error = e.toString();
      print("********************************error: $error");
      return error;
    }
  }


  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final cardWidth = min(deviceSize.width * 0.75, 360.0);
    const cardPadding = 16.0;
    final textFieldWidth = cardWidth - cardPadding * 2;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(30.0),
        children: <Widget>[
          SizedBox(height: 40),
          Container(
            child: Center(
              child: Text("Enter Your Details",
                style: TextStyle(
                    color: Colors.lightBlue,
                    fontSize: 30.0
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            error,
            style: TextStyle(color: Colors.red, fontSize: 14.0),
          ),
          SizedBox(height: 10),
          AnimatedTextFormField(
            interval: const Interval(0, .85),
            width: textFieldWidth,
            maxLines: 1,
            labelText: 'Username',
            prefixIcon: Icon(Icons.account_circle),
            keyboardType: TextInputType.name,
            autofillHints: [AutofillHints.username],
            onFieldSubmitted: (value) {
              FocusScope.of(context).requestFocus(lastNameFocusNode);
            },
            textInputAction: TextInputAction.next,
            onSaved: (value) {this.firstName = "tusua123"; }/*(value) => this.firstName = (value == null) ? "problem" : value*/,
          ),
          SizedBox(height: 30),
          AnimatedTextFormField(
            interval: const Interval(0, .85),
            width: textFieldWidth,
            maxLines: 1,
            labelText: 'Address/City',
            prefixIcon: Icon(Icons.home_outlined),
            keyboardType: TextInputType.name,
            autofillHints: [AutofillHints.username],
            onFieldSubmitted: (value) {
              //FocusScope.of(context).requestFocus(lastNameFocusNode);
            },
            textInputAction: TextInputAction.next,
            onSaved: (value) => this.city = value,
          ),
          SizedBox(height: 30),
          AnimatedTextFormField(
            interval: const Interval(0, .85),
            width: textFieldWidth,
            maxLines: null,
            labelText: 'Description',
            prefixIcon: Icon(Icons.description_outlined),
            keyboardType: TextInputType.name,
            autofillHints: [AutofillHints.username],
            onFieldSubmitted: (value) {
              //FocusScope.of(context).requestFocus(lastNameFocusNode);
            },
            textInputAction: TextInputAction.next,
            onSaved: (value) => this.description = value,
          ),
          SizedBox(height: 30),
          Container(
            width: 200,
            height: 50,
            child: PickButton(optionsList: ['Female', 'Male'], textController: genderController, fontSize: 14.0,),
          ),
          SizedBox(height: 30),
          LimitedBox(
            maxHeight: 50,
            child: DatePicker(textController: dateController,),
          ),
          SizedBox(height: 50),
          Center(
            child: Row(
              children: <Widget>[
                ShadowButton(
                  width: deviceSize.width/4,
                  height: 30,
                  onPressed: () async {
                    // save!!
                    String error = await save();
                    if (error == "") {
                      Navigator.pushReplacementNamed(context, '/home_page.dart');
                    }
                    else {
                      //show error
                    }
                  },
                  text: 'SUBMIT',
                  color: Colors.lightBlue,
                ),
                SizedBox(width: deviceSize.width/4),
                ShadowButton(
                  width: deviceSize.width/4,
                  height: 30,
                  onPressed: () {
                    // don't save
                    Navigator.pushReplacementNamed(context, '/home_page.dart');
                  },
                  text: 'SKIP',
                  color: Colors.lightBlue,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
 */


String validateEmail(String? value) {
  String _msg;
  RegExp regex = new RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
  _msg = "";
  if (value == null) {
    _msg = "Your username is required";
  } else if (!regex.hasMatch(value)) {
    _msg = "Please provide a valid emal address";
  }
  return _msg;
}