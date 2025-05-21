enum UserType { bayer, regular }

class MyUser {
  final String uId;
  String oId;
  String name;
  String type;
  bool isAdmin = false;
  String mobileNo;
  String email;
  String state;
  String district;
  final List<String> organizations;

  ///This will determine what modifications should be made
  UserType userType;

  MyUser(
    this.uId,
    this.oId,
    this.name,
    this.mobileNo,
    this.email,
    this.type,
    this.state,
    this.district,
  )   : userType = UserType.regular,
        organizations = [] {
    isAdmin = type.split('_').last == 'admin';
  }

  Map<String, dynamic> toJson() {
    return {
      'uId': uId,
      'oId': oId,
      'name': name,
      'mobileNo': mobileNo,
      'email': email,
      'type': type,
      'state': state,
      'district': district,
    };
  }

  static MyUser fromFirebase(Map<String, dynamic> map) {
    return MyUser(
      map["uid"]??"",
      map["organizationId"]??"",
      map["name"],
      map["mobileNo"] ?? "",
      map["email"] ?? "",
      map["type"] ?? '',
      map["state"] ?? '',
      map["district"] ?? '',
    );
  }
}
