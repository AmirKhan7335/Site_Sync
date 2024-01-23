import 'package:amir_khan1/screens/consultant_screens/activityDetail.dart';
import 'package:flutter/material.dart';

class ConsultantSchedule extends StatefulWidget {
  const ConsultantSchedule({super.key});

  @override
  State<ConsultantSchedule> createState() => _ConsultantScheduleState();
}

class _ConsultantScheduleState extends State<ConsultantSchedule> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back_ios_outlined)),
                  Text(
                    'Schedule',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                      onPressed: () {

                      },
                      icon: Icon(Icons.add_box_outlined)),
                  
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Construction of NISH',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 32, left: 32),
              child: Container(
                height: 1.5,
                color: Colors.white,
              ),
            ),
         Padding(
           padding: const EdgeInsets.all(24.0),
           child: Container(
            decoration: BoxDecoration(
              color: Colors.blue[200],
              borderRadius: BorderRadius.circular(10),
            ),
             child: ListTile(title: Text('Excavation',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
             subtitle: Text('10/10/2021 - 10/11/2021',style: TextStyle(fontSize: 12))
             ,
             trailing: Image.asset('assets/images/excavation.jpeg'),),
           ),
         ),
         Padding(
           padding: const EdgeInsets.only(left: 24,right: 24,top: 0,bottom: 16),
           child: Container(
            decoration: BoxDecoration(
              color: Colors.blue[200],
              borderRadius: BorderRadius.circular(10),
            ),
             child: ListTile(
              onTap: () => Navigator.push(context,MaterialPageRoute(builder: (context) => ActivityDetail())),
              title: Text('Foundation',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
             subtitle: Text('10/10/2021 - 10/11/2021',style: TextStyle(fontSize: 12))
             ,
             trailing: Image.asset('assets/images/foundation.jpeg'),),
           ),
         ),
         
         Padding(
           padding: const EdgeInsets.only(left: 24,right: 24,top: 8,bottom: 16),
           child: Container(
            decoration: BoxDecoration(
              color: Colors.blue[200],
              borderRadius: BorderRadius.circular(10),
            ),
             child: ListTile(title: Text('Framing',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
             subtitle: Text('10/10/2021 - 10/11/2021',style: TextStyle(fontSize: 12))
             ,
             trailing: Image.asset('assets/images/framing.jpeg'),),
           ),
         ),
           Padding(
           padding: const EdgeInsets.only(left: 24,right: 24,top: 8,bottom: 16),
           child: Container(
            decoration: BoxDecoration(
              color: Colors.blue[200],
              borderRadius: BorderRadius.circular(10),
            ),
             child: ListTile(title: Text('Roofing',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
             subtitle: Text('10/10/2021 - 10/11/2021',style: TextStyle(fontSize: 12),)
             ,
             trailing: Image.asset('assets/images/roofing.jpeg'),),
           ),
         ),
          

          ]
          ,
        ),
      ),
    );
  }
}
