import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('Projects'),
      ),
      body: ListView.builder(itemCount: 5,itemBuilder: ((context, index) => ListTile(
        leading: ClipOval(
          child: Text(index.toString(),style: TextStyle(
            fontSize: 20,fontWeight: FontWeight.bold
          ),),
        ),
        title: Text('Construction of - Name -'),
        subtitle: Text('Ongoing'),
      ))),
    );
  
  }
}