import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:take_a_pet/util/const.dart';
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


class UserProfileEdit extends StatefulWidget {

  UserProfileEdit({Key? key, required this.logic, required this.storage,}) : super(key: key);

  final DBLogic logic;
  final StorageRepository storage;

  @override
  _UserProfileEditState createState() => _UserProfileEditState();
}

class _UserProfileEditState extends State<UserProfileEdit>
    with SingleTickerProviderStateMixin {

  String _currentUserId = '';
  AppUser _currentUser = new AppUser(id: "", email: "", firstName: "", gender: "",
      favoriteProfilesIdList: [], createdProfilesIdList: [], historyData:
      History(labelsSearched: [], profilesId: [], animalsTypes: []));
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  bool _status = true;
  bool _pressGender = false;
  Icon _genderIcon = Icon(Icons.keyboard_arrow_down_sharp);
  String _error = "";
  File? _selectedImage;
  Image? _currentImageInDB;
  // final firstNameController = TextEditingController();
  // final lastNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();
  final genderController = TextEditingController();
  final firstNameFocus = FocusNode();
  final lastNameFocus = FocusNode();
  final descriptionFocus = FocusNode();
  final genderFocus = FocusNode();
  final dateFocus = FocusNode();
  Flushbar _flushbarError = Flushbar(message: "",);
  bool infoChanged = false;

  @override
  void initState() {
    super.initState();
    // get current user's details
    _currentUserDetails();
    _retrievePicFromDB();
  }

  @override
  void dispose() {
    // Clean up the controller and focus nodes when the Widget is disposed
    firstNameFocus.dispose();
    lastNameFocus.dispose();
    descriptionFocus.dispose();
    genderFocus.dispose();
    dateFocus.dispose();
    // firstNameController.dispose();
    // lastNameController.dispose();
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

  void _getUserInformation() {
    setState(() {
      // firstNameController.text = _currentUser.getFirstName();
      genderController.text = _currentUser.getGender();
      // lastNameController.text = _currentUser.getLastName();
      descriptionController.text = _currentUser.getDescription();
      if (_currentUser.birthday != null) {
        dateController.text = _currentUser.getBirthDate();
      } else {
        dateController.text = "";
      }
    });
  }

  Future<void> _currentUserDetails() async {
    try {
      _currentUserId = widget.logic.getCurrentUser()!.uid;
      _currentUser = await widget.logic.getUserById(_currentUserId);
      _getUserInformation();
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

      // saved new pic in db
      _currentImageInDB = null;

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
        _currentImageInDB = null;
      });

    } catch (e) {
      _error = e.toString();
      _showError();
    }

  }

  Future<void> _retrievePicFromDB() async {
    String fileName = _currentUserId;

    try {
      Image? currentProfileImage = await widget.storage.getImageFromStorage(fileName);

      setState(() {
        _currentImageInDB = currentProfileImage;
        //print('Image Path: $_selectedImage');
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
        } else {
          date = Timestamp.fromDate(DateTime.now().add(Duration(days: 20)));
        }
        _currentUser = _currentUser.copyWith(/*firstName: firstNameController.text, lastName: lastNameController.text,*/
            description: descriptionController.text, gender: genderController.text, birthday: date);
        await widget.logic.updateUserInfo(updatedUser: _currentUser);
        setState(() {
          _status = true;
          _pressGender = false;
          loading = false;
          infoChanged = true;
        });

      } catch (e) {
        _error = e.toString();
        _showError();
        setState(() {
          loading = false;
        });
      }
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
              _getUserInformation();
              setState(() {
                _status = true;
                _pressGender = false;
                //FocusScope.of(context).requestFocus(new FocusNode());
                _error = "";
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
        radius: 14.0,
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
                  Icons.person,
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
                      builder: (context) =>
                          ImageView(selectedImage: _selectedImage,
                              imageFromDB: _currentImageInDB,
                              logic: widget.logic,
                              storage: widget.storage,
                              forEdit: true,
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
    //_getUserInformation();

    return WillPopScope(
      onWillPop: () => showExitPopup(context),
      child: AdminScaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('My Profile'),
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
                SizedBox(height: 30,),
                Container(
                  //padding: EdgeInsets.only(left: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Personal Information',
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(width: 80,),
                      _status ? _getEditIcon() : Container(),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.account_circle, color: Colors.grey,),
                            tooltip: 'First Name',
                            onPressed: () {},
                          ),
                          SizedBox(width: 10,),
                          Text(_currentUser.getFirstName(), style: TextStyle(fontSize: 16),)
                        ],
                      ),

                      SizedBox(height: 10),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.people_alt_outlined, color: Colors.grey,),
                            tooltip: 'Last Name',
                            onPressed: () {},
                          ),
                          SizedBox(width: 10,),
                          Text(_currentUser.getLastName(), style: TextStyle(fontSize: 16),)
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 20),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.wc_outlined, color: Colors.grey,),
                        tooltip: 'Gender',
                        onPressed: () {},
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 60),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          decoration: _status ? InputDecoration (
                            //icon: textIcon,
                            hintText: "Gender",
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                          ) : InputDecoration (
                            hintText: "Gender",
                          ),
                          onTap: !_status ? () {
                            setState(() {
                              if (_pressGender) {
                                _pressGender = false;
                              } else {
                                _pressGender = true;
                              }
                            });
                          } : null,
                          enabled: !_status,
                          autofocus: !_status,
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
                SizedBox(height: 10),
                _pressGender ? PickButton(optionsList: ['Female', 'Male'],
                    textController: genderController,
                    fontSize: 14.0) : SizedBox(height: 0,),
                //SizedBox(height: 20),

                Padding(
                  padding: EdgeInsets.only(left: 10, right: 20),
                  child: Stack(
                      alignment: Alignment.centerLeft,
                      children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.description_outlined, color: Colors.grey,),
                        tooltip: 'Gender',
                        onPressed: () {},
                      ),
                      Padding(padding: const EdgeInsets.only(left: 60),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: _status ? InputDecoration (
                            hintText: "About Yourself",
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                          ) : InputDecoration (
                              hintText: "About Yourself"
                          ),
                          enabled: !_status,
                          autofocus: !_status,
                          controller: descriptionController,
                          maxLines: null,
                          focusNode: descriptionFocus,
                          onFieldSubmitted: (value) {
                            FocusScope.of(context).requestFocus(genderFocus);
                            },
                        ),

                      )
                    ]
                  ),
                ),

                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 20),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: <Widget>[
                      !_status ? DatePicker(textController: dateController, active: true,) :
                      DatePicker(textController: dateController, active: false),
                      Padding(
                        padding: const EdgeInsets.only(left: 50),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          decoration: _status ? InputDecoration (
                            //icon: textIcon,
                            hintText: "Date Of Birth",
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                          ) : InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                dateController.text = "";
                              },

                            ),
                            hintText: "Date Of Birth",
                          ),
                          enabled: !_status,
                          autofocus: !_status,
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
                (!_status) ? _getActionButtons(context) : new Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openImagePicker({required ImageSource imageSource}) async {
    try{
      final pickedImage = await ImagePicker().getImage(source: imageSource, maxWidth: 512, maxHeight: 512);
      if (pickedImage == null) return; // if no image picked - not changing anything

      setState(() {
        _selectedImage = File(pickedImage.path);
        //print('Image Path: $_selectedImage');
      });
      _saveImage();

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
                (_selectedImage != null || _currentImageInDB != null) ?
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
              (_selectedImage != null || _currentImageInDB != null) ?
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