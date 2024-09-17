

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? id;
  String? fullName;
  String? signUpPhoneNumber;
  String? email;

  UserModel({
    this.id,
    this.fullName,
    this.signUpPhoneNumber,
    this.email,
  });

  toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'sign Up phoneNumber': signUpPhoneNumber,
      'email': email,
    };
  }

factory UserModel.fromJson(DocumentSnapshot<Map<String, dynamic>> document) {
  final userData = document.data()!;
  return UserModel(
    id: userData['id'],
    fullName: userData['fullName'],
    signUpPhoneNumber: userData['sign Up phoneNumber'],
    email: userData['email'],
  );
}

}

class DonorModel {
  String? id;
  String? fullName;
  String? phoneNumber;
  String? dateOfBirth;
  String? province;
  String? district;
  String? localGovernment;
  String? gender;
  
  String? bloodGroup;
  
  double?  latitude;
  double? longitude;


  DonorModel(  {
    this.id,
    this.fullName,
    this.phoneNumber,
    this.dateOfBirth,
    this.province,
    this.district,
    this.localGovernment,
    this.gender,
    this.bloodGroup,
    this.latitude,
    this.longitude,

    
  });
  toJson() {
    return {
      'id':id,
      'fullName': fullName,
      'phone Number': phoneNumber,
      "date of birth": dateOfBirth,
      'province': province,
      "district": district,
      "local Government": localGovernment,
      'gender': gender,
      "Blood Group": bloodGroup,
      "latitude":latitude,
      "longitude":longitude,

    };
  }

factory DonorModel.fromJson(DocumentSnapshot<Map<String, dynamic>> document) {
  final donorData = document.data()!;
  return DonorModel(
    id: donorData['id'],
    fullName: donorData['fullName'],
    phoneNumber: donorData['phone Number'],
    dateOfBirth: donorData['date of birth'],
    province: donorData['province'],
    district: donorData['district'],
    localGovernment: donorData['local Government'],
    gender: donorData['gender'],
    bloodGroup: donorData['Blood Group'],
    latitude: donorData['latitude'],
    longitude: donorData['longitude'],
  );
}

}
