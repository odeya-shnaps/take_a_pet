
import 'package:firebase_auth/firebase_auth.dart';
import 'package:take_a_pet/db/auth_repository.dart';
import 'package:take_a_pet/db/data_repository.dart';
import 'package:take_a_pet/db/storage_repository.dart';
import 'package:take_a_pet/models/app_user.dart';
import 'package:take_a_pet/models/history.dart';

class DBLogic {

  final AuthRepository _authRepo = AuthRepository();
  final DataRepository _dbRepo = DataRepository();
  final StorageRepository _storageRepo = new StorageRepository();


  User? getCurrentUser () {
    return _authRepo.getCurrentUser();
  }

  /// ACCOUNT LOG IN METHODS
  Future<AppUser> registration ({required String email, required String password,
    required String firstName, required String lastName, required gender} ) async {

    try{
      User user = await _authRepo.registerWithEmailAndPassword(email, password);

      // if getting here - registration succeeded
      //creating costumed AppUser for the new FB User
      AppUser appUser = AppUser(id: user.uid, email: email,
          firstName: firstName, lastName: lastName, gender: gender,
          favoriteProfilesIdList: [], createdProfilesIdList: [],
          historyData: History(labelsSearched: [], profilesId: [],
              animalsTypes: []));


      // CREATING new document for the user in the DB
      _dbRepo.createUserInDB(newUser: appUser);

      return appUser;

    } catch (e) {
      throw e;
    }
  }



  Future<AppUser> logIn ({required String email, required String password}) async {
    // returning the error or AppUser
    try {
      User user = await this._authRepo.signInWithEmailAndPassword(email, password);
      // if we got here - the login succeeded
      AppUser? appUser = await _dbRepo.getUserById(user.uid);

      // user is found in DB
      return appUser;

    } catch (e) {
      throw e;
    }
  }


  /// ACCOUNT MANAGEMENT METHODS
  Future<void> deleteUser({required String uid}) async {
    try {
      await Future.wait([
        this._dbRepo.deleteDocumentInDB(uid, DataRepository.USERS_COLLECTION_NAME),
        this._authRepo.deleteUser()
      ]);
    } catch (e) {
      throw e;
    }
  }


  Stream<User?> listenToUserAuth () {
    return _authRepo.userAuthChange();
  }

  Future<void> updateUserInfo({required AppUser updatedUser}) async {
    try {
      await _dbRepo.updateUser(updatedUser: updatedUser);
    } catch (e) {
      print('Failed to update user details');
      throw e;
    }
  }


  Future<AppUser> getUserById(String? userId) async {
    try {
      return _dbRepo.getUserById(userId);
    } catch (e) {
      throw e;
    }
  }

  Future<void> deleteAnimalProfile({required String animalId, required String creatorId}) async {
    try {
      AppUser creator = await this.getUserById(creatorId);
      // remove profile from created profiles list of the user that created the profile
      creator.removeFromCreatedProfilesList(animalId);
      await updateUserInfo(updatedUser: creator);
      var allUsers = await this._dbRepo.getUsersList().first;
      // for each user remove the profile from it's favorites or history and update the user.
      allUsers!.forEach((user) {
        bool inFav = user.removeAnimalProfileFromHistory(animalId);
        bool inHistory = user.removeFromFavProfilesList(animalId);
        if (inHistory || inFav) {
          updateUserInfo(updatedUser: user);
        }
      });

      // Future.wait(
      //     [
      //       // try {
      //       this._storageRepo.deleteImageFromStorage(animalId),
      //       this._dbRepo.deleteDocumentInDB(animalId, DataRepository.ANIMALS_COLLECTION_NAME),
      //
      //     ]
      //
      // );

      await this._storageRepo.deleteImageFromStorage(animalId);

      // delete animal doc and profile image
      await this._dbRepo.deleteDocumentInDB(animalId, DataRepository.ANIMALS_COLLECTION_NAME);
      // try {
      // } catch (e) {
      // }
    } catch (e) {
      throw e;
    }
  }



// Future<void> setMessageIsRead(String messageId) async {
//   try {
//     await _dbRepo.updateUser(updatedUser: updatedUser);
//   } catch (e) {
//     throw e;
//   }
// }

}