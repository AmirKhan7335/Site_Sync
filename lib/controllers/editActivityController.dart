import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class EditActivityController extends GetxController {
  Rx<DateTime>? selectedDate = DateTime.now().obs;
  Rx<DateTime>? endDate = DateTime.now().obs;

  void SelectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate!.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      selectedDate!.value = picked;
      // Update the UI immediately after selecting the date
      _updateDateTextField(picked);
    }
  }

  void EndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate!.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      endDate!.value = picked;
      // Update the UI immediately after selecting the date
      _updateEndDateTextField(picked);
    }
  }

  void _updateDateTextField(DateTime pickedDate) {
    // Find the text field's controller using GetX's Get.find method
    final TextEditingController controller = Get.find<TextEditingController>();
    final formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
    // Update the text field with the newly selected date
    controller.text = formattedDate;
  }

  void _updateEndDateTextField(DateTime pickedDate) {
    // Find the text field's controller using GetX's Get.find method
    final TextEditingController controller = Get.find<TextEditingController>();
    final formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
    // Update the text field with the newly selected date
    controller.text = formattedDate;
  }
}
