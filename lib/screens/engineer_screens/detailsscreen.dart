import 'package:flutter/material.dart';



// Details screen
class DetailsScreen extends StatelessWidget {
  final String mainHeading;
  final String subHeading;

  const DetailsScreen({
    super.key,
    required this.mainHeading,
    required this.subHeading,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        backgroundColor: const Color(0xFF212832),
      ),
      backgroundColor: const Color(0xFF212832),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              mainHeading,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subHeading,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 18.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}