class Profile {
  String? id;
  String? phone;
  String? name;
  String? avatar;
  bool? isChildren;
  String? email;
  String? dob;
  String? gender;

  Profile({
    this.id,
    this.phone,
    this.name,
    this.avatar,
    this.isChildren = false,
    this.email,
    this.dob,
    this.gender,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['_id'],
      phone: json['phone'],
      name: json['name'],
      avatar: json['avatar'],
      isChildren: json['isChildren'] ?? false,
      email: json['email'],
      dob: json['dob'],
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'phone': phone,
      'name': name,
      'avatar': avatar,
      'isChildren': isChildren,
      'email': email,
      'dob': dob,
      'gender': gender,
    };
  }
}
