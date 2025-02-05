class UserModel{
  String? userName;
  String? userType;
  String? email;
  String? phoneNumber;
  String? password;
  String? otp;
  String? googleId;


  UserModel({
    this.userName,
    required this.userType,
    required this.email,
     this.phoneNumber,
    required this.password,
     this.googleId,
     this.otp
  });

  UserModel.fromJson(Map<String,dynamic> json)
  {
    userName = json['name'];
    userType = json['user_type'];
    email = json['email'];
    phoneNumber = json['phone_number'];
    password = json['password'];
    googleId = json['google_id'];
    otp = json['otp'];

  }

  Map<String,dynamic> toJson(){

    final data = <String, dynamic>{};
    data['name'] = userName;
    data['user_type'] = userType;
    data['email'] = email;
    data['phone_number'] = phoneNumber;
    data['password'] = password;
    data['google_id'] = googleId;
    data['otp'] = otp;
    return data;

  }





}