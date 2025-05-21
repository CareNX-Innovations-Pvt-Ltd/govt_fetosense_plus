import 'package:l8fe/models/user_model.dart';

class Doctor extends UserModel{

  int noOfMother = 0;
  int noOfTests = 0;


  Doctor.fromMap(Map snapshot,String id) :
        noOfMother = snapshot['noOfMother'],
        noOfTests = snapshot['noOfTests'],
        super.fromMap(snapshot,id);

 /* toJson() {
    return {
      "price": price,
      "name": name,
      "img": img,
    };
  }*/
}