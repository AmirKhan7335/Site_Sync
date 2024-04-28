import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class Query {
  generateInvoiceForCnsltProject(
      name, amountRequested, requestDate, daysLeft, fileInfo) async {
    var email = FirebaseAuth.instance.currentUser!.email;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var activitiesCollection = await firestore
        .collection('engineers')
        .doc(email)
        .collection('invoices')
        .doc();
    await activitiesCollection.set({
      'name': name,
      'amountRequested': amountRequested,
      'requestDate': requestDate,
      'status': 'Unpaid',
      'daysLeft': daysLeft,
      'transaction': 'Make Request',
      'payment': 'notMade',
      'requestReceipt': fileInfo
    });
  }

  generateInvoiceForContrProject(name, amountRequested, requestDate,
      amountApproved, approvalDate, fileInfo) async {
    var email = FirebaseAuth.instance.currentUser!.email;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var activitiesCollection = await firestore
        .collection('engineers')
        .doc(email)
        .collection('invoices')
        .doc();
    await activitiesCollection.set({
      'name': name,
      'amountRequested': amountRequested,
      'requestDate': requestDate,
      'status': 'Paid',
      'amountApproved': amountApproved,
      'approvalDate': approvalDate,
      'requestReceipt': fileInfo
    });
  }

  updateReceivedMoney(amountApproved) async {
    var email = await FirebaseAuth.instance.currentUser!.email;
    var getProjectId = await FirebaseFirestore.instance
        .collection('engineers')
        .doc(email)
        .get();
    var projectId = getProjectId.data()!['projectId'];
    var query = await FirebaseFirestore.instance
        .collection('Projects')
        .doc(projectId)
        .get();
    var received = await query.data()!['receivedMoney'];
    var totalReceived = received + int.parse(amountApproved);
    await FirebaseFirestore.instance
        .collection('Projects')
        .doc(projectId)
        .update({'receivedMoney': totalReceived});
  }

  checkRole() async {
    var email = await FirebaseAuth.instance.currentUser!.email;
    var role =
    await FirebaseFirestore.instance.collection('users').doc(email).get();
    var getRole = await role.data()!['role'];
  }

  Future<List> getProjectPrice(isClient) async {
    var email = await FirebaseAuth.instance.currentUser!.email;
    var getProjectId = isClient
        ? await FirebaseFirestore.instance
        .collection('clients')
        .doc(email)
        .get()
        : await FirebaseFirestore.instance
        .collection('engineers')
        .doc(email)
        .get();
    var projectId = getProjectId.data()!['projectId'];
    var query = await FirebaseFirestore.instance
        .collection('Projects')
        .doc(projectId)
        .get();
    var total = query.data()!['budget'];
    var ret = query.data()!['retMoney'];
    var received = query.data()!['receivedMoney'];
    return [total, ret, received];
  }

  Future<List> getData(isClient) async {
    var isContrCreator = await projectCreator(isClient);

    var invoiceData = await fetchInvoicesForEng(isClient);
    return [isContrCreator, invoiceData];
  }

  fetchInvoicesForEng(isClient) async {
    var email = await FirebaseAuth.instance.currentUser!.email;
    if (isClient) {
      var projIdForClient = await FirebaseFirestore.instance
          .collection('clients')
          .doc(email)
          .get();
      var clientProjectId = projIdForClient.data()!['projectId'];
      var sameEngineer = await FirebaseFirestore.instance
          .collection('engineers')
          .where('projectId', isEqualTo: clientProjectId)
          .get();

      var engEmails = sameEngineer.docs.map((e) => e.id).toList();
      var invoiceCollection = await FirebaseFirestore.instance
          .collection('engineers')
          .doc(engEmails[0])
          .collection('invoices')
          .get();
      var invoices = await invoiceCollection.docs
          .map((doc) => [doc.data(), doc.id])
          .toList();

      return invoices;
    } else {
      var invoiceCollection = await FirebaseFirestore.instance
          .collection('engineers')
          .doc(email)
          .collection('invoices')
          .get();
      var invoices = await invoiceCollection.docs
          .map((doc) => [doc.data(), doc.id])
          .toList();

      return invoices;
    }
  }

  projectCreator(isClient) async {
    final email = await FirebaseAuth.instance.currentUser!.email;

    final query = isClient
        ? await FirebaseFirestore.instance
        .collection('clients')
        .doc(email)
        .get()
        : await FirebaseFirestore.instance
        .collection('engineers')
        .doc(email)
        .get();

    final getCreatorEmail = await query.data()!['consultantEmail'];

    final creator = await FirebaseFirestore.instance
        .collection('users')
        .doc(getCreatorEmail)
        .get();

    final creatorType = creator.data()!['role'];

    if (creatorType == 'Contractor') {
      return true;
    } else {
      return false;
    }
  }

  updateTransaction(docId, value) async {
    var email = FirebaseAuth.instance.currentUser!.email;

    var invoiceCollection = await FirebaseFirestore.instance
        .collection('engineers')
        .doc(email)
        .collection('invoices')
        .doc(docId)
        .update({
      'transaction': value,
    });
  }

  updateDays(docId, int value) async {
    var email = FirebaseAuth.instance.currentUser!.email;

    var invoiceCollection = await FirebaseFirestore.instance
        .collection('engineers')
        .doc(email)
        .collection('invoices')
        .doc(docId)
        .update({
      'daysLeft': value,
    });
  }

  updatePayment(docId, value) async {
    var email = FirebaseAuth.instance.currentUser!.email;

    var invoiceCollection = await FirebaseFirestore.instance
        .collection('engineers')
        .doc(email)
        .collection('invoices')
        .doc(docId)
        .update({
      'payment': value,
    });
  }

  updateStatus(docId, value) async {
    var email = FirebaseAuth.instance.currentUser!.email;

    var invoiceCollection = await FirebaseFirestore.instance
        .collection('engineers')
        .doc(email)
        .collection('invoices')
        .doc(docId)
        .update({
      'status': value,
    });
  }
}