import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class Api {
  final _db = FirebaseFirestore.instance;
  final String path;
  late CollectionReference ref;



  Api(this.path) {
    ref = _db.collection(path);

  }

  Future<QuerySnapshot> getDataCollection() {
    return ref.get();
  }

  Stream<QuerySnapshot> streamMotherData(String organizationId) {
    // "BdKtDmfQfJijonDh9p6j"
    return ref
        .where("type", isEqualTo: "mother")
        .where("organizationId", isEqualTo: organizationId)
        .orderBy("createdOn", descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> streamActiveMotherData(String? organizationId) {
    // "BdKtDmfQfJijonDh9p6j"
    DateTime today = new DateTime.now();
    DateTime daysAgo = today.subtract(new Duration(days: 30));
    return ref
        .where("type", isEqualTo: "mother")
        .where("organizationId", isEqualTo: organizationId)
        .where("edd", isGreaterThanOrEqualTo: daysAgo)
        .orderBy("edd")
        .snapshots();
  }

  Stream<QuerySnapshot> streamMotherDataSearch(
      String? organizationId, String filter) {
    // "BdKtDmfQfJijonDh9p6j"
    int char = filter.codeUnitAt(0);
    char++;
    List start = new List<String?>.filled(1, null, growable: false);
    start[0] = '${filter[0].toUpperCase()}${filter.substring(1)}';
    //start[1] = '${filter[0].toLowerCase()}${filter.substring(1)}';
    return ref
        .where("type", isEqualTo: "mother")
        .where("organizationId", isEqualTo: organizationId)
        .orderBy("name")
        //.startAt([]..add(filter))
        .startAt(start)
        .endAt([]..add(new String.fromCharCode(char)))
        .snapshots();
  }

  Stream<QuerySnapshot> streamActiveMothersData(
      String organizationId, String filter) {
    // unused
    int char = filter.codeUnitAt(0);
    char++;
    List start = new List<String?>.filled(1, null, growable: false);
    start[0] = '${filter[0].toUpperCase()}${filter.substring(1)}';
    DateTime today = new DateTime.now();
    DateTime daysAgo = today.subtract(new Duration(days: 30));
    //start[1] = '${filter[0].toLowerCase()}${filter.substring(1)}';
    return ref
        .where("type", isEqualTo: "mother")
        .where("organizationId", isEqualTo: organizationId)
        .where("edd", isGreaterThanOrEqualTo: daysAgo)
        .orderBy("edd")
        .limit(4)
        .snapshots();
  }

  Future<DocumentSnapshot> getDocumentById(String id) {
    return ref.doc(id).get();
  }

  Stream<QuerySnapshot> streamDocumentByEmailId(String? id) {
    return ref
        .where("type", isEqualTo: "doctor")
        .where("email", isEqualTo: id)
        .snapshots();
  }

  Stream<QuerySnapshot> streamDocumentByMobile(String? id) {
    return ref
        .where("type", isEqualTo: "doctor")
        .where("mobileNo", isEqualTo: id)
        .snapshots();
  }

  Future<void> removeDocument(String id) {
    return ref.doc(id).delete();
  }

  Future<DocumentReference> addDocument(Map data) {
    return ref.add(data);
  }

  Future<void> updateDocument(Map data, String id) {
    return ref.doc(id).update(data as Map<Object, Object?>);
  }

  Stream<QuerySnapshot> getUser(String phoneNo) {
    return _db
        .collection('users')
        .where('mobileNo', isEqualTo: phoneNo)
        .snapshots();
  }

  Future<bool> isNewUser(String? phoneNo) async {
    QuerySnapshot result = await _db
        .collection("users")
        .where("mobileNo", isEqualTo: phoneNo)
        .where("type", isEqualTo: "doctor")
        .get();
    final List<DocumentSnapshot> docs = result.docs;
    return docs.length == 0 ? true : false;
  }
}
