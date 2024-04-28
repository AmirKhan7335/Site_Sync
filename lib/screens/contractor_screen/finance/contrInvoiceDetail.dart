import 'package:amir_khan1/components/my_button.dart';
import 'package:amir_khan1/components/mytextfield.dart';
import 'package:amir_khan1/screens/consultant_screens/finance/colors.dart';
import 'package:amir_khan1/screens/engineer_screens/finance/backend/receipt.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ContrInvoiceDetail extends StatefulWidget {
  ContrInvoiceDetail(
      {required this.data, required bool this.projCreatedbyContr, super.key});
  bool projCreatedbyContr;
  Map data;

  @override
  State<ContrInvoiceDetail> createState() => _ContrInvoiceDetailState();
}

class _ContrInvoiceDetailState extends State<ContrInvoiceDetail> {
  final controller = TextEditingController();

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
              onTap: () {},
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
              .format(widget.data['approvalDate'].toDate()),
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
          hintText: widget.data['amountApproved'],
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
          widget.data['name'],
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
                    List file = widget.data['requestReceipt'];

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
                  .format(widget.data['requestDate'].toDate()),
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
                  'Requested Amount',
                  style: TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            MySimpleTextField(
              hintText: widget.data['amountRequested'],
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
                  'Status',
                  style: TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            MySimpleTextField(
              hintText: widget.data['status'],
              obscureText: false,
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              readOnly: true,
            ),
            const SizedBox(height: 10),
            widget.projCreatedbyContr
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
                  hintText: '12',
                  obscureText: false,
                  controller: controller,
                  keyboardType: TextInputType.emailAddress,
                  readOnly: true,
                ),
              ],
            ),
            const SizedBox(height: 10),
            widget.data['payment'] == 'notMade' ? SizedBox() : afterPayment(),
            const SizedBox(height: 10),
            const SizedBox(height: 20),
            widget.projCreatedbyContr
                ? MyButton(
                icon: Icons.receipt,
                text: 'Receipt',
                bgColor: Colour().lightGreen,
                textColor: Colors.black,
                onTap: () {})
                : SizedBox(),
          ]),
        ),
      ),
    );
  }
}