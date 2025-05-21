
import 'package:l8fe/models/device_model.dart';
import 'package:l8fe/models/mother_model.dart';
import 'package:l8fe/models/user_model.dart';
import 'package:l8fe/utils/date_format_utils.dart';

class CtgTest {
  String? id;
  String? documentId;
  String? motherId;
  String? deviceId;
  String? doctorId;

  int? age;
  int? gAge;
  int fisherScore = 0;

  String? motherName;
  String? deviceName;
  String? doctorName;
  String? patientId;

  String? organizationId;
  String? organizationName;

  String? imageLocalPath;
  String? imageFirePath;
  String? audioLocalPath;
  String? audioFirePath;
  bool isImgSynced = false;
  bool isAudioSynced = false;

  List<int> bpmEntries = [];
  List<int> bpmEntries2 = [];
  List<int> mhrEntries = [];
  List<int> spo2Entries = [];
  List<int> baseLineEntries = [];
  List<int> movementEntries = [];
  List<int> autoFetalMovement = [];
  List<int> tocoEntries = [];
  Map<String,dynamic>? lastBp;
  int lengthOfTest = 0;
  int? averageFHR;

  bool live = false;

  bool testByMother = false;
  String? testById;

  String interpretationType ="";
  String? interpretationExtraComments;

  Map<String, dynamic>? associations;
  Map<String, dynamic>? autoInterpretations;

  bool? delete = false;
  DateTime createdOn = DateTime.now();
  DateTime? modifiedAt = DateTime.now();
  String? createdBy;

  Map<String,dynamic>? fisherScoreArray={};

  CtgTest.fromMap(Map snapshot, String id)
      : id = snapshot['id'],
        documentId = snapshot['documentId'] ?? '',
        motherId = snapshot['motherId'],
        deviceId = snapshot['deviceId'],
        doctorId = snapshot['doctorId'],
        age = snapshot['age'],
        gAge = snapshot['gAge'],
        fisherScore = snapshot['fisherScore']??0,
        motherName = snapshot['motherName'],
        deviceName = snapshot['deviceName'],
        doctorName = snapshot['doctorName'],
        patientId = snapshot['patientId'],
        organizationId = snapshot['organizationId'],
        organizationName = snapshot['organizationName'],
        imageLocalPath = snapshot['imageLocalPath'],
        imageFirePath = snapshot['imageFirePath'],
        audioLocalPath = snapshot['audioLocalPath'],
        audioFirePath = snapshot['audioFirePath'],
        isImgSynced = snapshot['isImgSynced']??false,
        isAudioSynced = snapshot['isAudioSynced']??false,
        bpmEntries = snapshot['bpmEntries'] != null
            ? snapshot['bpmEntries'].cast<int>()
            : <int>[],
        bpmEntries2 = snapshot['bpmEntries2'] != null
            ? snapshot['bpmEntries2'].cast<int>()
            : <int>[],
        baseLineEntries = snapshot['baseLineEntries'] != null
            ? snapshot['baseLineEntries'].cast<int>()
            : <int>[],
        mhrEntries = snapshot['mhrEntries'] != null
            ? snapshot['mhrEntries'].cast<int>()
            : <int>[],
        spo2Entries = snapshot['spo2Entries'] != null
            ? snapshot['spo2Entries'].cast<int>()
            : <int>[],
        movementEntries = snapshot['movementEntries'] != null
            ? snapshot['movementEntries'].cast<int>()
            : <int>[],
        autoFetalMovement = snapshot['autoFetalMovement'] != null
            ? snapshot['autoFetalMovement'].cast<int>()
            : <int>[],
        tocoEntries = snapshot['tocoEntries'] != null
            ? snapshot['tocoEntries'].cast<int>()
            : <int>[],
        lengthOfTest = snapshot['lengthOfTest']??0,
        averageFHR = snapshot['averageFHR'],
        live = snapshot['live'] ?? false,
        lastBp = snapshot['lastBp'],

      testByMother = snapshot['testByMother']??false,
        testById = snapshot['testById'],
        interpretationType = snapshot['interpretationType']??"",
        interpretationExtraComments = snapshot['interpretationExtraComments'],
        associations = snapshot['association'] ?? {},
        autoInterpretations = snapshot['autoInterpretations'] ?? {},
        fisherScoreArray = snapshot['autoInterpretations']?["fisherScore"]??snapshot['FisherScoreArray']??{},
        delete = snapshot['delete'],
        createdOn = snapshot['createdOn'].toDate(),
        modifiedAt = snapshot['modifiedAt']?.toDate()??snapshot['createdOn'].toDate(),
        createdBy = snapshot['createdBy'];

  CtgTest();

  CtgTest.withDevice(Device user):
    organizationId = user.organizationId,
    organizationName = user.organizationName,
    doctorName = user.doctorName,
    deviceName = user.deviceName,
    deviceId = user.deviceId,
    testById = user.documentId,
    associations = user.associations,
    createdOn = DateTime.now(),
    modifiedAt = DateTime.now(),
    createdBy = user.documentId;

  CtgTest.withMother(Mother user):
    motherId = user.documentId,
    patientId = user.patientId,
    motherName = user.name,
    doctorName = user.doctorName,
    deviceName = user.deviceName,
    age = user.age,
    gAge = user.lmp.getGestAge(),
    organizationId = user.organizationId,
    organizationName = user.organizationName,
    deviceId = user.deviceId,
    testById = user.documentId,
    associations = user.associations,
    createdOn = DateTime.now(),
    modifiedAt = DateTime.now(),
    createdBy = user.documentId;
/*
  User({this.name,
    this.email,
    this.createdOn,
    this.createdBy,
    this.uid,
})
*/

  Map<String, Object?> toJson() {
    return {
      'documentId': documentId,
      'motherId': motherId,
      'deviceId': deviceId,
      'doctorId': doctorId,
      'age': gAge??0,
      'gAge': gAge,
      'fisherScore' : fisherScore,
      'motherName': motherName,
      'deviceName': deviceName,
      'doctorName': doctorName,
      'patientId': patientId,
      'organizationId': organizationId,
      'organizationName': organizationName,

      'audioLocalPath': audioLocalPath,

      'bpmEntries': bpmEntries,
      'bpmEntries2': bpmEntries2,
      'baseLineEntries': baseLineEntries,
      'movementEntries': movementEntries,
      'mhrEntries': mhrEntries,
      'spo2Entries': spo2Entries,
      'autoFetalMovement': autoFetalMovement,
      'tocoEntries': tocoEntries,
      'lengthOfTest': lengthOfTest,
      'averageFHR': averageFHR,
      'lastBp': lastBp,
      'live': live ?? false,
      'testByMother': testByMother,
      'testById': testById,
      'interpretationType': interpretationType,
      'interpretationExtraComments': interpretationExtraComments,

      'association' : associations,
      'autoInterpretations' : autoInterpretations,
      'FisherScoreArray' : fisherScoreArray,
      'type': "plus",
      'delete': delete,
      'createdOn': createdOn,
      'modifiedAt': modifiedAt,
      'createdBy': createdBy,
      'deviceType' : "plus"
    };
  }

  @override
  String toString() => 'CtgTest(testId: $documentId)';
}
