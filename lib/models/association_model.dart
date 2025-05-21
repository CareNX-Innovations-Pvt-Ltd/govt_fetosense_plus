import 'package:l8fe/models/user_model.dart';

class Association{

  String? id;
  String? name;
  String? type;

  Association({this.id,
             this.name,
              this.type});
/*  Association(User user) {
    this.id = user.getDocumentId();
    this.name = user.getName();
    this.type = user.getType();
  }*/


  Association.fromMap(Map snapshot):
        id = snapshot['id']  ?? '',
        name = snapshot['name'] ?? '',
        type = snapshot['type'] ?? '';

  Association.fromUser(UserModel userModel):
        id = userModel.documentId ?? '',
        name = userModel.name ?? '',
        type = userModel.type ?? '';

  Map<String, Object?> toJson() {
    return {
      'type': type,
      'id': id,
      'name': name,
    };
  }

  String? getId() {
    return id;
  }

  void setId(String id) {
    this.id = id;
  }

  String? getName() {
    return name;
  }

  void setName(String name) {
    this.name = name;
  }

  String? getType() {
    return type;
  }

  void setType(String type) {
    this.type = type;
  }

}
