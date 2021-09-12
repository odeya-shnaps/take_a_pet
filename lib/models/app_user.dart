import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:take_a_pet/models/history.dart';
import 'package:collection/collection.dart';


class AppUser {
  // final so there values will not be changed outside of this class and only in setters
  final String id;
  final String email;
  final String firstName;
  final String gender;


  final String? lastName;
  final String? avatarKey;
  final String? description;
  final Timestamp? birthday;
  // final DateTime b = new DateTime(1997,8,3);
  // final Timestamp t = new Timestamp.fromDate(b);


  /// there are repetitions - maybe it is good for recommendation Algo
  final List<String> favoriteProfilesIdList;// = [];
  final List<String> createdProfilesIdList;// = [];
  final History historyData;// = History(); // default constructor


  String getId() {
    return this.id;
  }

  String getFirstName() {
    return this.firstName;
  }

  String getGender() {
    return this.gender;
  }

  String getLastName() {
    return (this.lastName == null) ? "" : this.lastName.toString();
  }

  String getDescription() {
    return (this.description == null) ? "" : this.description.toString();
  }

  String getBirthDate() {
    if (this.birthday != null) {
      DateFormat dateFormat = DateFormat('dd/MM/yyyy');
      return dateFormat.format(this.birthday!.toDate());
    }
    return "";
  }

  // singleton - only one object is created
  const AppUser._internal(
      {
        required this.id,
        required this.email,
        required this.firstName,
        required this.gender,
        this.lastName,
        this.avatarKey,
        this.description,
        this.birthday,
        required this.favoriteProfilesIdList,
        required this.createdProfilesIdList,
        required this.historyData
      });

  factory AppUser(
      {
        required String id,
        required String email,
        required String firstName,
        String? lastName,
        required String gender,
        String? avatarKey,
        String? description,
        Timestamp? birthday,
        required List<String> favoriteProfilesIdList,
        required List<String> createdProfilesIdList,
        required History historyData
      }) {
    return AppUser._internal(
        id: id,
        email: email,
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        avatarKey: avatarKey,
        description: description,
        birthday: birthday,
        favoriteProfilesIdList: favoriteProfilesIdList,
        createdProfilesIdList: createdProfilesIdList,
        historyData: historyData
    );
  }

  // compare object
  bool equals(Object other) {
    return this == other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    // comparing all fields
    return other is AppUser &&
        id == other.id &&
        email == other.email &&
        firstName == other.firstName &&
        lastName == other.lastName &&
        gender == other.gender &&
        avatarKey == other.avatarKey &&
        description == other.description &&
        birthday == other.birthday &&
        ListEquality().equals(favoriteProfilesIdList, other.favoriteProfilesIdList) &&
        ListEquality().equals(createdProfilesIdList, other.createdProfilesIdList) &&
        historyData == other.historyData;
  }


  @override
  int get hashCode => toString().hashCode;

  AppUser copyWith(
      {
        String? id,
        String? email,
        String? firstName,
        String? lastName,
        String? gender,
        String? avatarKey,
        String? description,
        Timestamp? birthday,
        List<String>? favoriteProfilesIdList,
        List<String>? createdProfilesIdList,
        History? historyData
      }) {
    return AppUser(
      // creating an object with the new info
        id: id ?? this.id,
        email: email ?? this.email,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        gender: gender ?? this.gender,
        avatarKey: avatarKey ?? this.avatarKey,
        description: description ?? this.description,
        birthday: birthday == null ? this.birthday : birthday.toDate().isAfter(DateTime.now()) ? null : birthday, // future time means the date is deleted by the user
        favoriteProfilesIdList: favoriteProfilesIdList ?? this.favoriteProfilesIdList,
        createdProfilesIdList: createdProfilesIdList ?? this.createdProfilesIdList,
        historyData: historyData ?? this.historyData
    );
  }




  Map<String, dynamic> toJson() => {
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'gender': gender,
    'avatarKey': avatarKey,
    'description': description,
    'birthday': birthday,
    'favoriteProfiles': favoriteProfilesIdList,
    'history': historyData.toMap(),
    'createdProfiles': createdProfilesIdList,
  };

  AppUser.fromSnapshot(DocumentSnapshot snap)
      : id = snap.id,
        email = snap.get('email'),
        firstName = snap.get('firstName'),
        lastName = snap.get('lastName'),
        gender = snap.get('gender'),
        avatarKey = snap.get('avatarKey'),
        description = snap.get('description'),
        birthday = snap.get('birthday'),
        favoriteProfilesIdList = List.castFrom(snap.get('favoriteProfiles')),
        historyData = History.fromMap(snap.get('history')),
        createdProfilesIdList = List.castFrom(snap.get('createdProfiles')
        );



  void addToFavProfilesList (String profileId) {
    print('ADDED     '+ profileId);

    if (!inFavProfilesList(profileId)) {
      this.favoriteProfilesIdList.add(profileId);
    }
  }

  bool removeFromFavProfilesList (String profileId) {
    print('REMOVED  '+ profileId);
    return this.favoriteProfilesIdList.remove(profileId);
  }

  bool inFavProfilesList(String profileId) {
    return this.favoriteProfilesIdList.contains(profileId);
  }

  void addToCreatedProfilesList (String profileId) {
    this.createdProfilesIdList.add(profileId);
  }

  void removeFromCreatedProfilesList (String profileId) {
    this.createdProfilesIdList.remove(profileId);
  }

  void setHistoryData({String? profileId, String? label, String? animalType}) {
    if (!this.favoriteProfilesIdList.contains(profileId)) {
      this.historyData.addToHistory(profileId, label, animalType);
    }
  }

  bool removeAnimalProfileFromHistory(String profileId) {
    return this.historyData.removeFromProfileList(profileId);
  }

  List<String> getFavProfilesList() {
    return this.favoriteProfilesIdList;
  }

  List<String> getCreatedProfilesIdList() {
    return this.createdProfilesIdList;
  }

  String? getAvatarKey() {
    return this.avatarKey;
  }

  DateTime convertTimeStampToDate(Timestamp timestamp) {
    return timestamp.toDate();

  }

}