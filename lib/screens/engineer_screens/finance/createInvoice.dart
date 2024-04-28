import 'package:amir_khan1/components/my_button.dart';
import 'package:amir_khan1/components/mytextfield.dart';
import 'package:amir_khan1/controllers/addActivityController.dart';
import 'package:amir_khan1/screens/consultant_screens/finance/colors.dart';
import 'package:amir_khan1/screens/engineer_screens/finance/backend/engViewModel.dart';
import 'package:amir_khan1/screens/engineer_screens/finance/backend/receipt.dart';
import 'package:amir_khan1/screens/engineer_screens/finance/financeController.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateInvoicePage extends StatefulWidget {
  CreateInvoicePage({required this.projectCreatedByContr, super.key});
  bool projectCreatedByContr;
  @override
  State<CreateInvoicePage> createState() => _CreateInvoicePageState();
}

class _CreateInvoicePageState extends State<CreateInvoicePage> {
  final dcontroller = Get.put(AddActivityController());
  final namecontroller = TextEditingController();
  final amountcontroller = TextEditingController();
  final amountPaidController = TextEditingController();
  List fileInformation = [];
  @override
  Widget build(BuildContext context) {
    final financeController = Get.put(FinanceController());
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Create Invoice',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Obx(
              () => Padding(
            padding: const EdgeInsets.all(18.0),
            child: Container(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        const SizedBox(
                          height: 25,
                          width: double.infinity,
                          child: Padding(
                            padding: EdgeInsets.only(left: 6.0),
                            child: Text(
                              'Name',
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.blueGrey),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        MyTextField(
                          hintText: 'IPC 1',
                          obscureText: false,
                          controller: namecontroller,
                          icon: Icons.money,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 10),
                        const SizedBox(
                          height: 25,
                          width: double.infinity,
                          child: Padding(
                            padding: EdgeInsets.only(left: 6.0),
                            child: Text(
                              'Amount Requested',
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.blueGrey),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        MyTextField(
                          hintText: 'Rs 321,234,333',
                          obscureText: false,
                          controller: amountcontroller,
                          icon: Icons.money,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 10),
                        const SizedBox(
                          height: 25,
                          width: double.infinity,
                          child: Padding(
                            padding: EdgeInsets.only(left: 6.0),
                            child: Text(
                              'Date of Request',
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.blueGrey),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        MyDateField(
                            hintText: dcontroller.requestDate == null
                                ? 'Request Date'
                                : '${dcontroller.requestDate!.value.toLocal()}'
                                .split(' ')[0],
                            callback: dcontroller.RequestDate),
                        const SizedBox(height: 10),
                        widget.projectCreatedByContr
                            ? Column(
                          children: [
                            const SizedBox(
                              height: 25,
                              width: double.infinity,
                              child: Padding(
                                padding: EdgeInsets.only(left: 6.0),
                                child: Text(
                                  'Amount Paid',
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.blueGrey),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            MyTextField(
                              hintText: 'Rs 321,234,333',
                              obscureText: false,
                              controller: amountPaidController,
                              icon: Icons.money,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 10),
                            const SizedBox(
                              height: 25,
                              width: double.infinity,
                              child: Padding(
                                padding: EdgeInsets.only(left: 6.0),
                                child: Text(
                                  'Date of Approval',
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.blueGrey),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            MyDateField(
                                hintText: dcontroller.approvalDate == null
                                    ? 'Approval Date'
                                    : '${dcontroller.approvalDate!.value.toLocal()}'
                                    .split(' ')[0],
                                callback: dcontroller.ApprovalDate),
                            const SizedBox(height: 10),
                          ],
                        )
                            : SizedBox(),
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
                          height: 5,
                        ),
                        MyButton(
                          text: 'Confirm',
                          bgColor: Colour().lightGreen,
                          textColor: Colors.black,
                          icon: Icons.receipt,
                          onTap: () async {
                            try {
                              if (!widget.projectCreatedByContr) {
                                Query().generateInvoiceForCnsltProject(
                                    namecontroller.text,
                                    amountcontroller.text,
                                    dcontroller.requestDate!.value,
                                    fileInformation);
                              } else if (widget.projectCreatedByContr) {
                                Query().generateInvoiceForContrProject(
                                    namecontroller.text,
                                    amountcontroller.text,
                                    dcontroller.requestDate!.value,
                                    amountPaidController.text,
                                    dcontroller.approvalDate!.value
                                    ,fileInformation
                                );
                                await Query().updateReceivedMoney(
                                    amountPaidController.text);
                              }
                              Navigator.pop(context, true);

                              namecontroller.clear();
                              amountcontroller.clear();
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
            ),
          ),
        ),
      ),
    );
  }
}