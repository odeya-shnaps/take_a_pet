

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class StorageRepository {
  static const PROFILE_IMAGES_DIRECTORY = 'profileImages/';

  final FirebaseStorage _fb = FirebaseStorage.instance;


  Future<void> uploadImageToStorage(String fileName, File image) async {
    String destinationPath = PROFILE_IMAGES_DIRECTORY+fileName;
    print('DEST '+destinationPath);

    try {
      Reference ref = _fb.ref(destinationPath);
      await ref.putFile(image);
      //ref.getDownloadURL().then((value) => print('image URL $value'));

    } on FirebaseException catch (e) {
      print('Failed saving image');
      throw e;
    } catch (e) {
      print('error occurred trying to storage image');
      return null;
    }
  }


  Future<Image?> getImageFromStorage(String fileName) async {

    String imagePath = PROFILE_IMAGES_DIRECTORY+fileName;

    try {

      Reference ref = _fb.ref(imagePath);

      print(ref);
      String? imageUrl = await ref.getDownloadURL();

      print("image reference exists "+imagePath);
      Image image = Image.network(imageUrl);
      return image;

    } on FirebaseException catch (e) {
      print('Failed getting image '+imagePath);
      print (e.code.toString());
      return null;

    } catch (e) {
      print('error occurred trying to retrieve image');
      return null;
    }

  }

  Future<void> deleteImageFromStorage(String fileName) async {
    String destinationPath = PROFILE_IMAGES_DIRECTORY+fileName;

    try {
      Reference ref = _fb.ref(destinationPath);
      await ref.delete();


    } on FirebaseException catch (e) {
      print('Failed deleting image');
      throw e;

    } catch (e) {
      print('error occurred trying to delete image');
      return null;
    }
  }




}