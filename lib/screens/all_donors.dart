import 'package:flutter/material.dart';
import '../firebase_authService.dart/firebase_dataBase_services.dart';
import '../model/user_model.dart';
class AllDonorsScreen extends StatelessWidget {
  final FirebaseDatabaseServices firebaseDatabaseServices = FirebaseDatabaseServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Donors"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: FutureBuilder<List<DonorModel>>(
        future: firebaseDatabaseServices.getDonorsFromDatabase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No donors found. Please check back later."));
          } else {
            List<DonorModel> donors = snapshot.data!;
            return ListView.builder(
              itemCount: donors.length,
              itemBuilder: (context, index) {
                DonorModel donor = donors[index];
                return Container(
                  margin: const EdgeInsets.only(left: 20, right: 20, top: 5),
                  decoration:  BoxDecoration(
                    border: Border.all(color: Colors.red,),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8),
                    title: Text(donor.fullName ?? "Unknown Donor", style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      "${donor.bloodGroup ?? "N/A"} - ${donor.phoneNumber ?? "No phone"}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BasicDetails(donorModel: donor),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}


class BasicDetails extends StatelessWidget {
  const BasicDetails({super.key, required this.donorModel});

  final DonorModel? donorModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 206, 72, 72),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 139, 106, 106).withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
          color: const Color.fromARGB(255, 240, 222, 222),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 139, 106, 106).withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              donorModel != null
                  ? Text('Name: ${donorModel!.fullName}')
                  : const Text('Name: -'),
              const SizedBox(height: 5),
              donorModel != null
                  ? Text('Phone: ${donorModel!.phoneNumber}')
                  : const Text('Phone: -'),
              const SizedBox(height: 5),
              donorModel != null
                  ? Text('Date of Birth: ${donorModel!.dateOfBirth}')
                  : const Text('Date of Birth: -'),
              const SizedBox(height: 5),
              donorModel != null
                  ? Text('Province: ${donorModel!.province}')
                  : const Text('Province: -'),
              const SizedBox(height: 5),
              donorModel != null
                  ? Text('District: ${donorModel!.district}')
                  : const Text('District: -'),
              const SizedBox(height: 5),
              donorModel != null
                  ? Text('Local Government: ${donorModel!.localGovernment}')
                  : const Text('Local Government: -'),
              const SizedBox(height: 5),
              donorModel != null
                  ? Text('Gender: ${donorModel!.gender}')
                  : const Text('Gender: -'),
              const SizedBox(height: 5),
              donorModel != null
                  ? Text('Blood Group: ${donorModel!.bloodGroup}')
                  : const Text('Blood Group: -'),
            ],
          ),
        ),
      ),
    );
  }
}
