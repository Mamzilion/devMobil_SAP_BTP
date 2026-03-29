class UserModel {
  final String id;    // Correspond à _id (ex: 69a199...)
  final String nom;
  final String email;
  final String role;  // ADMIN, DIRIGEANT, EMPLOYE, VERIFICATEUR
  final String token;

  UserModel({
    required this.id, 
    required this.nom, 
    required this.email, 
    required this.role, 
    required this.token
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'], // Très important de mapper _id ici
      nom: json['nom'],
      email: json['email'],
      role: json['role'],
      token: json['token'] ?? "",
    );
  }
}