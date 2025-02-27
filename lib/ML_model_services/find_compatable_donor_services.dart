
import 'package:blood_app/ML_model_services/tf_Lite_services.dart';
import '../firebase_Service.dart/firebase_database_services.dart';
import '../model/user_model.dart';



class DonorService {
  final FirebaseDatabaseServices _firebaseDatabaseServices;
  final TFLiteService _tfliteService;

  DonorService(this._firebaseDatabaseServices, this._tfliteService);

  Future<List<DonorModel>> getFilteredDonors(String bloodGroup, double radius) async {
    try {
      List<DonorModel> allDonors = await _firebaseDatabaseServices.getDonorsFromDatabase();

      Map<String, List<String>> compatibility = {
        "O-": ["O-"],
        "O+": ["O-", "O+"],
        "A-": ["O-", "A-"],
        "A+": ["O-", "O+", "A-", "A+"],
        "B-": ["O-", "B-"],
        "B+": ["O-", "O+", "B-", "B+"],
        "AB-": ["O-", "A-", "B-", "AB-"],
        "AB+": ["O-", "O+", "A-", "A+", "B-", "B+", "AB-", "AB+"],
      };

      List<DonorModel> compatibleDonors = allDonors.where((donor) {
        return compatibility[bloodGroup]?.contains(donor.bloodGroup) == true &&
               (donor.distance ?? double.infinity) <= radius;
      }).toList();

      List<DonorModel> eligibleDonors = await _tfliteService.getEligibleDonors(compatibleDonors);

      print('Eligible donors this month: ${eligibleDonors.length}');
      print('Eligible donors this month: ${eligibleDonors.length}');
for (var donor in eligibleDonors) {
  print('Name: ${donor.fullName}, Phone: ${donor.phoneNumber}');
}

      
      return eligibleDonors;
    } catch (e) {
      print('Error occurred while filtering donors: $e');
      return [];
    }
  }
}
