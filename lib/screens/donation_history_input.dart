import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../firebase_Service.dart/firebase_dataBase_services.dart';
import '../model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DonationInputDialog extends StatefulWidget {
  final DonorModel donorModel;

  const DonationInputDialog({super.key, required this.donorModel});

  @override
  _DonationInputDialogState createState() => _DonationInputDialogState();
}

class _DonationInputDialogState extends State<DonationInputDialog> {
  final TextEditingController donationDateController = TextEditingController();
  final TextEditingController bloodVolumeController = TextEditingController();
  String? _dateError;
  String? _volumeError;

  final int _minVolume = 200;
  final int _maxVolume = 500;

  final FirebaseDatabaseServices _databaseServices = FirebaseDatabaseServices();
  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
  }

void _validateAndSubmit() {
  setState(() {
    _dateError = null;
    _volumeError = null;
  });

  if (donationDateController.text.isEmpty) {
    setState(() {
      _dateError = 'Please select a donation date';
    });
    return;
  }

  DateTime selectedDate = DateTime.parse(donationDateController.text);

  // Check if the new donation date is at least 2 months after the last donation
  if (widget.donorModel.lastDonationDate != null) {
    DateTime minNextDonationDate = widget.donorModel.lastDonationDate!.add(const Duration(days: 60));
    if (selectedDate.isBefore(minNextDonationDate)) {
      setState(() {
        _dateError = 'Next donation date must be at least 2 months after the last donation';
      });
      return;
    }
  }

  int? volume = int.tryParse(bloodVolumeController.text);
  if (volume == null || volume <= 0) {
    setState(() {
      _volumeError = 'Please enter a valid positive volume';
    });
    return;
  }

  if (volume < _minVolume || volume > _maxVolume) {
    setState(() {
      _volumeError = 'Volume must be between $_minVolume ml and $_maxVolume ml';
    });
    return;
  }

  updateDonationDetails(selectedDate, volume);
  Navigator.of(context).pop();
}


  Future<void> updateDonationDetails(DateTime donationDate, int volume) async {
    DonorModel updatedDonor = widget.donorModel;
    updatedDonor.totalDonations += 1;
    updatedDonor.totalMonetary += volume;

    updatedDonor.firstDonationDate ??= donationDate;

    updatedDonor.lastDonationDate = donationDate;

      // Add donation history
    updatedDonor.donationHistory ??= [];
    updatedDonor.donationHistory.add({
      'date': DateFormat('yyyy-MM-dd').format(donationDate),
      'volume': volume,
    });

    await _databaseServices.updateDonorsUsingId(
      context: context,
      uid: currentUser!.uid,
      donorModel: updatedDonor,
    );

    print('Donor data updated successfully');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Donation Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: donationDateController,
            decoration: InputDecoration(
              labelText: 'Donation Date',
              errorText: _dateError,
            ),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              donationDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate!);
                        },
            readOnly: true,
          ),
          TextField(
            controller: bloodVolumeController,
            decoration: InputDecoration(
              labelText: 'Volume (ml)',
              errorText: _volumeError,
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _validateAndSubmit,
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
