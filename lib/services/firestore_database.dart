import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:l8fe/models/mother_model.dart';
import 'package:l8fe/models/my_user.dart';
import 'package:l8fe/models/user_model.dart';
import 'package:l8fe/services/firestore_path.dart';
import 'dart:math' as math;

class FirestoreDatabase {
  FirestoreDatabase({required this.uid});
  final String uid;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<UserModel?> getOrgDetails({required String id}) async {
    final org = await _firestore.collection('users').doc(id).get();
    UserModel? o;
    if(org.exists) {
      o = UserModel.fromJson(org.data()!);
    }
    debugPrint("getOrgDetails : --- ${o?.toString()}");
    return o;
    /*
    //update assocations lVDwqjV72V7nSHYgiJeY
    final doc = await FirebaseFirestore.instance.collection('users').doc("lVDwqjV72V7nSHYgiJeY").get();
    final map = doc.data()!["associations"];
    final sanpshot = await FirebaseFirestore.instance.collection("users").where("organizationId",isEqualTo: "ar80bjVF4UKnYZAaZvP5").where("type",isEqualTo: "device").get();
    debugPrint("HEDGEWAR associations : $map");
    debugPrint("HEDGEWAR sanpshot : ${sanpshot.docs.length}");
    for (var device in sanpshot.docs) {
      debugPrint("HEDGEWAR documentId ${device.data()["documentId"]}");
      FirebaseFirestore.instance.collection("users").doc(device.id).update({"associations": map});
    }
    */
  }

  Future<Mother?> getMotherDetails({required String id}) async {
    final mom = await _firestore.collection('users').doc(id).get();
    Mother? m;
    if(mom.exists) {
      m = Mother.fromMap(mom.data()!, mom.id);
    }
    debugPrint("getMotherDetails : --- ${m?.toString()}");
    return m;
  }


  Future<String> saveNewTest(Map<String, dynamic> data,{String? testId}) async {
    /*DocumentReference ref = FirebaseFirestore.instance.collection("users")
        .doc(uid).collection("tests").doc();
        FirebaseFirestore.instance
        .collection("users")
        .doc(uid).collection("tests").doc(ref.id)*/


    DocumentReference ref = testId!=null? FirebaseFirestore.instance.collection("tests").doc(testId):FirebaseFirestore.instance.collection("tests").doc();
    debugPrint("saveNewTest : ${ref.id}");
    data["documentId"] = ref.id;
    data["id"] = ref.id;
    ref.set(data, SetOptions(merge: true));
    return ref.id;
  }

  Future<String> deleteNewTest(String? testId) async {
    DocumentReference ref = FirebaseFirestore.instance.collection("tests").doc(testId);
    ref.delete();
    return ref.id;
  }

  Future<String> saveNewTestAndMother(Map<String, dynamic> test,Map<String, dynamic> mom) async {
    DocumentReference refMom = FirebaseFirestore.instance.collection("users").doc(mom["documentId"]);
    // mom["documentId"] = refMom.id;
    refMom.set(mom);
    /*DocumentReference ref = FirebaseFirestore.instance.collection("users")
        .doc(uid).collection("tests").doc();*/
    DocumentReference ref = FirebaseFirestore.instance.collection("tests").doc();
    test["documentId"] = ref.id;
    test["id"] = ref.id;
    test["motherId"] = refMom.id;
    ref.set(test, SetOptions(merge: true));
    debugPrint("new test : --- ${test.toString()}");
    return ref.id;
  }

  Future<String> saveNewMother(Map<String, dynamic> mom) async {
    DocumentReference refMom = FirebaseFirestore.instance.collection("users").doc(mom["documentId"]);
    refMom.set(mom);
    debugPrint("new mom : --- ${mom.toString()}");
    return refMom.id;
  }

  Future<String> saveNewTestAnonymous(Map<String, dynamic> test) async {
    //DocumentReference refMom = FirebaseFirestore.instance.collection("users").doc();
    //mom["documentId"] = "Anonymous";
    //refMom.set(mom);
    /*DocumentReference ref = FirebaseFirestore.instance.collection("users")
        .doc(uid).collection("tests").doc();*/
    DocumentReference ref = FirebaseFirestore.instance.collection("tests").doc();
    test["documentId"] = ref.id;
    test["id"] = ref.id;
    test["motherId"] = "Anonymous";
    ref.set(test, SetOptions(merge: true));
    debugPrint("new test : --- ${test.toString()}");
    return ref.id;
  }

  Stream<List<Map<String, dynamic>>> allMothersStream(oId,
      {bool recent = false, int limit = 30}) {
    Query<Map<String, dynamic>> query;
    query = FirebaseFirestore.instance
        .collection("users")
        .where("organizationId", isEqualTo: oId)
        .where("type", isEqualTo: "mother")
        .orderBy("createdOn", descending: true)
        .limit(limit);

    final Stream<QuerySnapshot> snapshots = query.snapshots();
    return snapshots.map((snapshot) {
      final result = snapshot.docs
          .map((snapshot) => snapshot.data() as Map<String, dynamic>)
          .toList();
      return result;
    });
  }

  Future<QuerySnapshot<Object?>> allMothersPagination(
      {String? oId,
        dynamic lastDocument,
        int limit = 15,
        required String filter}) async {
    Query snapshots;
    snapshots = FirebaseFirestore.instance
        .collection("users")
        .where("organizationId", isEqualTo: oId)
        .where("delete", isEqualTo: false)
        .where("type", isEqualTo: "mother");

    if (filter.length > 2) {
      snapshots = snapshots.where("name",
          isGreaterThanOrEqualTo: filter);
      snapshots = snapshots.where("name",
          isLessThan: "${filter}z");
      snapshots = snapshots.orderBy("modifiedAt", descending: true);

    } else {
      snapshots = snapshots.orderBy("modifiedAt", descending: true);
    }
    if (lastDocument != null) {
      snapshots = snapshots.startAfterDocument(lastDocument!);
    }
    snapshots = snapshots.limit(filter.length > 2 ? 20 : limit);

    return await snapshots.get();
  }

  Stream<List<Map<String, dynamic>>> allTestsStream(oId,
      {bool recent = false, int limit = 10}) {

    Query<Map<String, dynamic>> query;
    query = FirebaseFirestore.instance
        .collection("tests")
        .where("organizationId", isEqualTo: oId)
        .orderBy("createdOn", descending: true)
        .limit(limit);

    final Stream<QuerySnapshot> snapshots = query.snapshots();
    return snapshots.map((snapshot) {
      final result = snapshot.docs
          .map((snapshot) => snapshot.data() as Map<String, dynamic>)
          .toList();
      return result;
    });
  }
  Stream<List<Map<String, dynamic>>> allMotherTestsStream(mId,
      {bool recent = false, int limit = 20}) {
    Query<Map<String, dynamic>> query;
    query = FirebaseFirestore.instance
        .collection("tests")
        .where("motherId", isEqualTo: mId)
        .orderBy("createdOn", descending: true)
        .limit(limit);

    final Stream<QuerySnapshot> snapshots = query.snapshots();
    return snapshots.map((snapshot) {
      final result = snapshot.docs
          .map((snapshot) => snapshot.data() as Map<String, dynamic>)
          .toList();
      return result;
    });
  }
}
