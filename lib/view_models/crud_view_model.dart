import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:l8fe/models/doctor_model.dart';
import 'package:l8fe/models/mother_model.dart';
import 'package:l8fe/models/user_model.dart';
import 'package:l8fe/services/fire_api.dart';

import '../../locater.dart';

class CRUDModel with ChangeNotifier {
  final Api _api = locator<Api>();

  List<Mother>? mothers;

  Future<List<Mother>?> fetchProducts() async {
    var result = await _api.getDataCollection();
    mothers =
        result.docs.map((doc) => Mother.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    return mothers;
  }

  Stream<QuerySnapshot> fetchMothersAsStream(String organizationId) {
    return _api.streamMotherData(organizationId);
  }

  Stream<QuerySnapshot> fetchMothersAsStreamSearch(
      String organizationId, String start) {
    return _api.streamMotherDataSearch(organizationId, start);
  }

  Stream<QuerySnapshot> fetchActiveMothersAsStream(String? organizationId) {
    return _api.streamActiveMotherData(organizationId);
  }

  Stream<List<Mother>> fetchMothersAsStreamSearchMothers(
      String? organizationId, String start) {
    _api.streamMotherDataSearch(organizationId, start);

    var snapshot = _api.streamMotherDataSearch(organizationId, start);
    return snapshot.map((qShot) {
      return qShot.docs
          .map((doc) => Mother.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  Future<Doctor> getDoctorById(String id) async {
    var doc = await _api.getDocumentById(id);
    return Doctor.fromMap(doc.data() as Map<dynamic, dynamic>, doc.id);
  }

  Stream<QuerySnapshot> fetchDoctorByEmailId(String? id) {
    return _api.streamDocumentByEmailId(id);
  }

  Stream<QuerySnapshot> fetchDoctorByMobile(String? id) {
    return _api.streamDocumentByMobile(id);
  }

  Future<UserModel> getUserById(String id) async {
    var doc = await _api.getDocumentById(id);
    return UserModel.fromMap(doc.data() as Map<dynamic, dynamic>, doc.id);
  }

  Future removeProduct(String id) async {
    await _api.removeDocument(id);
    return;
  }

  Future updateProduct(Mother data, String id) async {
    await _api.updateDocument(data.toJson(), id);
    return;
  }

  Future addProduct(Mother data) async {
    var result = await _api.addDocument(data.toJson());

    return result;
  }
}
