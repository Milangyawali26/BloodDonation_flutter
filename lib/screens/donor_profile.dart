import 'package:blood_app/firebase_Service.dart/firebase_dataBase_services.dart';
import 'package:blood_app/screens/donation_history_input.dart';
import 'package:blood_app/screens/update_donor_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:blood_app/model/user_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../firebase_Service.dart/locationService.dart';
import 'donation_history_display_screen.dart';

class DonorProfile extends StatefulWidget {
  const DonorProfile({super.key});

  @override
  State<DonorProfile> createState() => _DonorProfileState();
}

class _DonorProfileState extends State<DonorProfile> {
  String locationMessage = 'Current location of user';
  late String latitude;
  late String longitude;
  final LocationService _locationService = LocationService();
  final FirebaseDatabaseServices _databaseServices = FirebaseDatabaseServices();

  User? currentUser = FirebaseAuth.instance.currentUser;

  DonorModel? donorModel;
  bool _isLoading = true; // Add loading state flag

  @override
  void initState() {
    super.initState();
    fetchDonorDetails();
  }

  void fetchDonorDetails() async {
    if (currentUser != null) {
      String uid = currentUser!.uid;
      DonorModel? donor =
          await _databaseServices.getDonorDetailsFromId(uid: uid);
      setState(() {
        donorModel = donor;
        _isLoading = false; // Set loading to false once data is fetched
      });
      if (donor != null) {
        print('Donor Found: ${donor.fullName}');
      } else {
        print('Donor not registered');
      }
    } else {
      print('No User ID found');
      setState(() {
        _isLoading = false; // Set loading to false if no user found
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Donor Profile'),
          backgroundColor: Colors.red,
          centerTitle: true,
        ),
        body: _isLoading // Show loading indicator while loading data
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: donorModel == null
                    ? Center(
                        child: Column(
                          children: [
                            const Text(
                                "You have not registered yourself as a donor yet."),
                            Container(
                              alignment: Alignment.topLeft,
                              padding: const EdgeInsets.only(top: 20),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                                child: const Text(
                                  'Become a Donor',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushNamed('/donorRegister');
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10.0),
                                child: BasicDetails(donorModel: donorModel),
                              ),

                              //btn for update donor  details
                              Positioned(
                                top: 30.0,
                                right: 30.0,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const UpdateDonorDetails()),
                                    );
                                  },
                                  child: const Text("Update"),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Availability Toggle
                          SwitchListTile(
                            title: const Text('Is Available?'),
                            value: donorModel?.isAvailable ??
                                false, // Use null-aware operator
                            activeColor: Colors.green, // Color when switched on
                            inactiveThumbColor: Colors.red,
                            onChanged: (value) async {
                              if (donorModel != null) {
                                setState(() {
                                  donorModel!.isAvailable =
                                      value; // Update the state
                                });

                                // Update availability in Firestore
                                await _databaseServices.updateDonorsUsingId(
                                  context: context,
                                  uid: currentUser!.uid,
                                  donorModel: donorModel!,
                                );
                              }
                            },
                          ),

                          const SizedBox(height: 20),

                          // Button to add donation
                          ElevatedButton(
                            onPressed: () {
                              {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return DonationInputDialog(
                                      donorModel: donorModel!,
                                 
                                    );
                                  },
                                );
                              } 
                            
                            },
                            child: const Text('Add Donation'),
                          ),

                          const SizedBox(height: 20),

                          // Button to view donation history
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DonationHistoryScreen(
                                    donationHistory:
                                        donorModel!.donationHistory,
                                        
                                  ),
                                ),
                              );
                            },
                            child: const Text('View Donation History'),
                          ),

                          const SizedBox(height: 20),

                          // Get current location of donor
                          SizedBox(
                            height: 60,
                            width: 200,
                            child: ElevatedButton(
                              onPressed: () async {
                                try {
                                  Position position = await _locationService
                                      .getCurrentLocation();
                                  latitude = '${position.latitude}';
                                  longitude = '${position.longitude}';

                                  if (currentUser != null) {
                                    String uid = currentUser!.uid;

                                    // Update donor's latitude in Firebase
                                    donorModel!.latitude = position.latitude;
                                    donorModel!.longitude = position.longitude;

                                    await _databaseServices.updateDonorsUsingId(
                                      context: context,
                                      uid: uid,
                                      donorModel: donorModel!,
                                    );

                                    Get.snackbar(
                                      'Success',
                                      'Your current location updated successfully.',
                                    );

                                    print("Location updated successfully");
                                  }

                                  setState(() {
                                    locationMessage =
                                        'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
                                  });
                                } catch (e) {
                                  setState(() {
                                    locationMessage = 'Error: $e';
                                  });
                                }
                              },
                              child: const Text(
                                  'Click to get your current location'),
                            ),
                          ),
                        ],
                      ),
              ),
      ),
    );
  }
}

//donor detail screen
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
                Text('Name: ${donorModel?.fullName ?? '-'}'),
                const SizedBox(height: 5),
                Text('Phone: ${donorModel?.phoneNumber ?? '-'}'),
                const SizedBox(height: 5),
                Text('Date of Birth: ${donorModel?.dateOfBirth ?? '-'}'),
                const SizedBox(height: 5),
                Text('Province: ${donorModel?.province ?? '-'}'),
                const SizedBox(height: 5),
                Text('District: ${donorModel?.district ?? '-'}'),
                const SizedBox(height: 5),
                Text('Local Government: ${donorModel?.localGovernment ?? '-'}'),
                const SizedBox(height: 5),
                Text('Gender: ${donorModel?.gender ?? '-'}'),
                const SizedBox(height: 5),
                Text('Blood Group: ${donorModel?.bloodGroup ?? '-'}'),
                const SizedBox(height: 5),
                Text('latitude: ${donorModel?.latitude ?? 'null'}'),
                Text(
                    'longitude: ${donorModel?.longitude ?? 'Update the current location'}'),
                const SizedBox(height: 5),
                Text(
                    'last donation date :${donorModel?.lastDonationDate ?? 'null'}'),
                Text(
                    "total doanations : ${donorModel?.totalDonations ?? 'null'} "),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
