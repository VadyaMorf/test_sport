class UserModel {
  final String? email;

  final String? name;

  final String? surname;

  UserModel({required this.email, required this.name, required this.surname});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'],
      name: json['name'],
      surname: json['surname'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'name': name, 'surname': surname};
  }
}
