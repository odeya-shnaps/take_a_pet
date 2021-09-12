

import 'package:cloud_firestore/cloud_firestore.dart';

class AnimalProfile {

  final String id;
  final String type; // dog\cat

  final String name;
  final double age;

  final String gender;
  final String size;
  final List<String> color;

  final String location;
  final Timestamp createdAt;

  final String creatorId;

  final bool isAdopted;
  final bool isDeleted;

  final List<String> qualities;

  // not necessary
  final String? breed;
  final bool? isTrained;
  final String? about;

  final int likesNum;

  //int rating = 0;

  int getLikes() {
    return this.likesNum;
  }

  String getBreed() {
    return this.breed == null ? "" : this.breed.toString();
  }

  String getIsTrained() {
    if (this.isTrained == null) {
      return "";
    }
    if (this.isTrained.toString() == "true") {
      return "Trained";
    }
    return "Not Trained";
  }

  String getStringAge(double age) {
    try {
      String str = "";
      var splitNum = age.toString().split('.');
      int year = int.tryParse(splitNum[0]) ?? 0;

      if (year > 1) {
        str += year.toString() + " years ";
      }
      if (year == 1) {
        str += year.toString() + " year ";
      }

      if (splitNum.length > 1) {
        int subMonth = splitNum[1].length > 2 ? 2 : splitNum[1].length;
        int month = int.tryParse(splitNum[1].substring(0, subMonth)) ?? 0;
        int day = int.tryParse(splitNum[1].substring(subMonth)) ?? 0;

        if (month > 1 && month <= 12) {
          str += month.toString() + " months ";
        }
        if (month == 1) {
          str += month.toString() + " month ";
        }
        if (day > 1 && day <= 31) {
          str += day.toString() + " days ";
        }
        if (day == 1) {
          str += day.toString() + " day ";
        }
      }
      return str;
    } catch(e) {
      return "";
    }
  }

  String getAbout() {
    return this.about == null ? "" : this.about.toString();
  }

  const AnimalProfile._internal(
  {
    required this.id,
    required this.type,
    required this.name,
    required this.age,
    // required this.image,
    required this.gender,
    required this.size,
    required this.color,
    required this.location,
    required this.createdAt,
    required this.creatorId,
    required this.isAdopted,
    required this.isDeleted,
    required this.qualities,

    this.breed,
    this.isTrained,
    this.about,

    required this.likesNum
  });


  factory AnimalProfile(
  {
    required String id,
    required String type,
    required String name,
    required double age,
    // required String image,
    required String gender,
    required String size,
    required List<String> color,
    required String location,
    required Timestamp createdAt,
    required String creatorId,
    required bool isAdopted,
    required bool isDeleted,
    required List<String> qualities,

    String? breed,
    bool? isTrained,
    String? about,

    required int likesNum,


  }) {
    return AnimalProfile._internal(
      id: id,
      type: type,
      name: name,
      age: age,
      // image: image,
      gender: gender,
      size: size,
      color: color,
      location: location,
      createdAt: createdAt,
      creatorId: creatorId,
      isAdopted: isAdopted,
      isDeleted: isDeleted,
      qualities: qualities,

      breed: breed,
      isTrained: isTrained,
      about: about,

      likesNum: likesNum,
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
    return other is AnimalProfile &&
        id == other.id &&
        type == other.type &&
        name == other.name &&
        age == other.age &&
        // image == other.image &&
        gender == other.gender &&
        size == other.size &&
        ListEquality().equals(color, other.color) &&

        location == other.location &&
        createdAt == other.createdAt &&
        creatorId == other.creatorId &&
        isAdopted == other.isAdopted &&
        isDeleted == other.isDeleted &&
        //rating == other.rating &&
        breed == other.breed &&
        isTrained == other.isTrained &&
        about == other.about &&
        ListEquality().equals(qualities, other.qualities) &&

    likesNum == other.likesNum;
  }


  @override
  int get hashCode => toString().hashCode;


  AnimalProfile copyWith(
  {
    String? id,
    String? type,
    String? name,
    double? age,
    // String? image,
    String? gender,
    String? size,
    List<String>? color,
    String? location,
    Timestamp? createdAt,
    String? creatorId,
    bool? isAdopted,
    bool? isDeleted,
    List<String>? qualities,

    String? breed,
    bool? isTrained,
    String? about,

    int? likesNum

    //int? rating
  }) {
    return AnimalProfile(
      // creating an object with the new info
        id: id ?? this.id,
        type: type ?? this.type,
        name: name ?? this.name,
        age: age ?? this.age,
        gender: gender ?? this.gender,
        size: size ?? this.size,
        color: color ?? this.color,
        location: location ?? this.location,
        createdAt: createdAt ?? this.createdAt,
        creatorId: creatorId ?? this.creatorId,
        isAdopted: isAdopted ?? this.isAdopted,
        isDeleted: isDeleted ?? this.isDeleted,
        qualities: qualities ?? this.qualities,

        breed: breed ?? this.breed,
        isTrained: isTrained ?? this.isTrained,
        about: about ?? this.about,

        likesNum: likesNum ?? this.likesNum

        //rating: rating ?? this.rating
    );
  }



  Map<String, dynamic> toJson() => {
    'about': about,
    'age': age,
    'breed': breed,
    'color': color,
    'createdAt': createdAt,
    'creatorId': creatorId,
    'gender': gender,
    'isAdopted': isAdopted,
    'isDeleted': isDeleted,
    'isTrained': isTrained,
    'location': location,
    'name': name,
    'qualities': qualities,
    'size': size,
    'type': type,

    'likes': likesNum,

    //'rating': rating
  };


  AnimalProfile.fromSnapshot(DocumentSnapshot snap)
      : id = snap.id,
      type = snap.get('type'),
      name = snap.get('name'),
      age = snap.get('age').toDouble(),
      gender = snap.get('gender'),
      size = snap.get('size'),
      color = List.castFrom(snap.get('color')),
      location = snap.get('location'),
      createdAt = snap.get('createdAt'),
      creatorId = snap.get('creatorId'),
      isAdopted = snap.get('isAdopted'),
      isDeleted = snap.get('isDeleted'),
      //rating = snap.get('rating'),
      breed = snap.get('breed'),
      isTrained = snap.get('isTrained'),
      about = snap.get('about'),
      qualities = List.castFrom(snap.get('qualities')),

        likesNum = snap.get('likes')
  ;


  void addToColorsList (String color) {
    this.color.add(color);
  }

  void addToQualitiesList (String quality) {
    this.qualities.add(quality);
  }


  // void increaseLikes () {
  //   this.likesNum += 1;
  // }

/*
  void increaseRating()
  {
    this.rating++;
  }*/
}