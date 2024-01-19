import 'package:amir_khan1/components/my_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PendingRequest extends StatelessWidget {
  const PendingRequest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Pending Requests'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            RequestBody(),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: MyButton(
                text: 'Confirm',
                bgColor: Colors.yellow,
                textColor: Colors.black,
                icon: Icons.cloud_done_rounded,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ));
  }
}

class ApprovedRequest extends StatelessWidget {
  const ApprovedRequest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Approved Requests'),
          centerTitle: true,
        ),
        body: RequestBody());
  }
}

class RequestBody extends StatelessWidget {
  const RequestBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.yellow,
                  radius: 30,
                  child: Icon(Icons.person),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Kamran Khan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey,
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 50,
                        ),
                        Text(
                          'Email:  ',
                        ),
                        Text(
                          'example@123',
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 50,
                        ),
                        Text(
                          'Role:  ',
                        ),
                        Text(
                          'Engineer',
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 50,
                        ),
                        Text(
                          'Project :  ',
                        ),
                        Text(
                          'Construction of NSTP',
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 50,
                        ),
                        Text(
                          'Start Date:  ',
                        ),
                        Text(
                          '20/02/2023',
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 50,
                        ),
                        Text(
                          'End Date:  ',
                        ),
                        Text(
                          '30/06/2023',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
