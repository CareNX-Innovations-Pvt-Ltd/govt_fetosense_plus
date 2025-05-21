import 'package:l8fe/models/user_model.dart';

class Mother extends UserModel {
  int? age;
  int weight = 0;
  DateTime lmp;
  DateTime edd;
  int noOfTests = 0;
  String? patientId;
  String deviceId;
  String deviceName;
  String? doctorId;
  @override
  String doctorName;

  Mother.fromMap(Map<String, dynamic> super.snapshot, super.id)
      : age = snapshot['age'],
        weight = snapshot['weight'] ?? 0,
        lmp = snapshot['lmp']?.toDate() ?? DateTime.now(),
        edd = snapshot['edd']?.toDate() ?? DateTime.now(),
        noOfTests = snapshot['noOfTests'] ?? 0,
        patientId = snapshot['patientId'],
        deviceId = snapshot['deviceId'],
        doctorName = snapshot['doctorName'] ?? "",
        doctorId = snapshot['doctorId'],
        deviceName = snapshot['deviceName'] ?? snapshot['deviceId'],
        super.fromMap();

  Mother.fromUser(
      Map<String, dynamic> super.device, Map<String, dynamic> super.mom)
      : age = mom['age'],
        weight = mom['weight'] ?? 0,
        lmp = mom['lmp'] ?? DateTime.now(),
        edd = mom['edd'] ?? DateTime.now(),
        noOfTests = mom['noOfTests'] ?? 0,
        patientId = mom['patientId'],
        deviceId = device['deviceId'],
        doctorName = mom['doctorName'] ?? device['doctorName'] ?? "",
        doctorId = mom['doctorId'],
        deviceName = device['deviceName'],
        super.fromUser();

  @override
  Map<String, Object?> toJson() {
    return {
      'type': "mother",
      'organizationId': organizationId,
      'organizationName': organizationName,
      'organizationIdBabyBeat': organizationIdBabyBeat,
      'organizationNameBabyBeat': organizationNameBabyBeat,
      'name': name,
      'email': email,
      'mobileNo': mobileNo,
      'uid': uid,
      'notificationToken': notificationToken,
      'documentId': documentId,
      'delete': delete,
      'createdOn': createdOn,
      'modifiedAt': modifiedAt,
      'createdBy': createdBy,
      'associations': associations,
      'babyBeatAssociation': babyBeatAssociation,
      'weight': weight,
      'lmp': lmp,
      'edd': edd,
      'age': age,
      'noOfTests': noOfTests,
      'patientId': patientId,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'doctorName': doctorName,
      'doctorId': doctorId,
      'testAccount': testAccount,
      'deviceType': "plus"
    };
  }

/*Mother.fromMap(Map snapshot,String id):
        type = snapshot['type']  ?? '',
        organizationId = snapshot['organizationId'] ?? '',
        organizationName = snapshot['organizationName'] ?? '',
        name = snapshot['name'] ?? '',
        email = snapshot['email'] ?? '',
        mobileNo = snapshot['mobileNo'] ?? '',
        uid = snapshot['uid'] ?? '',
        notificationToken = snapshot['notificationToken'] ?? '',
        documentId = snapshot['documentId'] ?? '',
        delete = snapshot['delete'] ?? '',
        createdOn = snapshot['createdOn'] ?? '',
        createdBy = snapshot['createdBy'] ?? '',
        associations = snapshot['associations'] ?? '';*/
}
