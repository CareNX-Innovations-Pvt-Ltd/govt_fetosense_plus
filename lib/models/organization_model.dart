
import 'package:l8fe/models/user_model.dart';

class Organization extends UserModel{

  int noOfMother = 0;
  int noOfTests = 0;
  int noOfDevices = 0;
  String deviceCode ="";


  Organization.fromMap(Map snapshot,String id) :
        noOfMother = snapshot['noOfMother'] ?? 0,
        noOfTests = snapshot['noOfTests'] ?? 0,
        noOfDevices = snapshot['noOfTests'] ?? 0,
        deviceCode = snapshot["deviceCode"]??'',
        super.fromMap(snapshot,id);

 /* toJson() {
    return {
      "price": price,
      "name": name,
      "img": img,
    };
  }*/
}