import 'package:amir_khan1/screens/engineer_screens/scheduleScreen/schedulescreen.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import 'chatscreen.dart';
import 'notificationsscreen.dart';



//foundation schedule screen
class FoundationScheduleScreen extends StatefulWidget {
  const FoundationScheduleScreen({super.key});

  @override
  State<FoundationScheduleScreen> createState() =>
      _FoundationScheduleScreenState();
}

class _FoundationScheduleScreenState extends State<FoundationScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF212832),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: const Color(0xFF212832),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        children: [
          const Text(
            'Foundation',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 28.0,
            ),
          ),
          const SizedBox(height: 16.0),
          _buildActivityTile('Reinforcement Installation', '2/10/23 - 8/10/23'),
          _buildActivityTile('Form work', '9/10/23 - 15/10/23'),
          _buildActivityTile('Concreting', '16/10/23 - 25/11/23'),
          _buildActivityTile('Curing', '20/11/23 - 15/12/23'),
        ],
      ),
    );
  }

  Widget _buildActivityTile(String title, String date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      decoration: const BoxDecoration(
        color: Color(0xFF537789),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10.0),
          bottomRight: Radius.circular(10.0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 15.0,
            height: 60,
            color: const Color(0xFFFED36A),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  date,
                  style: const TextStyle(
                    color: Color(0xFFD2D2D2),
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16.0),
          const Text(
            'Tap to view',
            style: TextStyle(
              color: Color(0xFFD2D2D2),
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }
}