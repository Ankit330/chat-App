class UserModel {
  String? uid;
  String? fullname;
  String? email;
  String? profilepic;
  bool? isOnline;

  UserModel(
      {this.email, this.fullname, this.uid, this.profilepic, this.isOnline});

  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map["uid"];
    fullname = map["fullname"];
    email = map["email"];
    profilepic = map["profilepic"];
    isOnline = map["isonline"];
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "fullname": fullname,
      "email": email,
      "profilepic": profilepic,
      "isonline": isOnline
    };
  }
}
