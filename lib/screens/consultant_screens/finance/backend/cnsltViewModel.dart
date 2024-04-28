import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CnsltFinanceBackend {
  Future<List> getProjectPrice(projectId) async {
    var query = await FirebaseFirestore.instance
        .collection('Projects')
        .doc(projectId)
        .get();
    var total = query.data()!['budget'];
    var ret = query.data()!['retMoney'];
    var received = query.data()!['receivedMoney'];
    return [total, ret, received];
  }

  getInvoiceList(projectId) async {
    print(projectId);
    try {
      var invoiceCollection = await FirebaseFirestore.instance
          .collection('engineers')
          .where('projectId', isEqualTo: projectId)
          .get();
      final engEmail = await invoiceCollection.docs.first.id;
      final invoiceList = await FirebaseFirestore.instance
          .collection('engineers')
          .doc(engEmail)
          .collection('invoices')
          .get();
      var invoices =
      invoiceList.docs.map((doc) => [doc.data(), doc.id]).toList();
      return invoices;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  makePayment(projectId, invoiceId, date, amount, operation,fileInfo) async {
    var invoiceCollection = await FirebaseFirestore.instance
        .collection('engineers')
        .where('projectId', isEqualTo: projectId)
        .get();
    final engEmail = await invoiceCollection.docs.first.id;
    final invoiceList = await FirebaseFirestore.instance
        .collection('engineers')
        .doc(engEmail)
        .collection('invoices')
        .doc('$invoiceId')
        .update({
      'payment': operation,
      'approvalDate': date,
      'amountApproved': amount,
      'approvedReceipt':fileInfo
    });
  }

  changeOperation(projectId, invoiceId, operation) async {
    var invoiceCollection = await FirebaseFirestore.instance
        .collection('engineers')
        .where('projectId', isEqualTo: projectId)
        .get();
    final engEmail = await invoiceCollection.docs.first.id;
    final invoiceList = await FirebaseFirestore.instance
        .collection('engineers')
        .doc(engEmail)
        .collection('invoices')
        .doc('$invoiceId')
        .update({
      'transaction': operation,
    });
  }

  changePayment(projectId, invoiceId, operation) async {
    var invoiceCollection = await FirebaseFirestore.instance
        .collection('engineers')
        .where('projectId', isEqualTo: projectId)
        .get();
    final engEmail = await invoiceCollection.docs.first.id;
    final invoiceList = await FirebaseFirestore.instance
        .collection('engineers')
        .doc(engEmail)
        .collection('invoices')
        .doc('$invoiceId')
        .update({
      'payment': operation,
    });
  }
}