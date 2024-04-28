import 'package:amir_khan1/screens/consultant_screens/finance/backend/cnsltViewModel.dart';
import 'package:amir_khan1/screens/consultant_screens/finance/colors.dart';
import 'package:amir_khan1/screens/consultant_screens/finance/invoiceDetail.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CnsltFinanceHome extends StatefulWidget {
  CnsltFinanceHome({required this.projectId, super.key});
  String projectId;
  @override
  State<CnsltFinanceHome> createState() => _CnsltFinanceHomeState();
}

class _CnsltFinanceHomeState extends State<CnsltFinanceHome> {
  Widget head(int totalCost) {
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
                Text(totalCost.toString(),
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

  Widget priceBar(retention, received, remaining) {
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
                    Text(retention.toString(),
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
                onTap: () async {
                  if (invoiceData['transaction'] != 'Make Request') {
                    var reload = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InvoiceDetail(
                                data: invoiceData,
                                id: invoiceId,
                                projectId: widget.projectId)));
                    if (reload == true) {
                      setState(() {});
                    }
                  }
                },
                leading: Icon(
                  Icons.currency_bitcoin_rounded,
                  color: Colors.grey,
                ),
                title: Text(
                  '${invoiceData['name']}',
                  style: TextStyle(color: Colors.black),
                ),
                trailing: Text(
                  '${invoiceData['status']}',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            FutureBuilder(
                future: CnsltFinanceBackend().getProjectPrice(widget.projectId),
                builder: (context, snapshot) {
                  if (ConnectionState.waiting == snapshot.data) {
                    return SizedBox();
                  } else if (snapshot.hasError) {
                    return SizedBox();
                  } else {
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
                  }
                }),
            report(),
            FutureBuilder(
                future: CnsltFinanceBackend().getInvoiceList(widget.projectId),
                builder: (context, snapshot) {
                  if (ConnectionState.waiting == snapshot.connectionState) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }  else if (snapshot.hasError) {
                    return SizedBox();
                  }
                  else if (snapshot.hasData) {
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
    );
  }
}