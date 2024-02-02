import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  @override
  Widget build(BuildContext context) {
    return 
    Scaffold(
      appBar: AppBar(
        title: Text('Documents'),
      ),
      body: ListView.builder(itemCount: 5,itemBuilder: ((context, index) => ListTile(
        leading: ClipOval(
          child: Icon(Icons.file_copy),
        ),
        title: Text('Contract.pdf'),
        subtitle: Text('12/06/2024'),
      ))),
    );
  }
}