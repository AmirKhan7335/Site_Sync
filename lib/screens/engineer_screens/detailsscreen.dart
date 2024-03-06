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
        title: Text(
          mainHeading,
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: ListView.builder(
          itemCount: image.length,
          itemBuilder: (context, index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Scaffold(
                              backgroundColor: Colors.white,
                              body:
                                  Center(child: Image.network(image[index]))))),
                  child: Container(
                      width: Get.width * 1,
                      height: 350,
                      child: Image.network(image[index])),
                )
              ],
            );
          }),
    );
  }
}
