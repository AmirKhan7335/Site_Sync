import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Details screen
class DetailsScreen extends StatelessWidget {
  final String mainHeading;
  final String subHeading;
  final List image;

  const DetailsScreen({
    super.key,
    required this.mainHeading,
    required this.subHeading,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mainHeading),
        backgroundColor: const Color(0xFF212832),
      ),
      backgroundColor: const Color(0xFF212832),
      body: ListView.builder(
        itemCount: image.length,
        itemBuilder: (context,index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              
              
              Container(
                width: Get.width*1,
                height: 350,
                child: Image.network(image[index]))
            ],
          );
        }
      ),
    );
  }
}
