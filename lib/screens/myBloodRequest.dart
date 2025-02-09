import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase_Service.dart/firebase_dataBase_services.dart';
import '../firebase_Service.dart/firebase_msgServices.dart';
import 'updateBloodRequest.dart';
import '../model/user_model.dart';

class MyBloodRequest extends StatefulWidget {
  const MyBloodRequest({super.key});

  @override
  State<MyBloodRequest> createState() => _MyBloodRequestState();
}

class _MyBloodRequestState extends State<MyBloodRequest> {
  final FirebaseDatabaseServices _firebaseDatabaseServices =
      FirebaseDatabaseServices();
  final FirebaseMsgServices _firebaseMsgServices =
      FirebaseMsgServices(); // Create an instance of FirebaseMsgServices
  User? currentUser = FirebaseAuth.instance.currentUser;
  List<RequestModel> requests = [];
  List<DonorModel> compatibleDonors = [];
  bool _isLoading = true;
  double selectedRadius = 10.0; // default radius

  Future<void> fetchRequestDetails() async {
    if (currentUser != null) {
      String uid = currentUser!.uid;
      List<RequestModel>? bloodRequest =
          await _firebaseDatabaseServices.getBloodRequestFromId(uid: uid);

      setState(() {
        requests = bloodRequest ?? [];
        _isLoading = false;
      });
    }
  }

  Future<List<DonorModel>> getFilteredDonors(
      String bloodGroup, double radius) async {
    try {
      // Get all donors
      List<DonorModel> allDonors =
          await _firebaseDatabaseServices.getDonorsFromDatabase();

      // Define compatibility rules for blood donation
      Map<String, List<String>> compatibility = {
        "O-": ["O-", "O+", "A-", "A+", "B-", "B+", "AB-", "AB+"],
        "O+": ["O+", "A+", "B+", "AB+"],
        "A-": ["A-", "A+", "AB-", "AB+"],
        "A+": ["A+", "AB+"],
        "B-": ["B-", "B+", "AB-", "AB+"],
        "B+": ["B+", "AB+"],
        "AB-": ["AB-", "AB+"],
        "AB+": ["AB+"],
      };

      // Check compatibility and filter donors by blood group and radius
      List<DonorModel> filteredDonors = allDonors.where((donor) {
        return compatibility[bloodGroup]?.contains(donor.bloodGroup) == true &&
            donor.distance! <= radius;
      }).toList();

      print('Number of compatible donors: ${filteredDonors.length}');
      return filteredDonors;
    } catch (e) {
      print('Error occurred while filtering donors: $e');
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRequestDetails();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Blood Requests"),
          backgroundColor: Colors.red,
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : requests.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('You have not made any blood requests.'),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          child: const Text(
                            'Make a Blood Request',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushNamed('/addRequest');
                          },
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      return BasicDetails(
                        requestModel: requests[index],
                        getFilteredDonors:
                            getFilteredDonors, // Pass the function here
                        onUpdateCompatibleDonors: (donors) {
                          setState(() {
                            compatibleDonors = donors;
                          });
                        },
                        sendNotifications: _firebaseMsgServices
                            .sendNotificationsToDonors, // Pass instance method here
                      );
                    },
                  ),
      ),
    );
  }
}

class BasicDetails extends StatelessWidget {
  const BasicDetails({
    super.key,
    required this.requestModel,
    required this.getFilteredDonors,
    required this.onUpdateCompatibleDonors,
    required this.sendNotifications,
  });

  final RequestModel requestModel;
  final Future<List<DonorModel>> Function(String, double) getFilteredDonors;
  final Function(List<DonorModel>) onUpdateCompatibleDonors;
  final Future<void> Function(List<String>, String) sendNotifications;

  @override
  Widget build(BuildContext context) {
    double selectedRadius = 10.0;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Patient Name: ${requestModel.patientName ?? "-"}'),
                const SizedBox(height: 5),
                Text('Patient Gender: ${requestModel.gender ?? "-"}'),
                const SizedBox(height: 5),
                Text('Blood Group: ${requestModel.bloodGroup ?? "-"}'),
                const SizedBox(height: 5),
                Text('Contact Person Name: ${requestModel.contactPersonName ?? "-"}'),
                const SizedBox(height: 5),
                Text('Phone: ${requestModel.phoneNumber ?? "-"}'),
                const SizedBox(height: 5),
                Text('Hospital Name: ${requestModel.hospitalName ?? "-"}'),
                const SizedBox(height: 5),
                Text('Required Pint: ${requestModel.requiredPint ?? "-"}'),
                const SizedBox(height: 5),
                Text('Case Detail: ${requestModel.caseDetail ?? "-"}'),
                const SizedBox(height: 5),
                Text('Required Date: ${requestModel.requiredDate ?? "-"}'),
                const SizedBox(height: 5),
                Text('Required Time: ${requestModel.requiredTime ?? "-"}'),
                const SizedBox(height: 5),
                Text('Province: ${requestModel.province ?? "-"}'),
                const SizedBox(height: 5),
                Text('District: ${requestModel.district ?? "-"}'),
                const SizedBox(height: 5),
                Text('Local Government: ${requestModel.localGovernment ?? "-"}'),
                const SizedBox(height: 5),
                Text('Request ID: ${requestModel.requestId ?? "-"}'),
              ],
            ),
          ),
          Positioned(
            top: 30.0,
            right: 30.0,

            //btn for update
            child: ElevatedButton(
              onPressed: () {
                String requestId = requestModel.requestId ?? '';
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UpdateBloodRequest(requestId: requestId),
                  ),
                );
              },
              child: const Text("Update"),
            ),
          ),
          Positioned(
            top: 80.0,
            right: 30.0,
            // btn for delete
            child: ElevatedButton(
              onPressed: () async {
                String requestId = requestModel.requestId ?? '';
                try {
                  User? currentUser = FirebaseAuth.instance.currentUser;
                  if (currentUser != null) {
                    await FirebaseDatabaseServices.deleteBloodRequest(
                      requestId,
                      currentUser.uid,
                    );
                  }
                } catch (e) {
                  Get.snackbar("Error occurred", e.toString());
                }
              },
              child: const Text("Delete"),
            ),
          ),
          Positioned(
            top: 130.0,
            right: 30.0,
            child: urgentButton(
                context,
                requestModel,
                getFilteredDonors,
                onUpdateCompatibleDonors,
                sendNotifications), // Pass the function and callback here
          ),
        ],
      ),
    );
  }
}

Widget urgentButton(
  BuildContext context,
  RequestModel requestModel,
  Future<List<DonorModel>> Function(String, double) getFilteredDonors,
  Function(List<DonorModel>) onUpdateCompatibleDonors,
  Future<void> Function(List<String>, String) sendNotifications,
) {
  double selectedRadius = 10.0;

  return ElevatedButton(
    onPressed: () {
      showDialog<double>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Select Radius"),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Slider(
                      value: selectedRadius,
                      min: 1,
                      max: 50,
                      divisions: 49,
                      label: "${selectedRadius.toInt()} km",
                      onChanged: (value) {
                        setState(() {
                          selectedRadius = value;
                        });
                      },
                    ),
                    Text(
                      "Selected Radius: ${selectedRadius.toInt()} km",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pop(); // Close without returning a value
                },
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context)
                      .pop(selectedRadius); // Return the selected radius
                  List<DonorModel> filteredDonors = await getFilteredDonors(
                      requestModel.bloodGroup ?? "", selectedRadius);
                  onUpdateCompatibleDonors(
                      filteredDonors); // Update the donors list in the parent widget

                  // Collect userIds of compatible donors
                  List<String> userIds = filteredDonors
                      .map((donor) => donor.id!)
                      .toList(); // Use donor.id

                  print(
                      "number of conpatible donors of which userIds  collected ${userIds.length}");
                  
                  // Send notifications to the compatible donors
                  await sendNotifications(userIds,
                      'Blood request: ${requestModel.patientName} needs blood.');

                  Navigator.pop(context);
                },
                child: const Text("Confirm"),
              ),
            ],
          );
        },
      );
    },
    child: const Text("Find Compatible Donors"),
  );
}
