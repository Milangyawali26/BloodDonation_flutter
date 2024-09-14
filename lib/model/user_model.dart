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

  factory UserModel.fromJson(
      QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final userData = document.data();
    return UserModel(
      id: userData['id'],
      fullName: userData['fullName'],
      signUpPhoneNumber: userData['sign Up phoneNumber'],
      email: userData['email'],
    );
  }
}


// class DonorModel{
//   String? fullName;
//   String? phoneNumber;
//   String? dateOFBirth;
//   String? province;
//   String? district;
//   String? localGovernment;
//   String? gender;
//   String? bloodgroup;

//   DonorModel({
//     required this.fullName,
//     required this.phoneNumber,
//     required this.dateOFBirth,
//     required this.province,
//     required this.district,
//     required this.localGovernment,
//     required this.gender,
//     required this.bloodgroup,
//   });
//   toJson(){
//     return{
//       'fullName':fullName,
//       'phone Number':phoneNumber,
//       "date of birth":dateOFBirth,
//       'province':province,
//       "district":district,
//       "local Government":district,
//       'gender':gender,
//       "Blood Group":bloodgroup,

//     };
//   }

// }