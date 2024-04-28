import 'package:flutter/material.dart';


class PageTwo extends StatefulWidget {
  String total;
  String retMoney;
  PageTwo({super.key,required this.total,required this.retMoney});

  @override
  State<PageTwo> createState() => _PageTwoState();
}

class _PageTwoState extends State<PageTwo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        // Adjusted color here
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          // SizedBox(
          //   width: 50,
          //   height: 50,
          //   child: ColorFiltered(
          //     colorFilter: const ColorFilter.matrix([
          //       0.0, 0.0, 0.0, 0, 255,
          //       // red channel
          //       0.0, 0.0, 0.0, 0, 255,
          //       // green channel
          //       0.0, 0.0, 0.0, 0, 0,
          //       // blue channel to minimum
          //       0.0, 0.0, 0.0, 1, 0,
          //       // alpha channel
          //     ]),
          //     child: Image.asset('assets/images/budget_icon.png',color: Colors.green,),
          //   ),
          // ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Total Cost",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              // const SizedBox(height: 10),
              Row(

                children: [
                  Text(widget.total,
                      style: const TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                ],),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.green),
                      child: const Icon(Icons.arrow_upward, color: Colors.black,)),
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Received",
                          style:
                          TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)),
                      Text("105,649,534",style:  TextStyle(fontSize: 16, color: Colors.black),)
                    ],
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Colors.red),
                          child: const Icon(Icons.arrow_downward, color: Colors.black,)),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(" Retention",
                              style:
                              TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)),
                          Text(widget.retMoney,style:  const TextStyle(fontSize: 16, color: Colors.black),)
                        ],
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
