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


class UserProfileView extends StatefulWidget {

  UserProfileView({Key? key,required this.userId, required this.logic, required this.storage,}) : super(key: key);

  final DBLogic logic;
  final StorageRepository storage;
  final String userId;

  @override
  _UserProfileViewState createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {

  AppUser _currentUser = new AppUser(id: "", email: "", firstName: "", gender: "",
      favoriteProfilesIdList: [], createdProfilesIdList: [], historyData:
      History(labelsSearched: [], profilesId: [], animalsTypes: []));
  String _error = "";
  Image? _currentImageInDB;
  bool _isEmpty = false;
  Flushbar _flushbarError = Flushbar(message: "",);

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
      _currentUser = await widget.logic.getUserById(widget.userId);
    } catch (e) {
      _error = e.toString();
      _showError();
    }
  }

  Future<void> _retrievePicFromDB() async {
    String fileName = widget.userId;

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
              Icons.person,
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

  Widget _createRow(String? t, String toolTip, Icon icon, bool isDate) {
    _isEmpty = false;
    if (t == null || t == "") {
      _isEmpty = true;
      return SizedBox();
    }
    String text = t;
    if (isDate) {
      text = "Born At : " + text;
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
        Text(
            text,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 16.0,
              //fontWeight: FontWeight.bold
            )
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    return AdminScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile'),
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
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Column(
                children: [
                  _createRow(_currentUser.getFirstName(), 'FirstName', Icon(Icons.account_circle, color: Colors.grey,), false),
                  _isEmpty ? SizedBox() : SizedBox(height: 10),
                  _createRow(_currentUser.getLastName(), 'Last Name', Icon(Icons.people_alt_outlined, color: Colors.grey,), false),
                  _isEmpty ? SizedBox() : SizedBox(height: 10),
                  _createRow(_currentUser.getGender(), 'Gender', Icon(Icons.wc_outlined, color: Colors.grey,), false),
                  _isEmpty ? SizedBox() : SizedBox(height: 10),
                  _createRow(_currentUser.getDescription(), 'Description', Icon(Icons.description_outlined, color: Colors.grey,), false),
                  _isEmpty ? SizedBox() : SizedBox(height: 10),
                  _createRow(_currentUser.getBirthDate(), 'Birthday', Icon(Icons.date_range, color: Colors.grey,), true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}

/*
TextFormField(
                    decoration: const InputDecoration (
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        icon: Icon(Icons.account_circle),
                        hintText: "First Name"
                    ),
                    readOnly: true,
                    controller: firstNameController,
                  ),
SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration (
                        icon: Icon(Icons.people_alt_outlined),
                        hintText: "Last Name"
                    ),
                    readOnly: true,
                    controller: lastNameController,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration (
                        icon: Icon(Icons.description_outlined),
                        hintText: "About Yourself"
                    ),
                    readOnly: true,
                    controller: descriptionController,
                    maxLines: null,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration (
                      icon: Icon(Icons.wc_outlined),
                      hintText: "Gender",
                    ),
                    readOnly: true,
                    controller: genderController,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration (
                      icon: Icon(Icons.date_range),
                      hintText: "Date Of Birth",
                    ),
                    readOnly: true,
                    controller: dateController,
                  ),
 */