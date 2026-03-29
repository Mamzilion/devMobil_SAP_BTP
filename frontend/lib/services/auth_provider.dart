import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart'; // Assure-toi que le nom du fichier est correct

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  String? _token; // Ajout du token
  bool _isAuthenticated = false;

  // Getters publics
  UserModel? get user => _user;
  String? get token => _token; 
  bool get isAuthenticated => _isAuthenticated;

  final String baseUrl = "http://10.207.5.169:5000/api";

  // --- LOGIN ---
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "mot_de_passe": password, // Vérifie que c'est bien ce nom dans ton Backend
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['user'] != null && data['token'] != null) {
          _user = UserModel.fromJson(data['user']);
          _token = data['token']; // On stocke le token ici !
          _isAuthenticated = true;
          notifyListeners(); 
          return true;
        }
      }
      return false;
    } catch (e) {
      print("Erreur critique login : $e");
      return false;
    }
  }

  // --- REGISTER ---
  Future<bool> register(String nom, String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nom": nom,
          "email": email,
          "mot_de_passe": password,
          "role": role,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print("Erreur inscription : $e");
      return false;
    }
  }

  // --- LOGOUT ---
  void logout() {
    _user = null;
    _token = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}