import 'package:blood_app/model/user_model.dart';
import 'package:blood_app/screens/updateBloodRequest.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../firebase_authService.dart/firebase_dataBase_services.dart';

class MyBloodRequest extends StatefulWidget {
  const MyBloodRequest({super.key});

  @override
  State<MyBloodRequest> createState() => _MyBloodRequestState();
}

class _MyBloodRequestState extends State<MyBloodRequest> {
  final FirebaseDatabaseServices _firebaseDatabaseServices =
      FirebaseDatabaseServices();
  User? currentUser = FirebaseAuth.instance.currentUser;
  
  // Declare a list to hold the requests
  List<RequestModel> requests = [];

  // Fetching blood requests
  Future<void> fetchRequestDetails() async {
    if (currentUser != null) {
      String uid = currentUser!.uid;
      List<RequestModel>? bloodRequest =
          await _firebaseDatabaseServices.getBloodRequestFromId(uid: uid);

      // Update state with fetched requests
      setState(() {
        requests = bloodRequest ?? [];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRequestDetails();
  }

  // Callback for deleting a request
  void _deleteRequest(String requestId, int index) async {
    if (currentUser != null) {
      String uid = currentUser!.uid;
      await _firebaseDatabaseServices.deleteBloodRequest(requestId, uid);

      // Remove the deleted request from the list and refresh UI
      setState(() {
        requests.removeAt(index);
      });
    }
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
        body: requests.isEmpty
            ? const Center(child: Text('You have not made any blood requests.'))
            : ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  return BasicDetails(
                    requestModel: requests[index],
                    onDelete: () => _deleteRequest(requests[index].requestId!, index), // Pass the onDelete callback
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
    required this.onDelete, // Add the onDelete callback
  });

  final RequestModel requestModel;
  final VoidCallback onDelete; // Callback for deletion

  @override
  Widget build(BuildContext context) {
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
                Text(
                    'Contact Person Name: ${requestModel.contactPersonName ?? "-"}'),
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
                Text(
                    'Local Government: ${requestModel.localGovernment ?? "-"}'),
                Text('Request ID: ${requestModel.requestId ?? "-"}'),
              ],
            ),
          ),
          Positioned(
            top: 30.0,
            right: 30.0,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to Update page
                String requestId = requestModel.requestId ?? '';
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UpdateBloodRequest(
                            requestId: requestId,
                          )),
                );
              },
              child: const Text("Update"),
            ),
          ),
          Positioned(
            top: 80.0,
            right: 30.0,
            child: ElevatedButton(
              onPressed: onDelete, // Use the onDelete callback here
              child: const Text("Delete"),
            ),
          ),
        ],
      ),
    );
  }
}
