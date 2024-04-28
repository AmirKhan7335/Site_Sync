import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddActivityController extends GetxController{
  Rx<DateTime>? selectedDate=DateTime.now().obs;
  Rx<DateTime>? endDate=DateTime.now().obs;
  Rx<DateTime>? requestDate=DateTime.now().obs;
  Rx<DateTime>? approvalDate=DateTime.now().obs;

  Future<void> RequestDate( context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: requestDate!.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {

      selectedDate!.value = picked;

    }
  }Future<void> ApprovalDate( context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: approvalDate!.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {

      selectedDate!.value = picked;

    }
  }
  Future<void> SelectDate( context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate!.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {

      selectedDate!.value = picked;

    }
  }

  Future<void> EndDate(context) async {
    final DateTime? pick = await showDatePicker(
      context: context,
      initialDate: endDate!.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pick != null && pick != endDate) {

      endDate!.value = pick;

    }
  }

}