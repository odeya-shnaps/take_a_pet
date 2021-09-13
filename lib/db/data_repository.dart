import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:take_a_pet/db/auth_repository.dart';
import 'package:take_a_pet/db/db_logic.dart';
import 'package:take_a_pet/models/animal_profile.dart';

import '../models/app_user.dart';

class DataRepository {

  static const USERS_COLLECTION_NAME = 'users';
  static const ANIMALS_COLLECTION_NAME = 'animals';
  static const CONVERSATIONS_COLLECTION_NAME = 'conversations';


  final FirebaseFirestore _fb = FirebaseFirestore.instance;




  //AppUser? _user;

  ///USERS COLLECTION
  // returns the new data in the form of userData
  AppUser _appUserFromSnapshot(DocumentSnapshot? snap) {
    try {
      if(snap != null) {
        AppUser user = AppUser.fromSnapshot(snap);
        return user;
      }
      throw 'no user found in DB';

    } catch (e) {
      print('the error:');
      print(e.toString());
      throw e;
    }

  }

  // returns null if userId does not exists in DB, else retuning the AppUser
  Future<AppUser> getUserById(String? userId) async {
    try {
      if(userId == null) throw 'userId not given for getUserById search';
      DocumentReference? docRef = _fb.collection(USERS_COLLECTION_NAME).doc(userId);

      DocumentSnapshot? docData = await docRef.get();

      if (docData.exists) {
        // document exists (online/offline)
        print("document exists "+ userId);
        return _appUserFromSnapshot(docData);
      } else {
        throw "No such document!";
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> createUserInDB({required AppUser newUser}) async {
    try {
      // returns void
      await _fb.collection(USERS_COLLECTION_NAME).doc(newUser.id).set(newUser.toJson());
    } catch (e) {
      print('Failed creating new user');
      throw e;
    }
  }

  Future<void> updateUser({required AppUser updatedUser}) async {
    try {
      await _fb.collection(USERS_COLLECTION_NAME).doc(updatedUser.id).update(updatedUser.toJson());
    } catch (e) {
      print('Failed to update user details');
      throw e;
    }
  }

  ///NEED TO CHECK THIS STREAM
  Stream<List<AppUser>?> getUsersList (){
    // return a stream when there is a change in the collection
    return this._fb.collection(USERS_COLLECTION_NAME).snapshots().map(_usersListFromSnapshot);
  }


  List<AppUser>? _usersListFromSnapshot(QuerySnapshot? snapshot) {
    // no users in DB
    if(snapshot == null) {
      return null;
    }

    List<AppUser> listOfUsers = [];
    snapshot.docs.forEach((docum) {

      listOfUsers.add(AppUser.fromSnapshot(docum));
    });
    return listOfUsers;
  }



  // animals in FEED (does not contain animals the user created)
  Stream<List<AnimalProfile>?> getAnimalsList (){
    // return a stream when there is a change in the collection
    // return this._fb.collection(ANIMALS_COLLECTION_NAME).snapshots().map(animalsListFromSnapshot);

    return this._fb.collection(ANIMALS_COLLECTION_NAME).orderBy('createdAt', descending: true).snapshots().map(animalsListFromSnapshot);

  }


  Future<List<AnimalProfile>> getFeed() async {
    CollectionReference<Map<String, dynamic>> ref = this._fb.collection(ANIMALS_COLLECTION_NAME);


    List<AnimalProfile>? feedList;

    await ref.orderBy('createdAt', descending: true).get().then((querySnapshot) => {
      feedList = animalsListFromSnapshot(querySnapshot)
    });

    return feedList ?? [];

  }

  List<AnimalProfile>? animalsListFromSnapshot(QuerySnapshot? snapshot) {
    // no users in DB
    if(snapshot == null) {
      return null;
    }

    List<AnimalProfile> listOfAnimals = [];
    snapshot.docs.forEach((docum) {

      var animal = AnimalProfile.fromSnapshot(docum);
      if(animal.creatorId != AuthRepository().getCurrentUser()!.uid) {
        listOfAnimals.add(animal);
      }

    });
    return listOfAnimals;
  }



  // //animals in FEED (does not contain animals the user created)
  // Stream<List<AnimalProfile>?> getAnimalsList ({required bool feed, required bool fav, AppUser? appUser}){
  //   // return a stream when there is a change in the collection
  //   // return this._fb.collection(ANIMALS_COLLECTION_NAME).snapshots().map(animalsListFromSnapshot);
  //
  //   var st;
  //   if(feed) {
  //     st = this._fb.collection(ANIMALS_COLLECTION_NAME).orderBy('createdAt', descending: true).snapshots();
  //
  //     return st.map(feedListFromSnapshot);
  //   }
  //
  //   st = this._fb.collection(ANIMALS_COLLECTION_NAME).orderBy('createdAt', descending: true).snapshots();
  //
  //   _user = appUser;
  //   return st.map(favListFromSnapshot);
  //
  //   //return this._fb.collection(ANIMALS_COLLECTION_NAME).orderBy('createdAt', descending: true).snapshots().map(feedListFromSnapshot);
  //
  // }

  // Future<List<AnimalProfile>> getFeed() async {
  //   CollectionReference<Map<String, dynamic>> ref = this._fb.collection(ANIMALS_COLLECTION_NAME);
  //
  //
  //   List<AnimalProfile>? feedList;
  //
  //   await ref.orderBy('createdAt', descending: true).get().then((querySnapshot) => {
  //     feedList = feedListFromSnapshot(querySnapshot)
  //   });
  //
  //   return feedList ?? [];
  //
  // }

  // Future<List<AnimalProfile>> getFavorites(AppUser appUser) async {
  //   _user = appUser;
  //   CollectionReference<Map<String, dynamic>> ref = this._fb.collection(ANIMALS_COLLECTION_NAME);
  //
  //
  //   List<AnimalProfile>? favList;
  //
  //   await ref.orderBy('createdAt', descending: true).get().then((querySnapshot) => {
  //     favList = favListFromSnapshot(querySnapshot)
  //   });
  //
  //   return favList ?? [];
  //
  // }
  //
  // List<AnimalProfile>? feedListFromSnapshot(QuerySnapshot? snapshot) {
  //   // no users in DB
  //   if(snapshot == null) {
  //     return null;
  //   }
  //
  //   List<AnimalProfile> listOfAnimals = [];
  //   snapshot.docs.forEach((docum) {
  //
  //     var animal = AnimalProfile.fromSnapshot(docum);
  //     if(animal.creatorId != AuthRepository().getCurrentUser()!.uid) {
  //       listOfAnimals.add(animal);
  //     }
  //
  //   });
  //   return listOfAnimals;
  // }

  // List<AnimalProfile>? favListFromSnapshot(QuerySnapshot? snapshot) {
  //   // no users in DB
  //   if(snapshot == null) {
  //     return null;
  //   }
  //
  //   List<AnimalProfile> favAnimals = [];
  //   snapshot.docs.forEach((docum) {
  //
  //     var animal = AnimalProfile.fromSnapshot(docum);
  //     if(animal.creatorId != AuthRepository().getCurrentUser()!.uid) {
  //       List<String> _favList = [];
  //       if(_user != null) {
  //         _favList = _user!.getFavProfilesList();
  //       }
  //
  //       if(_favList.contains(animal.id)) {
  //         favAnimals.add(animal);
  //       }
  //
  //     }
  //
  //   });
  //   return favAnimals;
  // }


  ///ANIMALS COLLECTION
  AnimalProfile? _animalProfileFromSnapshot(DocumentSnapshot? snap) {
    /// maybe try catch
    try {
      if(snap != null) {
        AnimalProfile animal = AnimalProfile.fromSnapshot(snap);
        return animal;
      }
      return null;

    } catch (e) {
      print('the error:');
      print(e.toString());
      throw e;
    }

  }

  Future<AnimalProfile?> getAnimalById(String? animalId) async {
    try {
      if(animalId == null) throw 'userId not given for getUserById search';
      DocumentReference? docRef = _fb.collection(ANIMALS_COLLECTION_NAME).doc(animalId);

      DocumentSnapshot? docData = await docRef.get();

      if (docData.exists) {
        // document exists (online/offline)
        print("document exists " + animalId);
        return _animalProfileFromSnapshot(docData);
      } else {
        print("No such document!");
        return null;
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> createAnimalInDB({required AnimalProfile newAnimal}) async {
    try {
      // returns void
      print('crating animal');
      await _fb.collection(ANIMALS_COLLECTION_NAME).doc(newAnimal.id).set(newAnimal.toJson());
    } catch (e) {
      print('Failed creating new animal');
      throw e;
    }
  }

  Future<void> updateAnimal({required AnimalProfile updatedAnimal}) async {
    try {
      print('update animal  ');
      await _fb.collection(ANIMALS_COLLECTION_NAME).doc(updatedAnimal.id).update(updatedAnimal.toJson());
    } catch (e) {
      print('Failed to update animal details');
      throw e;
    }
  }

  //delete document (user\animal)
  Future<void> deleteDocumentInDB(String documentName, String collectionName) async {
    try {
      //returns Future<void> when it is finished
      return await this._fb.collection(collectionName).doc(documentName).delete();
    } catch (e) {
      print('Failed to delete - contact with the App developers');
      throw e;
    }
  }

//
// Future<void> updateMessageInDB({required String conversationId, Message}) async {
//   try {
//     await _fb.collection(CONVERSATIONS_COLLECTION_NAME).doc(conversationId).set(data)
//   } catch (e) {
//     print('Failed to update user details');
//     throw e;
//   }
// }

}