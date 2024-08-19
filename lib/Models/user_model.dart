class UserModel {
  String? uid;
  String? username;
  String? email;
  String? phonenumber;
  String? profile;
  String? about;
  bool? isOnline;

  UserModel({this.uid, this.email, this.username, this.phonenumber, this.profile, this.about, this.isOnline});

  UserModel.fromMap(Map<String, dynamic> map) {

    uid = map['uid'];
    email = map['email'];
    username = map['username'];
    profile = map['profile'];
    phonenumber = map['phonenumber'];
    about = map['about'];
    isOnline = map['isOnline'];

  }

  Map<String, dynamic> toMap (){
    return {
      'uid' : uid,
      'email' : email,
      'username' : username,
      'profile' : profile,
      'phonenumber' : phonenumber,
      'about' : about,
      'isOnline' : isOnline,
    };
  }

}