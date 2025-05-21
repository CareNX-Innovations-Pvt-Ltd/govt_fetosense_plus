import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:l8fe/models/test_model.dart';

import '../../locater.dart';
import '../services/test_api.dart';

class TestCRUDModel extends ChangeNotifier {
  final TestApi _api = locator<TestApi>();

  List<CtgTest>? tests;

  Future<List<CtgTest>?> fetchTests() async {
    var result = await _api.getDataCollection();
    tests = result.docs.map((doc) => CtgTest.fromMap(doc.data() as Map<dynamic, dynamic>, doc.id)).toList();
    return tests;
  }

  Stream<QuerySnapshot> fetchTestsAsStream(String? id) {
    return _api.streamDataCollectionForMother(id);
  }

  Stream<QuerySnapshot> fetchTestsAsStreamBabyBeat(String? id) {
    return _api.streamDataCollectionForMotherBabyBeat(id);
  }


  Stream<QuerySnapshot> fetchAllTestsAsStream(String? id) {
    return _api.streamDataCollectionForOrganization(id);
  }

  Stream<QuerySnapshot> fetchAllTestsAsStreamBabyBeat(String? orgId, String? docId) {
    return _api.streamDataCollectionForOrganizationBabyBeat(orgId, docId);
  }

  Stream<QuerySnapshot> fetchAllTestsAsStreamBabyBeatAll(String? docId) {
    return _api.streamDataCollectionForOrganizationBabyBeatAll(docId);
  }

  Stream<QuerySnapshot> fetchAllTestsAsStreamOrg(String id) {
    return _api.streamDataCollectionForOrganizationOrg(id);
  }

  Stream<QuerySnapshot> fetchAllTestsAsStreamForTV(String? id, int limit) {
    return _api.streamDataCollectionForOrganizationForTV(id, limit);
  }

  Stream<QuerySnapshot> fetchAllTestsAsStreamOrgForTV(String? id, int limit) {
    return _api.streamDataCollectionForOrganizationOrgForTV(id, limit);
  }

  Future<CtgTest> getTestById(String id) async {
    var doc = await _api.getDocumentById(id);
    return CtgTest.fromMap(doc.data() as Map<dynamic, dynamic>, doc.id);
  }

  Future removeTest(String id) async {
    await _api.removeDocument(id);
    return;
  }
  /*Future updateTest(Test data,String id) async{
    await _api.updateDocument(data.toJson(), id) ;
    return ;
  }*/

}
