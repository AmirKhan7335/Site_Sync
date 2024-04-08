import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class DocumentViewer extends StatefulWidget {
  final String localFilePath;
  final String documentName;

  const DocumentViewer({super.key, required this.localFilePath, required this.documentName});

  @override
  DocumentViewerState createState() => DocumentViewerState();
}

class DocumentViewerState extends State<DocumentViewer> {
  late PDFViewController _pdfController;
  bool _showPageNumber = false;
  int _pageNumber = 1;
  int _totalPages = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PDFView(
            filePath: widget.localFilePath,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: false,
            pageSnap: true,
            pageFling: false,
            onViewCreated: (PDFViewController pdfController) async {
              _pdfController = pdfController;
              _pageNumber = await _pdfController.getCurrentPage() ?? 1;
              _totalPages = await _pdfController.getPageCount() ?? 0;
              setState(() {}); // Update the UI with page information
            },
            onPageChanged: (int? page, int? total) {
              if (page != null && total != null) {
                setState(() {
                  _pageNumber = page;
                  _totalPages = total;
                  _showPageNumber = true;
                });
                Future.delayed(const Duration(milliseconds: 1500), () {
                  setState(() {
                    _showPageNumber = false;
                  });
                });
              }
            },
            onError: (error) {
              if (kDebugMode) {
                print('Error loading PDF: $error');
              }
            },
          ),
          if (_showPageNumber)
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '$_pageNumber of $_totalPages',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DocumentScreen extends StatefulWidget {
  final String documentUrl;
  final String documentName;

  const DocumentScreen({super.key, required this.documentUrl, required this.documentName});

  @override
  DocumentScreenState createState() => DocumentScreenState();
}

class DocumentScreenState extends State<DocumentScreen> {
  bool _downloading = false;
  String? _localFilePath;

  @override
  void initState() {
    super.initState();
    _downloadFile();
  }

  Future<void> _downloadFile() async {
    setState(() {
      _downloading = true;
    });

    try {
      firebase_storage.Reference ref =
      firebase_storage.FirebaseStorage.instance.refFromURL(widget.documentUrl);
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String fileName = widget.documentUrl.split('/').last;
      final File localFile = File('${appDocDir.path}/$fileName');

      await ref.writeToFile(localFile).then((_) {
        setState(() {
          _localFilePath = localFile.path;
          _downloading = false;
        });
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading PDF: $e');
      }
      setState(() {
        _downloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.documentName, style: const TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _downloading
          ? const Center(child: CircularProgressIndicator())
          : _localFilePath != null
          ? DocumentViewer(localFilePath: _localFilePath!, documentName: widget.documentName)
          : const Center(
        child: Text('Error downloading PDF'),
      ),
    );
  }
}
