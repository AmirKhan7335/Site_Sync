import 'dart:collection';

import 'package:amir_khan1/components/my_button.dart';
import 'package:amir_khan1/components/mytextfield.dart';
import 'package:amir_khan1/controllers/addActivityController.dart';
import 'package:amir_khan1/screens/consultant_screens/finance/backend/cnsltViewModel.dart';
import 'package:amir_khan1/screens/consultant_screens/finance/colors.dart';
import 'package:amir_khan1/screens/consultant_screens/finance/invoiceDetail.dart';
import 'package:amir_khan1/screens/engineer_screens/finance/backend/engViewModel.dart';
import 'package:amir_khan1/screens/engineer_screens/finance/backend/receipt.dart';
import 'package:amir_khan1/screens/engineer_screens/finance/createInvoice.dart';
import 'package:amir_khan1/screens/engineer_screens/finance/engInvoiceDetail.dart';
import 'package:amir_khan1/screens/engineer_screens/finance/financeController.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EngFinanceHome extends StatefulWidget {
  EngFinanceHome({required bool this.isClient, super.key});
  bool isClient;

  @override
  State<EngFinanceHome> createState() => _CnsltFinanceHomeState();
}

class _CnsltFinanceHomeState extends State<EngFinanceHome> {
  final dcontroller = Get.put(AddActivityController());
  final namecontroller = TextEditingController();
  final amountcontroller = TextEditingController();
  final amountPaidController = TextEditingController();

  final controller = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  Widget head(total) {
    return Column(
      children: [
        Container(
          height: Get.height * 0.2,
          width: Get.width,
          decoration: BoxDecoration(
            color: Colour().lightGreen,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Cost',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(total.toString(),
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        Container(
          height: Get.height * 0.05,
        )
      ],
    );
  }

  Widget receipt(invoiceDetail) {
    return InkWell(
      onTap: () {
        List file = invoiceDetail['requestReceipt'];

        if (file.isNotEmpty) {
          Receipt().checkFileAndOpen(file[1], file[0]);
        }
      },
      child: Container(
        width: 55,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5), color: Colour().lightGreen),
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Row(
            children: [
              const Icon(
                Icons.receipt,
                color: Colors.black,
                size: 15,
              ),
              Text(
                'Receipt ',
                style: TextStyle(fontSize: 10, color: Colors.black),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget priceBar(ret, received, remaining) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        color: Colors.white,
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      received.toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text('Received', style: TextStyle(color: Colors.black)),
                  ],
                ),
                SizedBox(
                  width: 5,
                ),
                Container(
                  width: 1,
                  color: Colors.grey,
                  height: 50,
                ),
                SizedBox(
                  width: 5,
                ),
                Column(
                  children: [
                    Text(remaining.toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.red)),
                    SizedBox(
                      height: 5,
                    ),
                    Text('Remainig', style: TextStyle(color: Colors.black)),
                  ],
                ),
                SizedBox(
                  width: 5,
                ),
                Container(
                  width: 1,
                  color: Colors.grey,
                  height: 50,
                ),
                SizedBox(
                  width: 5,
                ),
                Column(
                  children: [
                    Text(ret.toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey)),
                    SizedBox(
                      height: 5,
                    ),
                    Text('Retention', style: TextStyle(color: Colors.black)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget report() {
    return Column(
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          onPressed: () {},
          iconSize: 35,
          icon: Icon(Icons.calendar_month, color: Colors.green),
        ),
        Text(
          'Report',
          style: TextStyle(color: Colors.green),
        ),
      ],
    );
  }

  Widget CreateInvoice(projectCreatedByContr) {
    return Column(
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            var reload = await Navigator.push(context,
                MaterialPageRoute(builder: (context) {
                  return CreateInvoicePage(
                      projectCreatedByContr: projectCreatedByContr);
                }));
            if (reload) {
              setState(() {});
            }
          },
          iconSize: 35,
          icon: Icon(Icons.add, color: Colors.green),
        ),
        Text(
          'Create',
          style: TextStyle(color: Colors.green),
        ),
      ],
    );
  }

  Widget invoiceList(projCreatedbyContr, invoiceData) {
    return Container(
        height: Get.height * 0.5,
        child: ListView.builder(
            itemCount: invoiceData.length,
            itemBuilder: (context, index) {
              var invoiceDoc = invoiceData[index];
              var invoice = invoiceDoc[0];
              var invoiceId = invoiceDoc[1];
              return Card(
                color: Colors.white,
                child: ListTile(
                  onTap: () async {
                    var reload = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EngInvoiceDetail(
                                isClient: widget.isClient,
                                projCreatedbyContr: projCreatedbyContr,
                                invoiceDetail: invoice,
                                invoiceId: invoiceId)));
                    if (reload == true) {
                      setState(() {});
                    }
                  },
                  leading: Icon(
                    Icons.currency_bitcoin_rounded,
                    color: Colors.grey,
                  ),
                  title: Text(
                    invoice['name'],
                    style: TextStyle(color: Colors.black),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      projCreatedbyContr ? receipt(invoice) : SizedBox(),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        invoice['status'],
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [

            FutureBuilder(
                future: Query().getProjectPrice(widget.isClient),
                builder: (context, snapshot) {
                  if (ConnectionState.waiting == snapshot.data) {
                    return SizedBox();
                  } else if (snapshot.hasError) {
                    return SizedBox();
                  } else if (snapshot.hasData) {
                    var total = int.parse(snapshot.data![0]);
                    var ret = int.parse(snapshot.data![1]);
                    var received = snapshot.data![2];
                    var remaining = total - received;

                    return Stack(
                      children: [
                        head(total),
                        Positioned(
                          top: Get.height * 0.15,
                          left: 0,
                          right: 0,
                          child: priceBar(ret, received, remaining),
                        ),
                      ],
                    );
                  } else {
                    return SizedBox();
                  }
                }),



            FutureBuilder(
                future: Query().getData(widget.isClient),
                builder: ((context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colour().lightGreen,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return SizedBox();
                  } else {
                    var isContrCreator = snapshot.data![0];
                    var invoiceData = snapshot.data![1];
                    return Column(
                      children: [
                        widget.isClient
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            report(),
                          ],
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CreateInvoice(isContrCreator),
                            SizedBox(
                              width: 20,
                            ),
                            report(),
                          ],
                        ),
                       invoiceList(isContrCreator, invoiceData),
                      ],
                    );
                  }
                }))

          ],
        ),
      ),
    );
  }
}