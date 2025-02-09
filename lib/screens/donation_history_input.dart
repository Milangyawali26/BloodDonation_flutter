import 'package:flutter/material.dart';

class DonationInputDialog extends StatefulWidget {
  final Function(String, String) onSubmit;

  const DonationInputDialog({super.key, required this.onSubmit});

  @override
  _DonationInputDialogState createState() => _DonationInputDialogState();
}

class _DonationInputDialogState extends State<DonationInputDialog> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _volumeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Donation Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _dateController,
            decoration: const InputDecoration(labelText: 'Donation Date'),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                _dateController.text = pickedDate.toString().split(' ')[0];
              }
            },
            readOnly: true,
          ),
          TextField(
            controller: _volumeController,
            decoration: const InputDecoration(labelText: 'Volume (ml)'),
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
          onPressed: () {
            widget.onSubmit(_dateController.text, _volumeController.text);
            Navigator.of(context).pop();
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
