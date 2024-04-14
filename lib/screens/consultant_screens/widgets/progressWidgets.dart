import 'package:flutter/material.dart';

class OngoingProgress extends StatefulWidget {
  OngoingProgress(
      {required this.index,
      required this.name,
      required this.progressValue,
      super.key});
  int index;
  String name;
  double progressValue;

  @override
  State<OngoingProgress> createState() => _OngoingProgressState();
}

class _OngoingProgressState extends State<OngoingProgress> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Ongoing Progress'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            RequestBody(index: widget.index,name: widget.name,progressValue: widget.progressValue,),
            SizedBox(
              height: 10,
            ),
          ],
        ));
  }
}

class CompletedProgress extends StatefulWidget {
  CompletedProgress({required this.index, required this.name, super.key, required this.progressValue});
  int index;
  String name;
  double progressValue;
  @override
  State<CompletedProgress> createState() => _CompletedProgressState();
}

class _CompletedProgressState extends State<CompletedProgress> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Completed Progress'),
          centerTitle: true,
        ),
        body: 
            RequestBody(index: widget.index,name: widget.name,progressValue: widget.progressValue,),
        );
  }
}

class RequestBody extends StatefulWidget {
  RequestBody({required this.name, required this.index, required this.progressValue, super.key});
  int index;
  String name;
  double progressValue;

  @override
  State<RequestBody> createState() => _RequestBodyState();
}

class _RequestBodyState extends State<RequestBody> {
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
            child: 
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[400],
                  radius: 30,
                  child: Text('${widget.index }',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  '${widget.name}',
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
            padding: EdgeInsets.all(32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Progress',
                style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),
                ),
                Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      child: CircularProgressIndicator(
                        value: widget.progressValue,
                        color: Colors.yellow,
                    strokeWidth: 10,
                    
                        
                    
                      ),
                    ),
                    Text('${widget.progressValue*100} %')
                  ],
                )
              ],
            ),
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
                          'Client:  ',
                        ),
                        Text(
                          'NUST',
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
                          'Budget:  ',
                        ),
                        Text(
                          'Rs 100,000,000',
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
                          'Contractor :  ',
                        ),
                        Text(
                          'ARCO',
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
                          'Engineer:  ',
                        ),
                        Text(
                          'Kamran Khan',
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
                          'Location:  ',
                        ),
                        Text(
                          'NUST',
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
