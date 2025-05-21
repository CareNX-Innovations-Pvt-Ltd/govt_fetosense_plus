import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class TestApi {
  final _db = FirebaseFirestore.instance;
  final String path;
  late CollectionReference ref;

  TestApi(this.path) {
    ref = _db.collection(path);
  }

  Future<QuerySnapshot> getDataCollection() {
    return ref.get();
  }

  Stream<QuerySnapshot> streamDataCollectionForMother(String? id) {
    return ref
        .where("motherId", isEqualTo: id)
        .orderBy("createdOn")
        .snapshots();
  }

  Stream<QuerySnapshot> streamDataCollectionForMotherBabyBeat(String? id) {
    return _db.collection("BabyBeat")
        .where("motherId", isEqualTo: id)
        .orderBy("createdOn")
        .snapshots();
  }

  Stream<QuerySnapshot> streamDataCollectionForOrganization(String? id) {
    return ref
        .where("organizationId", isEqualTo: id)
        .orderBy("createdOn", descending: true)
        .limit(30)
        .snapshots();
  }

  Stream<QuerySnapshot> streamDataCollectionForOrganizationBabyBeat(String? orgId, String? docId) {
    return _db.collection("BabyBeat")
        .where("association.babybeat_org.documentId", isEqualTo: orgId)
        .where("association.babybeat_doctor.documentId", isEqualTo: docId)
        .orderBy("createdOn", descending: true)
        .limit(30)
        .snapshots();
  }

  Stream<QuerySnapshot> streamDataCollectionForOrganizationBabyBeatAll(String? docId) {
    return _db.collection("BabyBeat")
        .where("association.babybeat_doctor.documentId", isEqualTo: docId)
        .orderBy("createdOn", descending: true)
        .limit(30)
        .snapshots();
  }

  Stream<QuerySnapshot> streamDataCollectionForOrganizationOrg(String id) {
    return ref
        .where("organizationId", isEqualTo: id)
        .orderBy("createdOn", descending: true)
        .limit(30)
        .snapshots();
  }

  Stream<QuerySnapshot> streamDataCollectionForOrganizationForTV(
      String? id, int limit) {
    return ref
        .where("organizationId", isEqualTo: id)
        .orderBy("createdOn", descending: true)
        .limit(limit)
        .snapshots();
  }

  Stream<QuerySnapshot> streamDataCollectionForOrganizationOrgForTV(
      String? id, int limit) {
    return ref
        .where("organizationId", isEqualTo: id)
        .orderBy("createdOn", descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<DocumentSnapshot> getDocumentById(String id) {
    return ref.doc(id).get();
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
}
