import 'package:amir_khan1/screens/consultant_screens/activityGallery.dart';
import 'package:flutter/material.dart';

class ActivityDetail extends StatefulWidget {
  const ActivityDetail({super.key});

  @override
  State<ActivityDetail> createState() => _ActivityDetailState();
}

class _ActivityDetailState extends State<ActivityDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SafeArea(
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
                      'Activity Detail',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
                      'Foundation',
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
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
               child: ListTile(title: Text('Reinforcement',),
               subtitle: Text('10/10/2021 - 10/11/2021',style: TextStyle(fontSize: 12))
               ,
               trailing: Text('Tap to view'),),
             ),
           ),
           Padding(
             padding: const EdgeInsets.only(left: 24,right: 24,top: 0,bottom: 16),
             child: Container(
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
               child: ListTile(title: Text('Formwork',),
               subtitle: Text('10/10/2021 - 10/11/2021',style: TextStyle(fontSize: 12))
               ,
               trailing:  Text('Tap to view')),
             ),
           ),
           
           Padding(
             padding: const EdgeInsets.only(left: 24,right: 24,top: 8,bottom: 16),
             child: Container(
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
               child: ListTile(title: Text('Concreting',),onTap:()=> Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityGallery()))
               ,subtitle: Text('10/10/2021 - 10/11/2021',style: TextStyle(fontSize: 12))
               ,
               trailing:  Text('Tap to view'),),
             ),
           ),
             Padding(
             padding: const EdgeInsets.only(left: 24,right: 24,top: 8,bottom: 16),
             child: Container(
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
               child: ListTile(title: Text('Curing',),
               subtitle: Text('10/10/2021 - 10/11/2021',style: TextStyle(fontSize: 12),)
               ,
               trailing:  Text('Tap to view'),),
             ),
           ),
            
    
            ]
            ,
          ),
        ),
      ),
    );
  }
}
