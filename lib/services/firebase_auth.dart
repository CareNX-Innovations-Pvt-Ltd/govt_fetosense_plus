import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:l8fe/models/device_model.dart';
import 'package:l8fe/models/my_user.dart';
import 'package:l8fe/models/user_model.dart';

class FirebaseAuthRepo {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  FirebaseAuthRepo();

  FirebaseAuth get instance => _firebaseAuth;

  Future<Device?> getCurrentUser() async {
    try {
      final User? fireUser = _firebaseAuth.currentUser;
      if (fireUser != null) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('uid', isEqualTo: fireUser.uid)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // ✅ User exists
          final doc = querySnapshot.docs.first;
          final data = doc.data() as Map<String, dynamic>;
          return Device.fromMap(data, doc.id);
        } else {
          // ❌ User does not exist, create one
          final newUserData = <String, dynamic>{
            'type': 'mother', // or any role you assign
            'organizationId': '',
            'organizationName': '',
            'organizationIdBabyBeat': '',
            'organizationNameBabyBeat': '',
            'name': fireUser.displayName ?? '',
            'doctorName': '',
            'email': fireUser.email ?? '',
            'mobileNo': '',
            'uid': fireUser.uid,
            'notificationToken': '',
            'documentId': '', // temporary, will be updated
            'delete': false,
            'testAccount': false,
            'createdOn': Timestamp.now(),
            'modifiedAt': Timestamp.now(),
            'createdBy': fireUser.uid,
            'associations': {},
            'babyBeatAssociation': {},
            'deviceId': 'defaultDeviceId',
            'deviceName': 'defaultDeviceName',
            'deviceCode': 'defaultCode',
            'noOfMother': 0,
            'noOfTests': 0,
          };

          final docRef = await FirebaseFirestore.instance
              .collection('users')
              .add(newUserData);

          // Update documentId in Firestore
          await docRef.update({'documentId': docRef.id});

          // Return the new Device user
          return Device.fromMap({...newUserData, 'documentId': docRef.id}, docRef.id);
        }
      } else {
        await signOut();
        return null;
      }

    } catch (e) {
      debugPrint("From services/firebase_auth.dart: ${e.toString()}");
      return null;
    }
  }

  bool isAuthenticated() {
    return _firebaseAuth.currentUser != null;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
