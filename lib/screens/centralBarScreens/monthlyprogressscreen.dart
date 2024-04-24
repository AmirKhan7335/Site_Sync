import 'dart:io';

import 'package:amir_khan1/widgets/colors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class MonthProgressScreen extends StatefulWidget {
  final String monthYear;
  final List<dynamic>? progressReports;

  const MonthProgressScreen({
    Key? key,
    required this.monthYear,
    required this.progressReports,
  }) : super(key: key);

  @override
  State<MonthProgressScreen> createState() => _MonthProgressScreenState();
}

class _MonthProgressScreenState extends State<MonthProgressScreen> {

  getPath() async {
    final Directory? tempDir = await getExternalStorageDirectory();
    final filePath = Directory(tempDir!.path);
    if (await filePath.exists()) {
      return filePath.path;
    } else {
      await filePath.create(recursive: true);
      return filePath.path;
    }
  }

  Future<void> _checkFileAndOpen(fileUrl, fileName) async {
    try {
      var storePath = await getPath();
      bool isExist = await File('$storePath/$fileName').exists();
      if (isExist) {
        OpenFile.open('$storePath/$fileName.pdf');
      } else {
        var filePath = '$storePath/$fileName.pdf';

        await Dio().download(
          fileUrl,
          filePath,
        );
        OpenFile.open(filePath);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }


  @override
  Widget build(BuildContext context) {
    // Sort progress reports by date in ascending order
    widget.progressReports?.sort((a, b) {
      DateTime dateA = DateFormat('dd-MM-yyyy').parse(a['today-date']);
      DateTime dateB = DateFormat('dd-MM-yyyy').parse(b['today-date']);
      return dateA.compareTo(dateB);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.monthYear, style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: widget.progressReports != null && widget.progressReports!.isNotEmpty
          ? ListView.builder(
        itemCount: widget.progressReports!.length,
        itemBuilder: (context, index) {
          final report = widget.progressReports![index];
          final reportDate = report['today-date'];
          final reportFileUrl = report['$reportDate'];
          print('url = $reportFileUrl');

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Colors.white,
              elevation: 5.0,
              child: ListTile(
                title: Text(reportDate ?? 'Untitled', style: TextStyle(color: Colors.black)),
                onTap: reportFileUrl != null
                    ? () async {
                  try {
                    print('Opening file URL: $reportFileUrl');
                    _checkFileAndOpen(reportFileUrl, reportDate);
                  } catch (error) {
                    print('Error opening file: $error');
                    // You could display a snackbar or dialog to inform the user about the error
                  }
                }
                    : null,
              ),
            ),
          );
        },
      )
          : const Center(
        child: Text('No progress reports available for this month'),
      ),
    );
  }
}