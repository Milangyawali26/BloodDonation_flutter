import 'package:blood_app/firebase_authService.dart/firebase_dataBase_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:blood_app/model/user_model.dart';

class DonorProfile extends StatefulWidget {
  const DonorProfile({super.key});

  @override
  State<DonorProfile> createState() => _DonorProfileState();
}

class _DonorProfileState extends State<DonorProfile> {
  final FirebaseDatabaseServices _databaseServices = FirebaseDatabaseServices();
  User? currentUser = FirebaseAuth.instance.currentUser;
  DonorModel? donorModel;

  @override
  void initState() {
    super.initState();
    fetchDonorDetails();
  }

  void fetchDonorDetails() async {
    if (currentUser != null) {
      String uid = currentUser!.uid;
      DonorModel? donor = await _databaseServices.getDonorDetailsFromId(uid: uid);
      setState(() {
        donorModel = donor;
      });
      if (donor != null) {
        print('Donor Found: ${donor.fullName}');
      } else {
        print('Donor not registered');
      }
    } else {
      print('No User ID found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donor Profile'),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: donorModel == null
            ? const Center(child:(Text(" you are have not registered yourself as donor yet. ")))
            : Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    child: BasicDetails(donorModel: donorModel),
                  ),
                ],
              ),
      ),
    );
  }
}

class BasicDetails extends StatelessWidget {
  const BasicDetails({super.key, required this.donorModel});

  final DonorModel? donorModel;

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
        ],
      ),
    );
  }
}
