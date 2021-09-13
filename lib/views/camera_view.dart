//
// import 'dart:io';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:take_a_pet/db/db_logic.dart';
// import 'package:take_a_pet/db/storage_repository.dart';
// import 'package:take_a_pet/models/app_user.dart';
//
// class CameraView extends StatefulWidget {
//   CameraView({Key? key, required this.title}) : super(key: key);
//
//   final String title;
//
//   @override
//   _CameraViewState createState() => _CameraViewState();
// }
//
// class _CameraViewState extends State<CameraView> {
//
//   StorageRepository _storageRepo = new StorageRepository();
//
//   final DBLogic _logic = DBLogic();
//
//
//   /// THOSE FIELDS SHOULD BE DELETED ///////////////////////////////////////////////////////
//   String _currentUserId='';
//   late AppUser _currentUser;
//
//   String _error = '';
//
//   File? _selectedImage;
//   Image? _currentImageInDB;
//
//
//   @override
//   Widget build(BuildContext context) {
//
//     _currentUserDetails();
//
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Builder(
//         builder: (context) => Container(
//           child: Column(
//             children: <Widget> [
//               InkWell(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.blue,
//                   ),
//                   width: 100,
//                   height: 100,
//                   child: (_currentImageInDB == null && _selectedImage == null) // no image in db and no image selected
//                       ? Icon(
//                     Icons.person,
//                     size: 50,
//                   )
//                       : ClipRRect( // the pickedPicture
//                     borderRadius: BorderRadius.circular(50),
//                     child: (_selectedImage == null)
//                       ?
//                     FittedBox( // no selected image - showing the image in the DB
//                       child: _currentImageInDB,
//                       fit: BoxFit.fill,
//                     )
//                     //Image.file(_currentImageInDB as File, fit: BoxFit.fill)
//                     :
//                     Image.file(_selectedImage as File, fit: BoxFit.fill), // there is selected image - showing it
//                   ),
//                 ),
//                 onTap: () {
//
//                 },
//               ),
//               IconButton(
//                 icon: Icon(Icons.camera_alt, color: Colors.white),
//                 onPressed: () {
//                   _showImageSourceActionSheet();
//                   _error = '';
//                 },
//               ),
//               Text(
//                 _error,
//                 style: TextStyle(color: Colors.red, fontSize: 14.0),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   _saveDetails(context);
//                 },
//                 style: ElevatedButton.styleFrom(
//                     primary: Colors.green
//                 ),
//                 child: Text('SAVE'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   _deleteProfilePic(context);
//                 },
//                 style: ElevatedButton.styleFrom(
//                     primary: Colors.red
//                 ),
//                 child: Text('delete picture'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   _retrievePicFromDB(context);
//                 },
//                 style: ElevatedButton.styleFrom(
//                     primary: Colors.orange
//                 ),
//                 child: Text('retrieve picture from DB'),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//
//   Future<void> _currentUserDetails() async {
//     _currentUserId = _logic.getCurrentUser()!.uid;
//     _currentUser = await _logic.getUserById(_currentUserId);
//   }
//
//
//     /// this method should contain saving ALL details and not only the
//   /// picture - depending on the info changed in the view
//   Future<void> _saveDetails(BuildContext context) async {
//     // no new image selected
//     if(_selectedImage == null) return;
//
//     // uploading the picture to storage
//     String fileName = _currentUserId;
//
//     try {
//
//       AppUser updatedUser = _currentUser.copyWith(avatarKey: fileName);
//
//       Future.wait([
//       _storageRepo.uploadImageToStorage(fileName, _selectedImage as File),
//         _logic.updateUserInfo(updatedUser: updatedUser)
//     ]);
//
//       setState(() {
//         Scaffold.of(context).showSnackBar(SnackBar(content: Text('Details Saved')));
//       });
//
//     } catch (e) {
//       _error = e.toString();
//     }
//   }
//
//   void _deleteProfilePic(BuildContext context) async {
//
//     String fileName = _currentUserId;
//
//     try {
//
//
//       AppUser updatedUser = _currentUser.copyWith(avatarKey: '');
//
//       Future.wait([
//       _storageRepo.deleteImageFromStorage(fileName),
//         _logic.updateUserInfo(updatedUser: updatedUser)
//       ]);
//
//       setState(() {
//         Scaffold.of(context).showSnackBar(SnackBar(content: Text('Pic Deleted')));
//       });
//
//       // await _storageRepo.deleteImageFromStorage(fileName);
//
//     } catch (e) {
//       _error = e.toString();
//     }
//
//
//   }
//
//   Future<void> _retrievePicFromDB(BuildContext context) async {
//
//
//     String fileName = _currentUserId;
//
//     try {
//
//
//       Image? currentProfileImage = await _storageRepo.getImageFromStorage(fileName);
//       print(currentProfileImage);
//
//       // return currentProfileImage;
//
//       setState(() {
//         _currentImageInDB = currentProfileImage;
//         print('Image Path: $_selectedImage');
//       });
//
//
//       setState(() {
//         Scaffold.of(context).showSnackBar(SnackBar(content: Text('Pic Retrieved')));
//       });
//
//     } catch (e) {
//       _error = e.toString();
//     }
//
//   }
//
//
//   Future<void> openImagePicker({required ImageSource imageSource}) async {
//     try{
//       final pickedImage = await ImagePicker().getImage(source: imageSource, maxWidth: 1024, maxHeight: 1024);
//       if (pickedImage == null) return; // if no image picked - not changing anything
//
//       setState(() {
//         _selectedImage = File(pickedImage.path);
//         print('Image Path: $_selectedImage');
//       });
//
//     } catch (e) {
//       print(e);
//
//       setState(() {
//         _error = e.toString();
//       });
//     }
//   }
//
//
//   void _showImageSourceActionSheet() {
//
//     Function(ImageSource) selectImageSource = (imageSource) {
//
//       openImagePicker(imageSource: imageSource);
//
//     };
//
//     if (Platform.isIOS) {
//       showCupertinoModalPopup(
//         context: context,
//         builder: (context) =>
//             CupertinoActionSheet(
//               actions: [
//                 CupertinoActionSheetAction(
//                   child: Text('Camera'),
//                   onPressed: () {
//                     Navigator.pop(context);
//                     selectImageSource(ImageSource.camera);
//                   },
//                 ),
//                 CupertinoActionSheetAction(
//                   child: Text('Gallery'),
//                   onPressed: () {
//                     Navigator.pop(context);
//                     selectImageSource(ImageSource.gallery);
//                   },
//                 )
//               ],
//             ),
//       );
//     } else {
//       showModalBottomSheet(
//         context: context,
//         builder: (context) =>
//             Wrap(children: [
//               ListTile(
//                 leading: Icon(Icons.camera_alt),
//                 title: Text('Camera'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   selectImageSource(ImageSource.camera);
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.photo_album),
//                 title: Text('Gallery'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   selectImageSource(ImageSource.gallery);
//                 },
//               ),
//             ]),
//       );
//     }
//   }
//
//
// }