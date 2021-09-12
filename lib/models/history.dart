import 'package:collection/collection.dart';


class History {

  List<String> profilesId;
  List<String> labelsSearched;
  List<String> animalsTypes;


  History({required this.profilesId, required this.labelsSearched, required this.animalsTypes});




  bool equals(Object other) {
    return this == other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    // comparing all fields
    return other is History &&
        ListEquality().equals(profilesId, other.profilesId) &&
        ListEquality().equals(labelsSearched, other.labelsSearched) &&
        ListEquality().equals(animalsTypes, other.animalsTypes);
  }

  @override
  int get hashCode => toString().hashCode;



  Map<String, dynamic> toMap() => {
    'profilesId': this.profilesId,
    'labelsSearched': this.labelsSearched,
    'animalsTypes' : this.animalsTypes
  };



  static History fromMap(Map<String, dynamic> map) {
    try {
      List<dynamic>? profiles = map['profilesId'] ?? null;
      List<dynamic>? labels = map['labelsSearched'] ?? null;
      List<dynamic>? animals = map['animalsTypes'] ?? null;

      if (profiles != null && labels != null && animals != null) {
        return History(profilesId: List.castFrom(profiles),
            labelsSearched: List.castFrom(labels), animalsTypes: List.castFrom(animals));
      }
      throw 'invalid db schema';

    } catch (e){
      throw e;
    }

  }


  void addToHistory (String? profileId, String? label, String? animalType) {
    if(profileId != null) {
      if (!this.profilesId.contains(profileId)) {
        this.profilesId.add(profileId);
      }
      if (this.profilesId.length > 100) {
        this.profilesId.removeAt(0);
      }
    }

    if(label != null) {
      this.labelsSearched.add(label);
    }

    if(animalType != null) {
      this.animalsTypes.add(animalType);
    }
  }

  bool removeFromProfileList(String profileId) {
    return this.profilesId.remove(profileId);
  }

}