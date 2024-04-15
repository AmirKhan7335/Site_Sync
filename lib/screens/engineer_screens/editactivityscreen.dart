import 'package:amir_khan1/controllers/editActivityController.dart';
import 'package:flutter/material.dart';
import 'package:amir_khan1/models/activity.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../components/my_button.dart';
import '../../components/mytextfield.dart';

class EditActivityScreen extends StatefulWidget {
  final Activity activity;
  final int index;
  final Function(Activity, int?) onSave;

  const EditActivityScreen(
      {super.key,
      required this.activity,
      required this.index,
      required this.onSave});

  @override
  EditActivityScreenState createState() => EditActivityScreenState();
}

class EditActivityScreenState extends State<EditActivityScreen> {
  late TextEditingController _nameController;
  late TextEditingController _orderController;

  @override
  void initState() {
    super.initState();
    final controller = Get.put(EditActivityController());
    _nameController = TextEditingController(text: widget.activity.name);
    controller.selectedDate!.value =
        DateFormat('dd/MM/yyyy').parse(widget.activity.startDate);
    controller.endDate!.value =
        DateFormat('dd/MM/yyyy').parse(widget.activity.finishDate);
    _orderController =
        TextEditingController(text: (widget.activity.order).toString());
  }

  @override
  void dispose() {
    _nameController.dispose();

    _orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditActivityController());
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
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              MyTextField(
                hintText: 'Activity Name',
                obscureText: false,
                controller: _nameController,
                icon: Icons.event,
                keyboardType:
                    TextInputType.text, // Use text input type for name
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Start Date',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              MyDateField(
                  hintText: controller.selectedDate == null
                      ? 'Start Date'
                      : '${controller.selectedDate!.value.toLocal()}'
                          .split(' ')[0],
                  callback: controller.SelectDate),
              const SizedBox(height: 16.0),
              const Text(
                'Finish Date',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              MyDateField(
                  hintText: controller.endDate == null
                      ? 'End Date'
                      : '${controller.endDate!.value.toLocal()}'.split(' ')[0],
                  callback: controller.EndDate),
              const SizedBox(height: 16.0),
              const Text(
                'Order',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              MyTextField(
                hintText: 'Order',
                obscureText: false,
                controller: _orderController,
                icon: Icons.format_list_numbered,
                keyboardType:
                    TextInputType.number, // Use number input type for order
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
    final controller = Get.put(EditActivityController());
    String newName = _nameController.text;
    String newStartDate =
        DateFormat('dd/MM/yyyy').format(controller.selectedDate!.value);
    String newFinishDate =
        DateFormat('dd/MM/yyyy').format(controller.endDate!.value);
    int? newOrder = int.tryParse(_orderController.text);

    if (newName.isNotEmpty &&
        newStartDate.isNotEmpty &&
        newFinishDate.isNotEmpty &&
        newOrder != null) {
      Activity updatedActivity = Activity(
        id: widget.activity.id, // Use the ID from the existing activity
        name: newName,
        startDate: newStartDate,
        finishDate: newFinishDate,
        order: newOrder,
      );

      widget.onSave(updatedActivity,
          newOrder); // Use the onSave callback to update the activity

      Navigator.pop(context,
          updatedActivity); // Pass updated activity back to previous screen
    } else {
      String errorMessage = 'Please fill all the fields';
      if (newOrder == null) errorMessage += ' and provide a valid order number';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }
}
