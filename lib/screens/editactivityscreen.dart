import 'package:flutter/material.dart';
import 'package:amir_khan1/screens/activity.dart';
import '../components/my_button.dart';
import '../components/mytextfield.dart';


class EditActivityScreen extends StatefulWidget {
  final Activity activity;
  final int index;
  final Function(Activity, int?) onSave;

  const EditActivityScreen({super.key, required this.activity, required this.index, required this.onSave});

  @override
  EditActivityScreenState createState() => EditActivityScreenState();
}

class EditActivityScreenState extends State<EditActivityScreen> {
  late TextEditingController _nameController;
  late TextEditingController _startDateController;
  late TextEditingController _finishDateController;
  late TextEditingController _orderController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.activity.name);
    _startDateController = TextEditingController(text: widget.activity.startDate);
    _finishDateController = TextEditingController(text: widget.activity.finishDate);
    _orderController = TextEditingController(text: (widget.activity.order + 1).toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startDateController.dispose();
    _finishDateController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editing Activity'),
        backgroundColor: const Color(0xFF212832),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Activity Name',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              MyTextField(
                hintText: 'Activity Name',
                obscureText: false,
                controller: _nameController,
                icon: Icons.event, keyboardType: TextInputType.text, // Use text input type for name
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Start Date',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              MyTextField(
                hintText: 'Start Date',
                obscureText: false,
                controller: _startDateController,
                icon: Icons.date_range, keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Finish Date',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              MyTextField(
                hintText: 'Finish Date',
                obscureText: false,
                controller: _finishDateController,
                icon: Icons.date_range,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Order',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              MyTextField(
                hintText: 'Order',
                obscureText: false,
                controller: _orderController,
                icon: Icons.format_list_numbered,
                keyboardType: TextInputType.number, // Use number input type for order
              ),
              const SizedBox(height: 16.0),
              MyButton(
                text: 'Save Changes',
                bgColor: Colors.yellow,
                textColor: Colors.white,
                icon: Icons.save,
                onTap: _saveActivity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveActivity() async {
    String newName = _nameController.text;
    String newStartDate = _startDateController.text;
    String newFinishDate = _finishDateController.text;
    int? newOrder = int.tryParse(_orderController.text);

    if (newName.isNotEmpty && newStartDate.isNotEmpty && newFinishDate.isNotEmpty && newOrder != null) {
      Activity updatedActivity = Activity(
        name: newName,
        startDate: newStartDate,
        finishDate: newFinishDate,
        order: newOrder - 1, // Subtract 1 here to get the actual order
      );

      widget.onSave(updatedActivity, newOrder - 1); // Use the onSave callback to update the activity

      Navigator.pop(context, updatedActivity); // Pass updated activity back to previous screen
    } else {
      String errorMessage = 'Please fill all the fields';
      if (newOrder == null) errorMessage += ' and provide a valid order number';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }
}