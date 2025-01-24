import 'package:blood_app/constants/bloodgroups.dart';
import 'package:blood_app/constants/province_district_localgovern_data.dart';
import 'package:flutter/material.dart';
import '../firebase_authService.dart/firebase_dataBase_services.dart';
import '../model/user_model.dart';

class Searchdonors extends StatefulWidget {
  const Searchdonors({super.key});

  @override
  _SearchdonorsState createState() => _SearchdonorsState();
}

class _SearchdonorsState extends State<Searchdonors> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedLocalGovernment;
  String? _selectedBloodGroup;
  List<String> _districts = [];
  List<String> _localGovernments = [];
  List<DonorModel> filteredDonors = [];

  final FirebaseDatabaseServices firebaseDatabaseServices =
      FirebaseDatabaseServices();

  void _filterDonors(List<DonorModel> donors) {
    setState(() {
      filteredDonors = donors.where((donor) {
        bool matchesProvince =
            _selectedProvince == null || donor.province == _selectedProvince;
        bool matchesDistrict =
            _selectedDistrict == null || donor.district == _selectedDistrict;
        bool matchesLocalGovernment = _selectedLocalGovernment == null ||
            donor.localGovernment == _selectedLocalGovernment;
        bool matchesBloodGroup = _selectedBloodGroup == null ||
            donor.bloodGroup == _selectedBloodGroup;

        return matchesProvince &&
            matchesDistrict &&
            matchesLocalGovernment &&
            matchesBloodGroup;
      }).toList();
    });
  }

  Future<void> _fetchAndFilterDonors() async {
    List<DonorModel> donors =
        await firebaseDatabaseServices.getDonorsFromDatabase();
    _filterDonors(donors);
  }

  @override
  void initState() {
    super.initState();
    _fetchAndFilterDonors();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("All Donors"),
          backgroundColor: Colors.red,
          centerTitle: true,
        ),
        body: Column(
          children: [
            // select blood group, province, district, local government
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Blood Group Dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Blood Group',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.bloodtype),
                    ),
                    value: _selectedBloodGroup,
                    items: BloodGroup.bloodGroups.map((String bloodGroup) {
                      return DropdownMenuItem<String>(
                        value: bloodGroup,
                        child: Text(bloodGroup),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedBloodGroup = newValue;
                      });
                      _fetchAndFilterDonors(); // Refetch blood requests
                    },
                    validator: (value) =>
                        null, // Allow the field to be optional
                  ),
                  const SizedBox(height: 4),

                  // Province Dropdown
                  DropdownButtonFormField<String>(
                    isExpanded:
                        true, // Ensure the dropdown takes the full width of the parent
                    decoration: const InputDecoration(
                      labelText: 'Province',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedProvince,
                    items: LocationData.provinces.map((String province) {
                      return DropdownMenuItem<String>(
                        value: province,
                        child: Text(
                          province,
                          overflow:
                              TextOverflow.ellipsis, // Ellipsis for long text
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedProvince = newValue;
                        _districts =
                            LocationData.districtMap[_selectedProvince] ?? [];
                        _selectedDistrict = null;
                        _selectedLocalGovernment = null;
                        _localGovernments = [];
                      });
                      _fetchAndFilterDonors(); // Refetch blood requests
                    },
                    validator: (value) => null,
                  ),
                  const SizedBox(height: 4),

// District Dropdown
                  DropdownButtonFormField<String>(
                    isExpanded:
                        true, // Ensure the dropdown takes the full width of the parent
                    decoration: const InputDecoration(
                      labelText: 'District',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedDistrict,
                    items: _districts.map((String district) {
                      return DropdownMenuItem<String>(
                        value: district,
                        child: Text(
                          district,
                          overflow:
                              TextOverflow.ellipsis, // Ellipsis for long text
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedDistrict = newValue;
                        _localGovernments = LocationData
                                .localGovernmentMap[_selectedDistrict] ??
                            [];
                        _selectedLocalGovernment = null;
                      });
                      _fetchAndFilterDonors(); // Refetch blood requests
                    },
                    validator: (value) => null,
                  ),
                  const SizedBox(height: 4),

// Local Government Dropdown
                  DropdownButtonFormField<String>(
                    isExpanded:
                        true, // Ensure the dropdown takes the full width of the parent
                    decoration: const InputDecoration(
                      labelText: 'Local Government',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedLocalGovernment,
                    items: _localGovernments.map((String localGov) {
                      return DropdownMenuItem<String>(
                        value: localGov,
                        child: Text(
                          localGov,
                          overflow:
                              TextOverflow.ellipsis, // Ellipsis for long text
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedLocalGovernment = newValue;
                      });
                      _fetchAndFilterDonors(); // Refetch blood requests
                    },
                    validator: (value) => null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<DonorModel>>(
                future: firebaseDatabaseServices.getDonorsFromDatabase(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child:
                            Text("No donors found. Please check back later."));
                  } else if (filteredDonors.isEmpty) {
                    return const Center(
                        child: Text(
                            "No donors found based on your filter.\nTry checking other filters or check back later."));
                  } else {
                    return ListView.builder(
                      itemCount: filteredDonors.length,
                      itemBuilder: (context, index) {
                        DonorModel donor = filteredDonors[index];

                        return Container(
                          margin: const EdgeInsets.only(
                              left: 20, right: 20, top: 5),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red),
                            borderRadius: BorderRadius.circular(16.0),
                            color: const Color.fromARGB(255, 240, 211, 209),
                          ),
                          child: ListTile(
                            title: Text(donor.fullName ?? "Unknown Donor",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              "${donor.bloodGroup ?? "N/A"}     ${donor.phoneNumber ?? "No phone"}",
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 20, 20, 20)),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                    "${donor.distance?.toStringAsFixed(2)}+  KM away"),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      textStyle: const TextStyle(fontSize: 12),
                                    ),
                                    child: const Text("notify")),
                              ],
                            ),
                            contentPadding: const EdgeInsets.all(8),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      BasicDetails(donorModel: donor),
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
                color:
                    const Color.fromARGB(255, 139, 106, 106).withOpacity(0.5),
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
