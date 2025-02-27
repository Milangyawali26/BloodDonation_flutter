
import 'package:tflite_flutter/tflite_flutter.dart';
import '../model/user_model.dart';

class TFLiteService {
  late Interpreter _interpreter;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/logistic_regression_model.tflite');

  }

  List<double> prepareDonorData(DonorModel donor) {
    final now = DateTime.now();

    int monthsSinceLastDonation = donor.lastDonationDate != null
        ? ((now.difference(donor.lastDonationDate!).inDays) / 30).floor()
        : 0;

    int monthsSinceFirstDonation = donor.firstDonationDate != null
        ? ((now.difference(donor.firstDonationDate!).inDays) / 30).floor()
        : 0;

    double totalVolumeDonated = donor.totalMonetary as double;

 
    return [
      monthsSinceLastDonation.toDouble(),
      donor.totalDonations.toDouble(),
      totalVolumeDonated,
      monthsSinceFirstDonation.toDouble(),
    //  madeDonationThisMonth.toDouble(),
    ];
  }

  Future<double> predictDonorEligibility(DonorModel donor) async {
    List<double> input = prepareDonorData(donor);
    var inputTensor = input.reshape([1, input.length]);
    var output = List.filled(1, 0).reshape([1, 1]);

    _interpreter.run(inputTensor, output);
    return output[0][0];
  }

  Future<List<DonorModel>> getEligibleDonors(List<DonorModel> donors) async {
    List<DonorModel> eligibleDonors = [];

    for (DonorModel donor in donors) {
      double prediction = await predictDonorEligibility(donor);
      if (prediction == 1 ) {
        eligibleDonors.add(donor);
      }
    }
    return eligibleDonors;

  }
}
