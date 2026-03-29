import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl = "http://10.207.5.169:5000/api/users";

  // 1. LIRE TOUS LES COMPTES (Admin)
  Future<List<dynamic>> getAllUsers(String token, String currentUserRole) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/all"), 
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "role": currentUserRole, // <--- Crucial pour ton middleware
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("🔥 Erreur Fetch All Users: $e");
      return [];
    }
  }

  // 2. RÉCUPÉRER LES EMPLOYÉS (Dirigeant)
  Future<List<dynamic>> getOnlyEmployees(String token, String currentUserRole) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/"), 
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "role": currentUserRole,
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("🔥 Erreur Fetch Employees: $e");
      return [];
    }
  }

  // 3. CRÉER UN COMPTE
  Future<bool> createUser(String token, String currentUserRole, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {
          "Authorization": "Bearer $token", 
          "Content-Type": "application/json",
          "role": currentUserRole,
        },
        body: jsonEncode({
          "nom": data["nom"],
          "email": data["email"],
          "role": data["role"],
          "mot_de_passe": data["password"], 
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print("🔥 Erreur Create User: $e");
      return false;
    }
  }

  // 4. MODIFIER UN COMPTE
  Future<bool> updateUser(String token, String currentUserRole, String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/update/$id"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "role": currentUserRole,
        },
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("🔥 Erreur Update User: $e");
      return false;
    }
  }

  // 5. SUPPRIMER UN COMPTE
  Future<bool> deleteUser(String token, String currentUserRole, String id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/$id"), 
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "role": currentUserRole,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print("🔥 Erreur Delete User: $e");
      return false;
    }
  }
}