import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:take_a_pet/db/db_logic.dart';
import 'package:take_a_pet/db/storage_repository.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:take_a_pet/models/app_user.dart';
import 'package:take_a_pet/models/history.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:take_a_pet/util/widgets.dart';

class ImageView extends StatefulWidget {
  ImageView({Key? key, this.selectedImage, this.imageFromDB, this.logic, this.storage, required this.forEdit, this.userId}) : super(key: key);

  final File? selectedImage;
  final Image? imageFromDB;
  final DBLogic? logic;
  final StorageRepository? storage;
  final bool forEdit;
  final String? userId;

  @override
  _ImageViewState createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {

  String _error = '';
  File? _selectedImage;
  Image? _imageFromDB;
  Flushbar _flushbarError = Flushbar(message: "",);
  AppUser _currentUser = new AppUser(id: "", email: "", firstName: "", gender: "",
      favoriteProfilesIdList: [], createdProfilesIdList: [], historyData:
      History(labelsSearched: [], profilesId: [], animalsTypes: []));

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.selectedImage;
    _imageFromDB = widget.imageFromDB;
    if(widget.userId != null) {
      _currentUserDetails();
    }
  }

  Future<void> _currentUserDetails() async {
    try {
      _currentUser = await widget.logic!.getUserById(widget.userId);
    } catch (e) {
      _error = e.toString();
      _showError();
    }
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

  Future<void> _saveImage() async {
    // no new image selected
    if(_selectedImage == null) return;

    // uploading the picture to storage
    String fileName = _currentUser.getId();

    try {
      _currentUser = _currentUser.copyWith(avatarKey: fileName);

      Future.wait([
        widget.storage!.uploadImageToStorage(fileName, _selectedImage as File),
        widget.logic!.updateUserInfo(updatedUser: _currentUser)
      ]);
      _imageFromDB = null;

    } catch (e) {
      _error = e.toString();
      _showError();
    }
  }

  void _deleteProfilePic() async {

    String fileName = _currentUser.getId();

    try {
      _currentUser = _currentUser.copyWith(avatarKey: '');

      Future.wait([
        widget.storage!.deleteImageFromStorage(fileName),
        widget.logic!.updateUserInfo(updatedUser: _currentUser)
      ]);

      setState(() {
        _selectedImage = null;
        _imageFromDB = null;
      });

    } catch (e) {
      _error = e.toString();
      _showError();
    }

  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Profile Image'),
        actions: <Widget>[
          widget.forEdit ?
          IconButton(
              onPressed: () {
                _showImageSourceActionSheet();
                _error = '';
              },
              icon: Icon(Icons.edit, color: Colors.white)
          ) : Container(),
        ],
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
          //width: deviceSize.width,
          height: deviceSize.height,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.black,
          ),
          child: (_selectedImage == null && _imageFromDB == null) // no pic in db or selected
              ?
              Icon(
                Icons.person,
                size: deviceSize.width - 20,
                color: Colors.white,
              )
              :
          (_imageFromDB != null)
              ?
          FittedBox( // showing the image in the DB
            child: _imageFromDB,
            fit: BoxFit.fill,
          )
          :
              Image.file(_selectedImage as File, fit: BoxFit.fill), // there is selected image - showing it
        ),
      ),
    );
  }

  Future<void> openImagePicker({required ImageSource imageSource}) async {
    try {
      final pickedImage = await ImagePicker().getImage(source: imageSource, maxWidth: 1024, maxHeight: 1024);
      if (pickedImage == null)
        return; // if no image picked - not changing anything

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
                (_selectedImage != null || _imageFromDB != null) ?
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
              (_selectedImage != null || _imageFromDB != null) ?
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