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

  DonorModel(  {
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.province,
    required this.district,
    required this.localGovernment,
    required this.gender,
    required this.bloodGroup,
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
  );
}

}
