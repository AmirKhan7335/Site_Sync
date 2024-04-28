import 'package:amir_khan1/components/my_button.dart';
import 'package:amir_khan1/components/mytextfield.dart';
import 'package:amir_khan1/screens/consultant_screens/finance/colors.dart';
import 'package:amir_khan1/screens/engineer_screens/finance/backend/engViewModel.dart'
as backEnd;
import 'package:amir_khan1/screens/engineer_screens/finance/backend/receipt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class EngInvoiceDetail extends StatefulWidget {
  EngInvoiceDetail(
      {required bool this.projCreatedbyContr,
        required bool this.isClient,
        required this.invoiceDetail,
        required this.invoiceId,
        super.key});
  bool isClient;
  bool projCreatedbyContr;
  Map invoiceDetail;
  String invoiceId;

  @override
  State<EngInvoiceDetail> createState() => _EngInvoiceDetailState();
}

class _EngInvoiceDetailState extends State<EngInvoiceDetail> {
  final controller = TextEditingController();
  final backendClass = backEnd.Query();
  final amountcontroller = TextEditingController();
  String daysLeft(requestDate,int totalDays) {
    debugPrint('1111111');
    DateTime currentDate = DateTime.now();
    debugPrint('222222');
    // Calculate the difference between the given date and the current date
    Duration difference = currentDate.difference(requestDate);
    debugPrint('3333333');
    // Extract the number of days from the duration
    int numberOfDays = difference.inDays;
    debugPrint('44444444');
    int leftDays = totalDays - numberOfDays;
    return leftDays.toString();
  }

  Widget afterPayment() {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(
              height: 25,
              child: Padding(
                padding: EdgeInsets.only(left: 6.0),
                child: Text(
                  'Payment Date',
                  style: TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            Expanded(child: SizedBox()),
            widget.projCreatedbyContr
                ? SizedBox()
                : InkWell(
              onTap: () {
                List file = widget.invoiceDetail['approvedReceipt'];

                if (file.isNotEmpty) {
                  Receipt().checkFileAndOpen(file[1], file[0]);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colour().lightGreen),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.receipt,
                        color: Colors.black,
                      ),
                      Text(
                        'Receipt ',
                        style: TextStyle(color: Colors.black),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
        MySimpleTextField(
          hintText: DateFormat('dd/MM/yyyy')
              .format(widget.invoiceDetail['approvalDate'].toDate()),
          obscureText: false,
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          readOnly: true,
        ),
        const SizedBox(height: 10),
        const SizedBox(
          height: 25,
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.only(left: 6.0),
            child: Text(
              'Amount Paid',
              style: TextStyle(fontSize: 18.0, color: Colors.blueGrey),
              textAlign: TextAlign.left,
            ),
          ),
        ),
        MySimpleTextField(
          hintText: widget.invoiceDetail['amountApproved'],
          obscureText: false,
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          readOnly: true,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          widget.invoiceDetail['name'],
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding:
        const EdgeInsets.only(left: 16.0, right: 16, bottom: 16, top: 8),
        child: SingleChildScrollView(
          child: Column(children: [
            Row(
              children: [
                Icon(
                  Icons.report,
                  color: Colors.black,
                ),
                Text(
                  'Details',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                Expanded(child: SizedBox()),
                widget.isClient
                    ? SizedBox()
                    : widget.projCreatedbyContr
                    ? SizedBox()
                    : widget.invoiceDetail['transaction'] == 'Request Sent'
                    ? SizedBox()
                    : widget.invoiceDetail['transaction'] ==
                    'Payment Sent'
                    ? SizedBox()
                    : widget.invoiceDetail['transaction'] ==
                    'Payment Accepted'
                    ? SizedBox()
                    : IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.edit),
                  color: Colors.lightGreen,
                )
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const SizedBox(
                  height: 25,
                  child: Padding(
                    padding: EdgeInsets.only(left: 6.0),
                    child: Text(
                      'Request Date',
                      style: TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Expanded(child: SizedBox()),
                widget.projCreatedbyContr
                    ? SizedBox()
                    : InkWell(
                  onTap: () {
                    List file = widget.invoiceDetail['requestReceipt'];

                    if (file.isNotEmpty) {
                      Receipt().checkFileAndOpen(file[1], file[0]);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colour().lightGreen),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.receipt,
                            color: Colors.black,
                          ),
                          Text(
                            'Receipt ',
                            style: TextStyle(color: Colors.black),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
            MySimpleTextField(
              hintText: DateFormat('dd/MM/yyyy')
                  .format(widget.invoiceDetail['requestDate'].toDate()),
              obscureText: false,
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              readOnly: true,
            ),
            const SizedBox(height: 10),
            widget.projCreatedbyContr
                ? const SizedBox(
              height: 25,
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.only(left: 6.0),
                child: Text(
                  'Amount Requested',
                  style:
                  TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                  textAlign: TextAlign.left,
                ),
              ),
            )
                : const SizedBox(
              height: 25,
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.only(left: 6.0),
                child: Text(
                  'Requested Amount',
                  style:
                  TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            MySimpleTextField(
              hintText: widget.invoiceDetail['amountRequested'],
              obscureText: false,
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              readOnly: true,
            ),
            const SizedBox(height: 10),
            widget.invoiceDetail['transaction'] == 'Make Request'
                ? SizedBox()
                : Column(
              children: [
                const SizedBox(
                  height: 25,
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.only(left: 6.0),
                    child: Text(
                      'Status',
                      style: TextStyle(
                          fontSize: 18.0, color: Colors.blueGrey),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                MySimpleTextField(
                  hintText: widget.invoiceDetail['status'],
                  obscureText: false,
                  controller: controller,
                  keyboardType: TextInputType.emailAddress,
                  readOnly: true,
                ),
                const SizedBox(height: 10),
              ],
            ),
            widget.projCreatedbyContr
                ? SizedBox()
                : widget.invoiceDetail['transaction'] == 'Make Request'
                ? SizedBox()
                : widget.invoiceDetail['transaction'] == 'Payment Accepted'
                ? SizedBox()
                : Column(
              children: [
                const SizedBox(
                  height: 25,
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.only(left: 6.0),
                    child: Text(
                      'Days Left',
                      style: TextStyle(
                          fontSize: 18.0, color: Colors.blueGrey),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                MySimpleTextField(
                  hintText:
                  daysLeft(
                      widget.invoiceDetail['requestDate']
                          .toDate(),
                      widget.invoiceDetail['daysLeft'])
                  ,
                  obscureText: false,
                  controller: controller,
                  keyboardType: TextInputType.emailAddress,
                  readOnly: true,
                ),
              ],
            ),
            const SizedBox(height: 10),
            widget.invoiceDetail['transaction'] == 'Make Request'
                ? SizedBox()
                : widget.invoiceDetail['transaction'] == 'Request Sent'
                ? SizedBox()
                : afterPayment(),
            const SizedBox(height: 10),
            widget.isClient
                ? SizedBox()
                : widget.projCreatedbyContr
                ? SizedBox()
                : widget.invoiceDetail['transaction'] == 'Request Sent'
                ? SizedBox()
                : widget.invoiceDetail['transaction'] == 'Payment Sent'
                ? SizedBox()
                : widget.invoiceDetail['transaction'] ==
                'Payment Accepted'
                ? SizedBox()
                : Row(
              children: [
                Text(
                  'Payment Shall be made with in ',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                InkWell(
                  onTap: () {
                    Get.defaultDialog(
                        title: 'Set No of Days',
                        content: Column(
                          children: [
                            MyTextField(
                              hintText: widget
                                  .invoiceDetail[
                              'daysLeft']
                                  .toString(),
                              obscureText: false,
                              controller:
                              amountcontroller,
                              icon: Icons.money,
                              keyboardType:
                              TextInputType.number,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            MyButton(
                              text: 'Change',
                              bgColor:
                              Colour().lightGreen,
                              textColor: Colors.black,
                              icon: Icons.receipt,
                              onTap: () async {
                                backendClass.updateDays(
                                    widget.invoiceId,
                                    int.parse(
                                        amountcontroller
                                            .text));
                                Get.back();
                                Navigator.pop(
                                    context, true);
                                setState(() {});
                              },
                            ),
                          ],
                        ));
                  },
                  child: Text(
                    widget.invoiceDetail['daysLeft']
                        .toString(),
                    style: TextStyle(
                        color: Colors.lightGreen,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  ' Days',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            widget.isClient
                ? SizedBox()
                : widget.projCreatedbyContr
                ? MyButton(
                icon: Icons.receipt,
                text: 'Receipt',
                bgColor: Colour().lightGreen,
                textColor: Colors.black,
                onTap: () {
                  List file = widget.invoiceDetail['requestReceipt'];

                  if (file.isNotEmpty) {
                    Receipt().checkFileAndOpen(file[1], file[0]);
                  }
                })
                : widget.invoiceDetail['transaction'] == 'Request Sent'
                ? SizedBox()
                : widget.invoiceDetail['transaction'] ==
                'Payment Accepted'
                ? SizedBox()
                : MyButton(
                text: widget.invoiceDetail['transaction'] ==
                    'Make Request'
                    ? 'Make Request'
                    : 'Mark as Paid',
                bgColor: Colour().lightGreen,
                textColor: Colors.black,
                onTap: () {
                  if (widget.invoiceDetail['transaction'] ==
                      'Make Request') {
                    backendClass.updateTransaction(
                        widget.invoiceId, 'Request Sent');
                    backendClass.updatePayment(
                        widget.invoiceId, 'notMade');

                    Navigator.pop(context, true);
                  } else if (widget
                      .invoiceDetail['transaction'] ==
                      'Payment Sent') {
                    backendClass.updateTransaction(
                        widget.invoiceId, 'Payment Accepted');
                    backendClass.updateStatus(
                        widget.invoiceId, 'Paid');
                    backendClass.updateReceivedMoney(
                        widget.invoiceDetail['amountApproved']);

                    Navigator.pop(context, true);
                  } else {
                    Navigator.pop(context, false);
                  }
                })
          ]),
        ),
      ),
    );
  }
}