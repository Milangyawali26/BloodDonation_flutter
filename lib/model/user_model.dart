

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? id;
  String? fullName;
  String? signUpPhoneNumber;
  String? email;
  String? fcmToken; // New field for FCM token

  UserModel({
    this.id,
    this.fullName,
    this.signUpPhoneNumber,
    this.email,
    this.fcmToken, // Add fcmToken to constructor
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'sign Up phoneNumber': signUpPhoneNumber,
      'email': email,
      'fcmToken': fcmToken, // Include fcmToken in toJson
    };
  }

  factory UserModel.fromJson(DocumentSnapshot<Map<String, dynamic>> document) {
    final userData = document.data()!;
    return UserModel(
      id: userData['id'],
      fullName: userData['fullName'],
      signUpPhoneNumber: userData['sign Up phoneNumber'],
      email: userData['email'],
      fcmToken: userData['fcmToken'], // Add fcmToken to fromJson
    );
  }
}



class DonorModel {
  bool? isAvailable;
  String? id;
  String? fullName;
  String? phoneNumber;
  String? dateOfBirth;
  String? province;
  String? district;
  String? localGovernment;
  String? gender;
  String? bloodGroup;
  double? latitude;
  double? longitude;
  double? distance;


  // New attributes
  DateTime? lastDonationDate;
  int totalDonations; // Frequency (times)
  int totalMonetary; // Total volume in c.c.
  DateTime? firstDonationDate;
  List<Map<String, dynamic>> donationHistory; // List to store donation history


  DonorModel({
    this.isAvailable,
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
    this.distance,
    this.lastDonationDate,
    this.totalDonations = 0,
    this.totalMonetary = 0,
    this.firstDonationDate,
    this.donationHistory = const [],

  });


  Map<String, dynamic> toJson() {
    return {
      'isAvailable':isAvailable,
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,  
      'dateOfBirth': dateOfBirth,  
      'province': province,
      'district': district,
      'localGovernment': localGovernment,  
      'gender': gender,
      'bloodGroup': bloodGroup,  
      'latitude': latitude,
      'longitude': longitude,
      
      'distance':distance,
       'lastDonationDate': lastDonationDate?.toIso8601String(),
      'totalDonations': totalDonations,
      'totalMonetary': totalMonetary,
      'firstDonationDate': firstDonationDate?.toIso8601String(),
      'donationHistory': donationHistory,
    };
  }

  factory DonorModel.fromJson(DocumentSnapshot<Map<String, dynamic>> document) {
    final donorData = document.data()!;
    return DonorModel(
      isAvailable: donorData['isAvailable'],
      id: donorData['id'],
      fullName: donorData['fullName'],
      phoneNumber: donorData['phoneNumber'],  
      dateOfBirth: donorData['dateOfBirth'],  
      province: donorData['province'],
      district: donorData['district'],
      localGovernment: donorData['localGovernment'],  
      gender: donorData['gender'],
      bloodGroup: donorData['bloodGroup'],  
      latitude: donorData['latitude'],
      longitude: donorData['longitude'],
      distance: donorData['distance'],
         lastDonationDate: donorData['lastDonationDate'] != null ? DateTime.parse(donorData['lastDonationDate']) : null,
      totalDonations: donorData['totalDonations'] ?? 0,
      totalMonetary: donorData['totalMonetary'] ?? 0,
      firstDonationDate: donorData['firstDonationDate'] != null ? DateTime.parse(donorData['firstDonationDate']) : null,
      donationHistory: List<Map<String, dynamic>>.from(donorData['donationHistory'] ?? []),

    );
  }

}




class RequestModel{
  String? userId;
  String? patientName;
  String? gender;
  String? contactPersonName;
  String? phoneNumber;
  String? hospitalName;
  String? bloodGroup;
  String? requiredPint;
  String? caseDetail;
  String? province;
  String? district;
  String? localGovernment;
  String? requiredDate;
  String? requiredTime;
  String? requestId;

  RequestModel({
    this.userId,
    this.patientName,
    this.gender,
    this.contactPersonName,
    this.phoneNumber,
    this.hospitalName,
    this.bloodGroup,
    this.caseDetail,
    this.requiredDate,
    this.requiredTime,
    this.requiredPint,
    this.province,
    this.district,
    this.localGovernment,
    this.requestId,
    
  });

  Map<String,dynamic> toJson(){
    return{
      'userId':userId,
      'requestId':requestId,
      'patientName':patientName,
      'gender':gender,
      'contactPersonName':contactPersonName,
      'phoneNumber':phoneNumber,
      'hospitalName':hospitalName,
      'bloodGroup':bloodGroup,
      'caseDetail':caseDetail,
      'requiredDate':requiredDate,
      'requiredTime':requiredTime,
      'requiredPint':requiredPint,
       'province': province,
      'district': district,
      'localGovernment': localGovernment,  

    };
  }

factory RequestModel.fromJson(Map<String,dynamic> json){
  final requestData=json;
  return RequestModel(
  
    userId:requestData['userId'],
    requestId: requestData['requestId'],
    patientName: requestData['patientName'],
    gender: requestData['gender'],
    contactPersonName: requestData['contactPersonName'],
    phoneNumber: requestData['phoneNumber'],
    hospitalName: requestData['hospitalName'],
    bloodGroup: requestData['bloodGroup'],
    requiredDate: requestData['requiredDate'],
    requiredTime: requestData['requiredTime'],
    requiredPint: requestData['requiredPint'],
    caseDetail: requestData['caseDetail'],
    province: requestData['province'],
    district: requestData['district'],
    localGovernment: requestData['localGovernment'],  

  );
}
}