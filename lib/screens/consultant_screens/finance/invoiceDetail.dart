import 'package:amir_khan1/components/my_button.dart';
import 'package:amir_khan1/components/mytextfield.dart';
import 'package:amir_khan1/controllers/addActivityController.dart';
import 'package:amir_khan1/screens/consultant_screens/finance/backend/cnsltViewModel.dart';
import 'package:amir_khan1/screens/consultant_screens/finance/colors.dart';
import 'package:amir_khan1/screens/consultant_screens/finance/makePayment.dart';
import 'package:amir_khan1/screens/engineer_screens/finance/backend/receipt.dart';
import 'package:amir_khan1/screens/engineer_screens/finance/financeController.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class InvoiceDetail extends StatefulWidget {
  InvoiceDetail(
      {required this.data,
        required this.id,
        required this.projectId,
        super.key});
  Map data;
  String id;
  String projectId;

  @override
  State<InvoiceDetail> createState() => _InvoiceDetailState();
}

class _InvoiceDetailState extends State<InvoiceDetail> {
  final controller = TextEditingController();
  final paymentController = TextEditingController();

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
            InkWell(
              onTap: () {
                List file = widget.data['approvedReceipt'];

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

    final financeController = Get.put(FinanceController());
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          '${widget.data['name']}',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                widget.data['transaction'] == 'Request Sent'
                    ? SizedBox()
                    : widget.data['transaction'] == 'Payment Accepted'
                    ? SizedBox()
                    : IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.edit),
                  color: Colors.lightGreen,
                )
              ],
            ),
            const SizedBox(height: 20),
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
                InkWell(
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
                  'Requuested Amount',
                  style: TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            MySimpleTextField(
              hintText: '${widget.data['amountRequested']}',
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
            const SizedBox(
              height: 25,
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.only(left: 6.0),
                child: Text(
                  'Days Left',
                  style: TextStyle(fontSize: 18.0, color: Colors.blueGrey),
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
            const SizedBox(height: 10),
            widget.data['payment'] == 'notMade' ? SizedBox() : afterPayment(),
            const SizedBox(height: 20),
            widget.data['payment'] == 'notMade'
                ? MyButton(
                text: 'Make Payment',
                bgColor: Colour().lightGreen,
                textColor: Colors.black,
                onTap: () async {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) {
                        return MakePayment(
                          projectId: widget.projectId,
                          id: widget.id,
                        );
                      }));
                })
                : widget.data['payment'] == 'made'
                ? MyButton(
                text: 'Send',
                bgColor: Colour().lightGreen,
                textColor: Colors.black,
                onTap: () {
                  CnsltFinanceBackend().changeOperation(
                      widget.projectId, widget.id, 'Payment Sent');
                  CnsltFinanceBackend().changePayment(
                      widget.projectId, widget.id, 'paid');
                  Navigator.pop(context, true);
                })
                : SizedBox(),
          ]),
        ),
      ),
    );
  }
}