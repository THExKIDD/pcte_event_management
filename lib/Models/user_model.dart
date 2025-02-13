class UserModel{
  String? userId;
  String? userName;
  String? userType;
  String? email;
  String? phoneNumber;
  String? password;
  String? otp;
  String? googleId;


  UserModel({
    this.userId,
    this.userName,
    this.userType,
    this.email,
    this.phoneNumber,
    this.password,
    this.googleId,
    this.otp
  });

  UserModel.fromJson(Map<String,dynamic> json)
  {
    userId = json['user_id'] ?? [''];
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
    data['user_id'] = userId;
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