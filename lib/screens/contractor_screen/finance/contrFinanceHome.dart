import 'package:amir_khan1/components/my_button.dart';
import 'package:amir_khan1/components/mytextfield.dart';
import 'package:amir_khan1/screens/consultant_screens/finance/backend/cnsltViewModel.dart';
import 'package:amir_khan1/screens/consultant_screens/finance/colors.dart';
import 'package:amir_khan1/screens/consultant_screens/finance/invoiceDetail.dart';
import 'package:amir_khan1/screens/contractor_screen/finance/contrInvoiceDetail.dart';
import 'package:amir_khan1/screens/engineer_screens/finance/backend/receipt.dart';
import 'package:amir_khan1/screens/engineer_screens/finance/engInvoiceDetail.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContrFinanceHome extends StatefulWidget {
  ContrFinanceHome(
      {required this.projectId,
        required bool this.projectCreatedbyContr,
        super.key});
  String projectId;
  bool projectCreatedbyContr;

  @override
  State<ContrFinanceHome> createState() => _ContrFinanceHomeState();
}

class _ContrFinanceHomeState extends State<ContrFinanceHome> {
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

  Widget CreateInvoice() {
    return Column(
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            createDialogue();
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

  Widget receipt(invoiceData) {
    return InkWell(
      onTap: () {
        List file = invoiceData['requestReceipt'];

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

  Widget invoiceList(data) {
    return Container(
      height: Get.height * 0.5,
      child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            var invoiceId = data[index][1];
            var invoiceData = data[index][0];
            return Card(
              color: Colors.white,
              child: ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ContrInvoiceDetail(
                              projCreatedbyContr: widget.projectCreatedbyContr,
                              data: invoiceData)));
                },
                leading: Icon(
                  Icons.currency_bitcoin_rounded,
                  color: Colors.grey,
                ),
                title: Text(
                  invoiceData['name'],
                  style: TextStyle(color: Colors.black),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.projectCreatedbyContr
                        ? receipt(invoiceData)
                        : SizedBox(),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      invoiceData['status'],
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  final controller = TextEditingController();
  createDialogue() {
    Get.defaultDialog(
      backgroundColor: Colors.white,
      title: 'Create Invoice',
      titleStyle: TextStyle(color: Colors.black),
      content: Column(
        children: [
          const SizedBox(height: 10),
          const SizedBox(
            height: 25,
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.only(left: 6.0),
              child: Text(
                'Name',
                style: TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          const SizedBox(height: 10),
          MyTextField(
            hintText: 'IPC 1',
            obscureText: false,
            controller: controller,
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
                'Amount',
                style: TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          const SizedBox(height: 10),
          MyTextField(
            hintText: 'Rs 321,234,333',
            obscureText: false,
            controller: controller,
            icon: Icons.money,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 10),
          MyButton(
            text: 'Attach Proof',
            bgColor: Colour().lightGreen,
            textColor: Colors.black,
            icon: Icons.receipt,
            onTap: () async {
              try {
                Get.back();
                controller.clear();
              } catch (e) {
                Get.back();
                controller.clear();
                debugPrint(e.toString());
                Get.snackbar('Error', '${e}');
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              FutureBuilder(
                  future:
                  CnsltFinanceBackend().getProjectPrice(widget.projectId),
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
              widget.projectCreatedbyContr
                  ? report()
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CreateInvoice(),
                  SizedBox(
                    width: 20,
                  ),
                  report(),
                ],
              ),
              FutureBuilder(
                  future:
                  CnsltFinanceBackend().getInvoiceList(widget.projectId),
                  builder: (context, snapshot) {
                    if (ConnectionState.waiting == snapshot.connectionState) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return SizedBox();
                    } else if (snapshot.hasData) {
                      return invoiceList(snapshot.data);
                    } else {
                      return Center(
                        child: Text('No Data Found'),
                      );
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}