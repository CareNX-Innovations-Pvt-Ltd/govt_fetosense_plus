import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String type;
  String organizationId;
  String organizationName;
  String organizationIdBabyBeat;
  String organizationNameBabyBeat;
  String name;
  String doctorName;
  String email;
  String mobileNo;
  String uid;
  String notificationToken;
  String documentId;
  bool delete = false;
  bool testAccount = false;
  DateTime createdOn;
  DateTime? modifiedAt;
  String createdBy;
  Map<String,dynamic> associations;
  Map<String,dynamic> babyBeatAssociation;

  UserModel.withData(
      {
      required this.type,
      required this.organizationId,
      required this.organizationName,
      required this.organizationIdBabyBeat,
      required this.organizationNameBabyBeat,
      required this.name,
      required this.doctorName,
      required this.email,
      required this.mobileNo,
      required this.uid,
      required this.notificationToken,
      required this.documentId,
        this.delete = false,
        this.testAccount = false,
      required this.createdOn,
      required this.createdBy,
      required this.associations, required this.babyBeatAssociation});

  UserModel.fromMap(Map snapshot, String id)
      : type = snapshot['type'] ?? '',
        organizationId = snapshot['organizationId'] ?? '',
        organizationName = snapshot['organizationName'] ?? '',
        organizationIdBabyBeat = snapshot['organizationIdBabyBeat'] ?? '',
        organizationNameBabyBeat = snapshot['organizationNameBabyBeat'] ?? '',
        doctorName = snapshot['doctorName'] ?? '',
        name = snapshot['name'] ?? '',
        email = snapshot['email'] ?? '',
        mobileNo = snapshot['mobileNo'] ?? '',
        uid = snapshot['uid'] ?? '',
        notificationToken = snapshot['notificationToken'] ?? '',
        documentId = snapshot['documentId'] ?? id,
        delete = snapshot['delete'] ?? false,
        testAccount = snapshot['testAccount']??false,
        createdOn = snapshot['createdOn']?.toDate()??DateTime.now(),
        modifiedAt = snapshot['modifiedAt']?.toDate()??DateTime.now(),
        createdBy = snapshot['createdBy'] ?? '',
        associations = snapshot['associations']??{},
        babyBeatAssociation = snapshot['babyBeatAssociation']??{};

  UserModel.fromUser(Map device, Map mom)
      : type = device['type'] ?? '',
        organizationId = device['organizationId'] ?? '',
        organizationName = device['organizationName'] ?? '',
        organizationIdBabyBeat = device['organizationIdBabyBeat'] ?? '',
        organizationNameBabyBeat = device['organizationNameBabyBeat'] ?? '',
        doctorName = device['doctorName'] ?? '',
        name = mom['name'] ?? '',
        email = mom['email'] ?? '',
        mobileNo =mom['mobileNo'] ?? '',
        uid =  mom['uid'] ?? '',
        notificationToken = device['notificationToken'] ?? '',
        documentId =  mom["documentId"],
        delete = device['delete'] ?? false,
        testAccount = device['testAccount']??false,
        createdOn = mom['createdOn']??DateTime.now(),
        modifiedAt = mom['modifiedAt']??DateTime.now(),
        createdBy = device['createdBy'] ?? device['documentId'],
        associations = device['associations']??{},
        babyBeatAssociation = device['babyBeatAssociation']??{};

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
      'testAccount': testAccount,
      'createdOn': createdOn,
      'modifiedAt': modifiedAt,
      'createdBy': createdBy,
      'doctorName':doctorName,
      'associations': associations,
      'babyBeatAssociation': babyBeatAssociation,
      'deviceType' : "plus"
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> doc) {
    UserModel user =  UserModel.withData(
        type: doc['type'],
        organizationId: doc['organizationId']??"",
        organizationName: doc['organizationName']??"",
        organizationIdBabyBeat: doc['organizationIdBabyBeat']??"",
        organizationNameBabyBeat: doc['organizationNameBabyBeat']??"",
        name: doc['name'],
        doctorName: doc['name'],
        email: doc['email'],
        mobileNo: doc['mobileNo']??"",
        uid: doc['uid']??"",
        notificationToken: doc['notificationToken']??"",
        documentId: doc['documentId'],
        delete: doc['delete']??false,
        testAccount: doc['testAccount']??false,
        createdOn: doc['createdOn'].toDate()??DateTime.now(),
        createdBy: doc['createdBy']??"",
        associations: doc['associations']??{},
        babyBeatAssociation: doc['babyBeatAssociation']??{});
    return user;
  }

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    return UserModel.fromJson(doc.data() as Map<String, Object>);
  }
}
