import 'package:l8fe/models/user_model.dart';

class Device extends UserModel{

  int noOfMother = 0;
  int noOfTests = 0;
  String deviceName;
  String deviceCode;
  String deviceId;

  Device.fromMap(super.snapshot,super.id) :
        deviceId = snapshot['deviceId']??snapshot['deviceName'],
        deviceName = snapshot['deviceName'],
        deviceCode = snapshot['deviceCode'],
        noOfMother = snapshot['noOfMother']??0,
        noOfTests = snapshot['noOfTests']??0,
        super.fromMap();

  @override
  Map<String, Object?> toJson() {
    return {
      'type': type,
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
      'createdBy': createdBy,
      'testAccount':testAccount,
      'associations': associations,
      'deviceId':deviceId,
      'deviceName' : deviceName,
      'deviceCode' : deviceCode,
      'noOfMother' : noOfMother,
      'noOfTests' : noOfTests,
    };
  }
}