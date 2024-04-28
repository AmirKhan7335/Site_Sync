import 'package:amir_khan1/components/my_button.dart';
import 'package:amir_khan1/components/mytextfield.dart';
import 'package:amir_khan1/controllers/addActivityController.dart';
import 'package:amir_khan1/screens/consultant_screens/finance/backend/cnsltViewModel.dart';
import 'package:amir_khan1/screens/consultant_screens/finance/colors.dart';
import 'package:amir_khan1/screens/engineer_screens/finance/backend/receipt.dart';
import 'package:amir_khan1/screens/engineer_screens/finance/financeController.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MakePayment extends StatefulWidget {
  MakePayment({required this.projectId, required this.id, super.key});
  String projectId;
  String id;
  @override
  State<MakePayment> createState() => _MakePaymentState();
}

class _MakePaymentState extends State<MakePayment> {
  final paymentController = TextEditingController();
  List fileInformation = [];

  @override
  Widget build(BuildContext context) {
    final dcontroller = Get.put(AddActivityController());

    final financeController = Get.put(FinanceController());
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Amount',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child:
        Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 10),
                MyTextField(
                  hintText: 'Rs 321,234,333',
                  obscureText: false,
                  controller: paymentController,
                  icon: Icons.money,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(
                  height: 25,
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.only(left: 6.0),
                    child: Text(
                      'Payment Date',
                      style: TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                MyDateField(
                    hintText: dcontroller.approvalDate == null
                        ? 'Payment Date'
                        : '${dcontroller.approvalDate!.value.toLocal()}'
                        .split(' ')[0],
                    callback: dcontroller.RequestDate),
                const SizedBox(height: 10),
                MyButton(
                  text: 'Attach Proof',
                  bgColor: Colour().lightGreen,
                  textColor: Colors.black,
                  icon: Icons.receipt,
                  onTap: () async {
                    try {
                      financeController.isload.value = true;
                      List fileInfo = await Receipt().uploadReceipt();
                      setState(() {
                        fileInformation = fileInfo;
                      });

                      financeController.isload.value = false;
                    } catch (e) {
                      debugPrint(e.toString());
                      Get.snackbar('Error', '${e}');
                    }
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                MyButton(
                  text: 'Confirm',
                  bgColor: Colour().lightGreen,
                  textColor: Colors.black,
                  icon: Icons.receipt,
                  onTap: () async {
                    try {
                      CnsltFinanceBackend().makePayment(
                          widget.projectId,
                          widget.id,
                          dcontroller.approvalDate!.value,
                          paymentController.text,
                          'made',
                          fileInformation
                      );

                      Get.back();

                      Navigator.pop(context, true);
                    } catch (e) {
                      Get.back();

                      debugPrint(e.toString());

                      Get.snackbar('Error', '${e}');
                    }
                  },
                ),
              ],
            ),
            financeController.isload.value
                ? Center(
              child: CircularProgressIndicator(
                color: Colors.lightGreen,
              ),
            )
                : SizedBox()
          ],
        ),


      ),
    );
  }
}