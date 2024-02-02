import 'package:flutter/material.dart';

import '../components/arcpainter.dart';

class PageTwo extends StatefulWidget {
  const PageTwo({super.key});

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
        color: const Color(0xFF0F2935),
        // Adjusted color here
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                0.0, 0.0, 0.0, 0, 255,
                // red channel
                0.0, 0.0, 0.0, 0, 255,
                // green channel
                0.0, 0.0, 0.0, 0, 0,
                // blue channel to minimum
                0.0, 0.0, 0.0, 1, 0,
                // alpha channel
              ]),
              child: Image.asset('assets/images/budget_icon.png'),
            ),
          ),
          Transform.translate(
            offset: const Offset(2, 0),
            // Adjust the vertical offset as needed
            child: const Text("Total Coast\n105,649,534",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Move "Status: On Time" text upwards
                ],
              ),
              const SizedBox(width: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  Container(
                    height: 55,
                    width: 90,
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        
                        SizedBox(width: 5,),
                        Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Colors.green),
                            child: Icon(Icons.arrow_upward)),
                        Text("  Approved\n105,649,534",
                            style:
                                TextStyle(fontSize: 10, color: Colors.white)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                    height: 55,
                    width: 90,
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        SizedBox(width: 5,),
                        Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Colors.red),
                            child: Icon(Icons.arrow_downward)),
                        Text("  Retention\n105,649,534",
                            style:
                                TextStyle(fontSize: 10, color: Colors.white)),
                      ],
                    ),
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
